import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:flashcards_app/data/local/deck_daily_stats_sync.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/study_session/html_generator.dart';
import 'package:flashcards_app/features/study_session/srs_service.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class StudyPage extends ConsumerStatefulWidget {
  final String packName;
  final List<Flashcard> cards;
  final int initialIndex;
  final String? sessionId;
  final DateTime? sessionStartedAt;
  const StudyPage({
    super.key,
    required this.packName,
    required this.cards,
    this.initialIndex = 0,
    this.sessionId,
    this.sessionStartedAt,
  });
  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  InAppWebViewController? webViewController;
  late List<Flashcard> studyQueue;
  int currentIndex = 0;
  bool isAnswerShown = false;
  bool isReadingShown = false;
  bool isComplexCard = false;
  bool isWriteModeActive = false;
  int currentWriteScore = 0;
  int minScoreRequired = 0;
  final SrsService _srsService = SrsService();
  DeckSettings? _currentDeckSettings;
  bool _webReady = false;
  bool _pendingReloadAfterSettings = false;
  bool _sessionCleared = false;
  _UndoAction? _lastUndo;
  StreamSubscription<void>? _deckSettingsSubscription;
  DateTime? _cardShownAt;
  late final String _activeSessionId;
  late final DateTime _sessionStartedAt;
  List<TextEditingController> _writeControllers = <TextEditingController>[];
  _WriteModeCardData? _writeModeCardData;
  final GlobalKey _studyAppBarKey = GlobalKey();
  final GlobalKey _showAnswerKey = GlobalKey();
  final GlobalKey _ratingControlsKey = GlobalKey();
  final GlobalKey _finishedBackButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    studyQueue = List.from(widget.cards);
    currentIndex = widget.initialIndex
        .clamp(0, studyQueue.isEmpty ? 0 : studyQueue.length - 1)
        .toInt();
    _activeSessionId = widget.sessionId?.trim().isNotEmpty == true
        ? widget.sessionId!.trim()
        : '${widget.packName}-${DateTime.now().microsecondsSinceEpoch}';
    _sessionStartedAt = widget.sessionStartedAt ?? DateTime.now();
    _markCurrentCardShown();
    _startDeckSettingsWatcher();
    _refreshDeckSettingsFromDb(reloadHtml: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistStudySession();
      _recomputeCurrentCardState();
    });
  }

  @override
  void dispose() {
    _deckSettingsSubscription?.cancel();
    _disposeWriteControllers();
    super.dispose();
  }

  bool get _isFinished => currentIndex >= studyQueue.length;
  bool get _undoEnabled => _currentDeckSettings?.enableUndo ?? true;

  Map<String, dynamic> _decodeExtraData(String? rawExtra) {
    if (rawExtra == null || rawExtra.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(rawExtra);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  void _disposeWriteControllers() {
    for (final controller in _writeControllers) {
      controller.dispose();
    }
    _writeControllers = <TextEditingController>[];
  }

  List<String> _splitHtmlSegments(String rawHtml) {
    final normalized = rawHtml.trim();
    if (normalized.isEmpty) return const <String>[];
    final splitRegex = RegExp(
      r'<strong>\s*\d+\.\s*</strong>',
      caseSensitive: false,
    );
    final parts = normalized
        .split(splitRegex)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts : <String>[normalized];
  }

  String _decodeBasicHtmlEntities(String value) {
    return value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  String _plainTextFromHtml(String? rawHtml) {
    if (rawHtml == null || rawHtml.trim().isEmpty) return '';
    final withoutBreaks = rawHtml.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      ' ',
    );
    final noTags = withoutBreaks.replaceAll(RegExp(r'<[^>]+>'), '');
    final decoded = _decodeBasicHtmlEntities(noTags);
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  _WriteModeCardData _buildWriteModeCardData(Flashcard card) {
    final sourceRaw = card.sentence ?? '';
    final targetRaw = card.translation ?? '';

    final sourceParts = _splitHtmlSegments(sourceRaw);
    final targetParts = _splitHtmlSegments(targetRaw);

    final targets = targetParts
        .map(_plainTextFromHtml)
        .where((part) => part.isNotEmpty)
        .toList();
    if (targets.isEmpty) {
      final fallbackTarget = _plainTextFromHtml(targetRaw);
      if (fallbackTarget.isNotEmpty) {
        targets.add(fallbackTarget);
      }
    }

    final prompts = sourceParts
        .map(_plainTextFromHtml)
        .where((part) => part.isNotEmpty)
        .toList();
    if (prompts.isEmpty) {
      final fallbackPrompt = _plainTextFromHtml(sourceRaw);
      if (fallbackPrompt.isNotEmpty) {
        prompts.add(fallbackPrompt);
      }
    }

    if (prompts.length > targets.length) {
      prompts.removeRange(targets.length, prompts.length);
    }
    while (prompts.length < targets.length) {
      prompts.add('');
    }

    return _WriteModeCardData(prompts: prompts, targets: targets);
  }

  void _configureWriteModeInputs(Flashcard card, bool writeActive) {
    if (!writeActive) {
      _writeModeCardData = null;
      _disposeWriteControllers();
      return;
    }

    final data = _buildWriteModeCardData(card);
    _writeModeCardData = data;
    _disposeWriteControllers();
    _writeControllers = List<TextEditingController>.generate(
      data.targets.length,
      (_) => TextEditingController(),
    );
  }

  void _markCurrentCardShown() {
    _cardShownAt = _isFinished ? null : DateTime.now();
  }

  int _currentCardStudyDurationMs(DateTime now) {
    final shownAt = _cardShownAt;
    if (shownAt == null) return 0;
    final elapsed = now.difference(shownAt).inMilliseconds;
    return elapsed < 0 ? 0 : elapsed;
  }

  void _startDeckSettingsWatcher() {
    final isar = Isar.getInstance();
    if (isar == null) return;
    _deckSettingsSubscription?.cancel();
    _deckSettingsSubscription = isar.deckSettings.watchLazy().listen((_) {
      _refreshDeckSettingsFromDb(reloadHtml: true);
    });
  }

  Future<DeckSettings?> _refreshDeckSettingsFromDb({
    bool reloadHtml = false,
  }) async {
    final isar = Isar.getInstance();
    if (isar == null) return _currentDeckSettings;
    final settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(widget.packName)
        .findFirst();
    if (!mounted) return settings;
    setState(() {
      _currentDeckSettings = settings;
    });
    if (reloadHtml) {
      _recomputeCurrentCardState(reloadHtml: true);
    }
    return settings;
  }

  void _reloadCurrentHtml() {
    if (!_webReady || webViewController == null) {
      _pendingReloadAfterSettings = true;
      return;
    }
    if (_isFinished) return;
    final card = studyQueue[currentIndex];
    webViewController!.loadData(
      data: HtmlGenerator.generateContent(
        card,
        l10n: context.l10n,
        writeMode: isWriteModeActive,
        nativeWriteInput: isWriteModeActive,
        brightness: Theme.of(context).brightness,
      ),
    );
  }

  Color _cardTypeColor(Flashcard card) {
    if (card.state == CardState.newCard) return AppUiColors.info(context);
    if (card.state == CardState.learning && card.learningStep == 0) {
      return AppUiColors.warning(context);
    }
    return AppUiColors.success(context);
  }

  bool _isEpoch(DateTime dt) => dt.millisecondsSinceEpoch == 0;

  Future<void> _ensureProductionReadings(Flashcard card) async {
    if (!card.cardType.endsWith('prod')) return;

    final extra = _decodeExtraData(card.extraDataJson);
    final hasTargetReading = (extra['target_reading'] ?? '')
        .toString()
        .trim()
        .isNotEmpty;
    final hasSentenceReading = (extra['sentence_reading'] ?? '')
        .toString()
        .trim()
        .isNotEmpty;
    if (hasTargetReading && hasSentenceReading) return;

    final isar = Isar.getInstance();
    if (isar == null) return;

    final twinCardType = card.cardType.replaceFirst(RegExp(r'prod$'), 'recog');
    final twin = await isar.flashcards
        .filter()
        .packNameEqualTo(card.packName)
        .originalIdEqualTo(card.originalId)
        .cardTypeEqualTo(twinCardType)
        .findFirst();
    if (!mounted || twin == null) return;

    final twinExtra = _decodeExtraData(twin.extraDataJson);
    var changed = false;

    if (!hasTargetReading) {
      final twinWordReading = (twinExtra['reading'] ?? '').toString().trim();
      if (twinWordReading.isNotEmpty) {
        extra['target_reading'] = twinWordReading;
        changed = true;
      }
    }

    if (!hasSentenceReading) {
      final twinSentenceReading = (twinExtra['sentence_reading'] ?? '')
          .toString()
          .trim();
      if (twinSentenceReading.isNotEmpty) {
        extra['sentence_reading'] = twinSentenceReading;
        changed = true;
      }
    }

    if (!changed) return;

    card.extraDataJson = jsonEncode(extra);
    if (_isFinished || studyQueue[currentIndex].id != card.id) return;
    if (isAnswerShown || isReadingShown) return;
    _reloadCurrentHtml();
  }

  bool _hasMeaningfulRecognitionReading(
    Flashcard card,
    Map<String, dynamic> extra,
  ) {
    final wordReading = (extra['reading'] ?? '').toString().trim();
    final sentenceReading = (extra['sentence_reading'] ?? '').toString().trim();
    final question = card.question.trim();
    final sentence = (card.sentence ?? '').trim();

    final hasWordReading = wordReading.isNotEmpty && wordReading != question;
    final hasSentenceReading =
        sentenceReading.isNotEmpty && sentenceReading != sentence;
    return hasWordReading || hasSentenceReading;
  }

  void _recomputeCurrentCardState({bool reloadHtml = false}) {
    if (_isFinished) return;
    final card = studyQueue[currentIndex];
    final extra = _decodeExtraData(card.extraDataJson);

    final bool isRecog = card.cardType.endsWith('recog');
    final bool hasReading = _hasMeaningfulRecognitionReading(card, extra);
    final bool writeEnabled = _currentDeckSettings?.enableWriteMode ?? false;
    final bool isProd = card.cardType.endsWith('prod');
    final int maxReps = _currentDeckSettings?.writeModeMaxReps ?? 0;
    final bool withinMax = (maxReps <= 0) || (card.repetitionCount < maxReps);
    final bool writeActive = writeEnabled && isProd && withinMax;
    _configureWriteModeInputs(card, writeActive);

    setState(() {
      isComplexCard = isRecog && hasReading;
      isWriteModeActive = writeActive;
      minScoreRequired = writeActive
          ? (_currentDeckSettings?.writeModeThreshold ?? 80)
          : 0;
      currentWriteScore = 0;
    });

    if (reloadHtml) _reloadCurrentHtml();
    if (isProd) {
      unawaited(_ensureProductionReadings(card));
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidedTourState = ref.watch(guidedTourProvider);

    return PopScope(
      canPop: !guidedTourState.step.isStudyStep,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          return;
        }
        if (_isFinished) {
          await _completeSessionIfNeeded();
        } else {
          await _persistStudySession();
        }
      },
      child: _isFinished
          ? _buildFinished(guidedTourState)
          : _buildStudy(guidedTourState),
    );
  }

  Widget _buildFinished(GuidedTourState guidedTourState) {
    final l10n = context.l10n;
    final isTourFinishedStep =
        guidedTourState.step == GuidedTourStep.studyFinishedExplain;

    final page = Scaffold(
      appBar: AppBar(title: Text(l10n.tr('study_finished_title'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppUiColors.success(context),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.tr('study_finished_message'),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            KeyedSubtree(
              key: _finishedBackButtonKey,
              child: ElevatedButton(
                onPressed: () {
                  if (isTourFinishedStep) {
                    ref
                        .read(guidedTourProvider.notifier)
                        .onStudyFinishedScreenClosed();
                    Navigator.pop(context, 'tour_finished');
                    return;
                  }
                  Navigator.pop(context);
                },
                child: Text(l10n.tr('common_back')),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isTourFinishedStep) return page;

    return Stack(
      children: [
        page,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: AppUiColors.scrim(context)),
          ),
        ),
        TourOverlayCard(
          targetKey: _finishedBackButtonKey,
          message: l10n.tr('onboarding_tour_study_finished'),
        ),
      ],
    );
  }

  Widget _buildStudy(GuidedTourState guidedTourState) {
    final l10n = context.l10n;
    final card = studyQueue[currentIndex];
    final tourStep = guidedTourState.step;
    final isTourInStudy = tourStep.isStudyStep;
    final showTourOverlay =
        isTourInStudy && tourStep != GuidedTourStep.studyFinishRemaining;

    final page = Scaffold(
      appBar: AppBar(
        key: _studyAppBarKey,
        title: Text(
          l10n.tr(
            'study_progress',
            params: <String, Object?>{
              'current': currentIndex + 1,
              'total': studyQueue.length,
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _cardTypeColor(card)),
        ),
        actions: [
          if (_undoEnabled && _lastUndo != null)
            IconButton(
              tooltip: l10n.tr('study_undo'),
              onPressed: _performUndo,
              icon: const Icon(Icons.undo),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              initialData: InAppWebViewInitialData(
                data: HtmlGenerator.generateContent(
                  card,
                  l10n: context.l10n,
                  writeMode: isWriteModeActive,
                  nativeWriteInput: isWriteModeActive,
                  brightness: Theme.of(context).brightness,
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                _webReady = true;

                controller.addJavaScriptHandler(
                  handlerName: 'submitScore',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      final raw = args[0];
                      final score = (raw is int)
                          ? raw
                          : int.tryParse(raw.toString()) ?? 0;
                      setState(() => currentWriteScore = score);
                    }
                    return null;
                  },
                );
                if (_pendingReloadAfterSettings) {
                  _pendingReloadAfterSettings = false;
                  _reloadCurrentHtml();
                }
              },
            ),
          ),
          if (isWriteModeActive && !isAnswerShown) _buildNativeWritePanel(),
          _buildControls(card, guidedTourState),
        ],
      ),
    );

    if (!showTourOverlay) return page;

    return Stack(
      children: [
        page,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: AppUiColors.scrim(context)),
          ),
        ),
        TourOverlayCard(
          targetKey: _targetKeyForStudyStep(tourStep),
          message: _tourStudyMessage(l10n, tourStep),
          actionLabel: _canAdvanceStudyStep(tourStep)
              ? l10n.tr('onboarding_tour_next')
              : null,
          onActionPressed: _canAdvanceStudyStep(tourStep)
              ? () => ref
                    .read(guidedTourProvider.notifier)
                    .nextStudyNarrationStep()
              : null,
        ),
      ],
    );
  }

  Widget _buildNativeWritePanel() {
    final l10n = context.l10n;
    final data = _writeModeCardData;
    if (data == null || data.targets.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = _StudyWritePalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.tr('html_write_sentences'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < data.targets.length; i++) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: palette.line),
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.targets.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${i + 1}.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: palette.accentDark,
                                ),
                              ),
                            ),
                          if (data.prompts[i].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                data.prompts[i],
                                style: TextStyle(
                                  fontSize: 20,
                                  height: 1.5,
                                  color: palette.text,
                                ),
                              ),
                            ),
                          TextField(
                            controller: _writeControllers[i],
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: i == data.targets.length - 1
                                ? TextInputAction.done
                                : TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            enableIMEPersonalizedLearning: false,
                            smartDashesType: SmartDashesType.disabled,
                            smartQuotesType: SmartQuotesType.disabled,
                            spellCheckConfiguration:
                                const SpellCheckConfiguration.disabled(),
                            autofillHints: null,
                            minLines: 3,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              color: palette.text,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.tr('html_write_placeholder'),
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: palette.soft,
                              ),
                              filled: true,
                              fillColor: palette.card,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: palette.line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: palette.accent,
                                  width: 1.5,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: palette.line),
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) {
                              if (i < data.targets.length - 1) {
                                FocusScope.of(context).nextFocus();
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i != data.targets.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _escapeHtml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
  }

  _WriteDiffResult _compareByWords(String user, String target) {
    final cleanUser = user.replaceAll(RegExp(r'\s+'), ' ').trim();
    final cleanTarget = target.replaceAll(RegExp(r'\s+'), ' ').trim();

    final userWords = cleanUser.isEmpty
        ? const <String>[]
        : cleanUser.split(' ');
    final targetWords = cleanTarget.isEmpty
        ? const <String>[]
        : cleanTarget.split(' ');

    final html = StringBuffer();
    var totalCorrectChars = 0;
    var totalTargetChars = cleanTarget.replaceAll(' ', '').characters.length;
    if (totalTargetChars == 0) totalTargetChars = 1;

    for (var i = 0; i < targetWords.length; i++) {
      final targetWord = targetWords[i];
      final userWord = i < userWords.length ? userWords[i] : '';
      final targetChars = targetWord.characters.toList();
      final userChars = userWord.characters.toList();
      final maxLength = targetChars.length > userChars.length
          ? targetChars.length
          : userChars.length;

      for (var k = 0; k < maxLength; k++) {
        final targetChar = k < targetChars.length ? targetChars[k] : '';
        final userChar = k < userChars.length ? userChars[k] : '';

        if (targetChar.toLowerCase() == userChar.toLowerCase()) {
          html.write(
            "<span class='diff-good'>${_escapeHtml(targetChar)}</span>",
          );
          if (targetChar.isNotEmpty) totalCorrectChars++;
        } else if (targetChar.isNotEmpty) {
          html.write(
            "<span class='diff-bad'>${_escapeHtml(targetChar)}</span>",
          );
        }
      }
      html.write(' ');
    }

    var percent = ((totalCorrectChars / totalTargetChars) * 100).round();
    if (percent > 100) percent = 100;
    return _WriteDiffResult(html: html.toString(), percent: percent);
  }

  _WriteModeEvaluation? _evaluateWriteInputs() {
    final data = _writeModeCardData;
    if (!isWriteModeActive || data == null || data.targets.isEmpty) {
      return null;
    }

    var totalPercent = 0;
    final resultHtml = StringBuffer();
    final userRawHtml = StringBuffer();

    for (var i = 0; i < data.targets.length; i++) {
      final userText = i < _writeControllers.length
          ? _writeControllers[i].text
          : '';
      final targetText = data.targets[i];
      final diff = _compareByWords(userText, targetText);
      totalPercent += diff.percent;

      final escapedUserText = _escapeHtml(userText).replaceAll('\n', '<br>');
      if (data.targets.length > 1) {
        userRawHtml.write('${i + 1}. $escapedUserText<br>');
        resultHtml.write('<div class="diff-row"><strong>${i + 1}. </strong>');
      } else {
        userRawHtml.write(escapedUserText);
        resultHtml.write('<div class="diff-row">');
      }
      resultHtml.write(diff.html);
      resultHtml.write('</div>');
    }

    final score = (totalPercent / data.targets.length).round();
    return _WriteModeEvaluation(
      score: score,
      resultHtml: resultHtml.toString(),
      userRawHtml: userRawHtml.toString(),
    );
  }

  Future<void> _pushWriteEvaluationToWebView(
    _WriteModeEvaluation evaluation,
  ) async {
    final controller = webViewController;
    if (controller == null) return;
    final script =
        'setNativeWriteResults(${jsonEncode(evaluation.resultHtml)}, '
        '${jsonEncode(evaluation.userRawHtml)}, ${evaluation.score});';
    await controller.evaluateJavascript(source: script);
  }

  Widget _buildControls(Flashcard card, GuidedTourState guidedTourState) {
    final l10n = context.l10n;
    final tourStep = guidedTourState.step;
    final isTourInStudy = tourStep.isStudyStep;
    final canShowAnswer =
        !isTourInStudy ||
        tourStep == GuidedTourStep.studyShowAnswerFirst ||
        tourStep == GuidedTourStep.studyShowAnswerSecond ||
        tourStep == GuidedTourStep.studyFinishRemaining;
    final canRateInTour =
        !isTourInStudy ||
        tourStep == GuidedTourStep.studyRateFirst ||
        tourStep == GuidedTourStep.studyRateSecond ||
        tourStep == GuidedTourStep.studyFinishRemaining;

    if (!isAnswerShown) {
      if (isComplexCard && !isReadingShown) {
        return _singleButton(
          label: l10n.tr('study_show_reading'),
          color: AppUiColors.warning(context),
          onPressed: () {
            setState(() => isReadingShown = true);
            webViewController?.evaluateJavascript(source: "showReading()");
            _persistStudySession();
          },
        );
      }

      return KeyedSubtree(
        key: _showAnswerKey,
        child: _singleButton(
          label: l10n.tr('study_show_answer'),
          color: AppUiColors.info(context),
          onPressed: canShowAnswer
              ? () async {
                  final evaluation = _evaluateWriteInputs();
                  if (evaluation != null) {
                    setState(() => currentWriteScore = evaluation.score);
                    await _pushWriteEvaluationToWebView(evaluation);
                  }
                  setState(() => isAnswerShown = true);
                  await webViewController?.evaluateJavascript(
                    source: "showAnswer()",
                  );
                  Future<void>.delayed(const Duration(milliseconds: 80), () {
                    if (!mounted) return;
                    ref.read(guidedTourProvider.notifier).onStudyAnswerShown();
                  });
                  _persistStudySession();
                }
              : () {},
        ),
      );
    }

    if (isComplexCard && !isReadingShown) {
      return _singleButton(
        label: l10n.tr('study_show_reading'),
        color: AppUiColors.warning(context),
        onPressed: () {
          setState(() => isReadingShown = true);
          webViewController?.evaluateJavascript(source: "showReading()");
          _persistStudySession();
        },
      );
    }

    final bool writePassed =
        !isWriteModeActive || (currentWriteScore >= minScoreRequired);
    return KeyedSubtree(
      key: _ratingControlsKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _ratingButton(
              l10n.tr('study_bad'),
              AppUiColors.danger(context),
              () => _submitAnswer(card, false),
              canRateInTour,
            ),
            _ratingButton(
              l10n.tr('study_good'),
              AppUiColors.success(context),
              () => _submitAnswer(card, true),
              writePassed && canRateInTour,
            ),
          ],
        ),
      ),
    );
  }

  bool _canAdvanceStudyStep(GuidedTourStep step) {
    return step == GuidedTourStep.studyIntro ||
        step == GuidedTourStep.studyTopCounter ||
        step == GuidedTourStep.studyTypeBar ||
        step == GuidedTourStep.studySecondCardIntro;
  }

  GlobalKey? _targetKeyForStudyStep(GuidedTourStep step) {
    return switch (step) {
      GuidedTourStep.studyIntro ||
      GuidedTourStep.studyTopCounter ||
      GuidedTourStep.studyTypeBar ||
      GuidedTourStep.studySecondCardIntro => _studyAppBarKey,
      GuidedTourStep.studyShowAnswerFirst ||
      GuidedTourStep.studyShowAnswerSecond => _showAnswerKey,
      GuidedTourStep.studyRateFirst ||
      GuidedTourStep.studyRateSecond => _ratingControlsKey,
      GuidedTourStep.studyFinishedExplain => _finishedBackButtonKey,
      _ => null,
    };
  }

  String _tourStudyMessage(AppLocalizations l10n, GuidedTourStep step) {
    switch (step) {
      case GuidedTourStep.studyIntro:
        return l10n.tr('onboarding_tour_study_intro');
      case GuidedTourStep.studyTopCounter:
        return l10n.tr('onboarding_tour_study_counter');
      case GuidedTourStep.studyTypeBar:
        return l10n.tr('onboarding_tour_study_type_bar');
      case GuidedTourStep.studyShowAnswerFirst:
        return l10n.tr('onboarding_tour_study_show_answer');
      case GuidedTourStep.studyRateFirst:
        return l10n.tr('onboarding_tour_study_rate_first');
      case GuidedTourStep.studySecondCardIntro:
        return l10n.tr('onboarding_tour_study_second_intro');
      case GuidedTourStep.studyShowAnswerSecond:
        return l10n.tr('onboarding_tour_study_show_answer_second');
      case GuidedTourStep.studyRateSecond:
        return l10n.tr('onboarding_tour_study_rate_second');
      case GuidedTourStep.studyFinishedExplain:
        return l10n.tr('onboarding_tour_study_finished');
      default:
        return '';
    }
  }

  Widget _singleButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppUiColors.onAccent(color),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _ratingButton(
    String text,
    Color color,
    VoidCallback onPressed,
    bool enabled,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled
                  ? color
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: enabled
                  ? AppUiColors.onAccent(color)
                  : Theme.of(context).disabledColor,
            ),
            onPressed: enabled ? onPressed : null,
            child: Text(text, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Future<void> _submitAnswer(Flashcard card, bool isCorrect) async {
    final settings = await _refreshDeckSettingsFromDb();
    final isar = Isar.getInstance();
    if (settings == null || isar == null) return;
    final now = DateTime.now();
    final studyDurationMs = _currentCardStudyDurationMs(now);
    final studyDay = StudyDay.label(now, settings);
    final prevIndex = currentIndex;
    // Snapshot para Undo antes de mutar
    final undo = _UndoAction(
      prevIndex: prevIndex,
      cardId: card.id,
      snapshot: _FlashcardSnapshot.fromCard(card),
    );

    // Contar nueva SOLO en el primer rating real
    final bool shouldCountNew =
        (card.state == CardState.newCard) && _isEpoch(card.lastReview);
    // Aplicar SRS
    final bool repeatToday = _srsService.reviewCard(card, isCorrect, settings);

    // Marcar lastReview
    card.lastReview = now;
    card.lifetimeReviewCount++;
    card.totalStudyTimeMs += studyDurationMs;
    if (isCorrect) {
      card.lifetimeCorrectCount++;
    } else {
      card.lifetimeWrongCount++;
    }

    int daysInterval = StudyDay.label(
      card.nextReview,
      settings,
    ).difference(studyDay).inDays;
    if (daysInterval < 0) daysInterval = 0;
    int daysLate = studyDay
        .difference(StudyDay.label(undo.snapshot.nextReview, settings))
        .inDays;
    if (daysLate < 0) daysLate = 0;

    final reviewLog = ReviewLog()
      ..packName = card.packName
      ..timestamp = now
      ..studyDay = studyDay
      ..cardOriginalId = '${card.originalId}::${card.cardType}'
      ..flashcardId = card.id
      ..sessionId = _activeSessionId
      ..cardType = card.cardType
      ..isCorrect = isCorrect
      ..previousState = undo.snapshot.state.name
      ..newState = card.state.name
      ..previousNextReview = undo.snapshot.nextReview
      ..newNextReview = card.nextReview
      ..daysLate = daysLate
      ..rating = isCorrect ? 3 : 1
      ..scheduledDays = daysInterval
      ..studyDurationMs = studyDurationMs;

    int? logId;
    int? prevSeen;
    DateTime? prevLastDate;

    await isar.writeTxn(() async {
      if (shouldCountNew) {
        final latest = await isar.deckSettings.get(settings.id);
        if (latest != null) {
          prevSeen = latest.newCardsSeenToday;
          prevLastDate = latest.lastNewCardStudyDate;
          final currentLabel = StudyDay.label(now, latest);
          final last = latest.lastNewCardStudyDate;
          final lastLabel = last == null ? null : StudyDay.label(last, latest);
          final bool sameStudyDay =
              lastLabel != null &&
              lastLabel.year == currentLabel.year &&
              lastLabel.month == currentLabel.month &&
              lastLabel.day == currentLabel.day;
          if (!sameStudyDay) {
            latest.newCardsSeenToday = 0;
          }
          latest.newCardsSeenToday += 1;
          // Guardamos timestamp real; luego se etiqueta con StudyDay.label().
          latest.lastNewCardStudyDate = now;
          await isar.deckSettings.put(latest);
          _currentDeckSettings = latest;
        }
      }
      await isar.flashcards.put(card);
      logId = await isar.reviewLogs.put(reviewLog);
    });

    undo.reviewLogId = logId;
    undo.reviewStudyDay = studyDay;

    if (shouldCountNew && prevSeen != null) {
      undo.didIncrementNewCounter = true;
      undo.prevNewCardsSeenToday = prevSeen!;
      undo.prevLastNewCardStudyDate = prevLastDate;
      undo.deckSettingsId = settings.id;
    }

    if (repeatToday) {
      setState(() => studyQueue.add(card));
      undo.didAppendToQueue = true;
    }

    ref.read(guidedTourProvider.notifier).onStudyRatedCard();

    await syncDeckDailyStatsForPackDay(isar, widget.packName, studyDay);
    await _nextCard();
    await _persistStudySession();

    if (_undoEnabled) {
      setState(() => _lastUndo = undo);
    } else {
      _lastUndo = null;
    }
  }

  Future<void> _performUndo() async {
    final action = _lastUndo;
    final isar = Isar.getInstance();
    if (action == null || isar == null) return;
    if (!_undoEnabled) return;
    // Si se re-encolar por repeatToday, revertir UNA ocurrencia
    if (action.didAppendToQueue) {
      for (int i = studyQueue.length - 1; i >= 0; i--) {
        if (studyQueue[i].id == action.cardId && i != action.prevIndex) {
          studyQueue.removeAt(i);
          break;
        }
      }
    }

    // Encontrar la carta a restaurar (preferir prevIndex)
    Flashcard? target;
    if (action.prevIndex >= 0 && action.prevIndex < studyQueue.length) {
      final c = studyQueue[action.prevIndex];
      if (c.id == action.cardId) target = c;
    }
    target ??= studyQueue
        .where((c) => c.id == action.cardId)
        .cast<Flashcard?>()
        .firstWhere((c) => c != null, orElse: () => null);
    if (target == null) return;
    action.snapshot.applyTo(target);

    await isar.writeTxn(() async {
      await isar.flashcards.put(target!);
      if (action.reviewLogId != null) {
        await isar.reviewLogs.delete(action.reviewLogId!);
      }

      if (action.didIncrementNewCounter && action.deckSettingsId != null) {
        final ds = await isar.deckSettings.get(action.deckSettingsId!);
        if (ds != null) {
          ds.newCardsSeenToday = action.prevNewCardsSeenToday;
          ds.lastNewCardStudyDate = action.prevLastNewCardStudyDate;
          await isar.deckSettings.put(ds);
          _currentDeckSettings = ds;
        }
      }
    });

    if (action.reviewStudyDay != null) {
      await syncDeckDailyStatsForPackDay(
        isar,
        widget.packName,
        action.reviewStudyDay!,
      );
    }

    setState(() {
      currentIndex = action.prevIndex
          .clamp(0, studyQueue.isEmpty ? 0 : studyQueue.length - 1)
          .toInt();
      isAnswerShown = false;
      isReadingShown = false;
      currentWriteScore = 0;
      _lastUndo = null; // solo 1 nivel
    });
    _markCurrentCardShown();

    _recomputeCurrentCardState(reloadHtml: true);
    await _persistStudySession();
  }

  Future<void> _nextCard() async {
    if (currentIndex < studyQueue.length - 1) {
      setState(() {
        currentIndex++;
        isAnswerShown = false;
        isReadingShown = false;
        currentWriteScore = 0;
      });
      _markCurrentCardShown();
      _recomputeCurrentCardState(reloadHtml: true);
    } else {
      setState(() {
        currentIndex++;
        _cardShownAt = null;
      });
      ref.read(guidedTourProvider.notifier).onStudyQueueFinished();
      await _completeSessionIfNeeded();
    }
  }

  Future<void> _completeSessionIfNeeded() async {
    if (_sessionCleared) return;
    _sessionCleared = true;
    await _storeSessionHistoryIfNeeded();
    await _clearStudySession();
  }

  Future<void> _storeSessionHistoryIfNeeded() async {
    final isar = Isar.getInstance();
    if (isar == null || _activeSessionId.isEmpty) return;

    final existing = await isar.studySessionHistorys
        .filter()
        .sessionIdEqualTo(_activeSessionId)
        .findFirst();
    if (existing != null) return;

    final logs = await isar.reviewLogs
        .filter()
        .sessionIdEqualTo(_activeSessionId)
        .sortByTimestamp()
        .findAll();
    if (logs.isEmpty) return;

    final answerCount = logs.length;
    final correctCount = logs
        .where((log) => log.isCorrect || log.rating >= 3)
        .length;
    final totalStudyTimeMs = logs.fold<int>(
      0,
      (sum, log) => sum + log.studyDurationMs,
    );
    final uniqueCards = <String>{};
    for (final log in logs) {
      uniqueCards.add(log.cardOriginalId);
    }

    final history = StudySessionHistory()
      ..sessionId = _activeSessionId
      ..packName = widget.packName
      ..sessionDay = logs.last.studyDay
      ..startedAt = _sessionStartedAt
      ..endedAt = logs.last.timestamp
      ..answerCount = answerCount
      ..correctCount = correctCount
      ..wrongCount = answerCount - correctCount
      ..uniqueCardCount = uniqueCards.length
      ..totalStudyTimeMs = totalStudyTimeMs
      ..averageAnswerTimeMs = answerCount == 0
          ? 0
          : (totalStudyTimeMs / answerCount).round();

    await isar.writeTxn(() async {
      await isar.studySessionHistorys.put(history);
    });
    await syncDeckDailyStatsForPackDay(
      isar,
      widget.packName,
      history.sessionDay,
    );
  }

  Future<void> _persistStudySession() async {
    if (_isFinished) {
      await _completeSessionIfNeeded();
      return;
    }
    final isar = Isar.getInstance();
    if (isar == null) return;
    final now = DateTime.now();
    final day = _currentDeckSettings != null
        ? StudyDay.label(now, _currentDeckSettings!)
        : DateTime(now.year, now.month, now.day);
    await isar.writeTxn(() async {
      var session = await isar.studySessions
          .filter()
          .packNameEqualTo(widget.packName)
          .findFirst();

      session ??= StudySession()..packName = widget.packName;
      session
        ..packName = widget.packName
        ..sessionId = _activeSessionId
        ..queueCardIds = studyQueue.map((c) => c.id).toList()
        ..currentIndex = currentIndex
        ..sessionDay = day
        ..startedAt = _sessionStartedAt
        ..lastUpdated = now;
      await isar.studySessions.put(session);
    });
  }

  Future<void> _clearStudySession() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    await isar.writeTxn(() async {
      await isar.studySessions
          .filter()
          .packNameEqualTo(widget.packName)
          .deleteAll();
    });
  }
}

class _FlashcardSnapshot {
  final DateTime nextReview;
  final DateTime lastReview;
  final double decayRate;
  final List<double> fixedPhaseQueue;
  final int learningStep;
  final int consecutiveLapses;
  final int repetitionCount;
  final int lifetimeReviewCount;
  final int lifetimeCorrectCount;
  final int lifetimeWrongCount;
  final int totalStudyTimeMs;
  final CardState state;

  _FlashcardSnapshot({
    required this.nextReview,
    required this.lastReview,
    required this.decayRate,
    required this.fixedPhaseQueue,
    required this.learningStep,
    required this.consecutiveLapses,
    required this.repetitionCount,
    required this.lifetimeReviewCount,
    required this.lifetimeCorrectCount,
    required this.lifetimeWrongCount,
    required this.totalStudyTimeMs,
    required this.state,
  });

  factory _FlashcardSnapshot.fromCard(Flashcard c) {
    return _FlashcardSnapshot(
      nextReview: c.nextReview,
      lastReview: c.lastReview,
      decayRate: c.decayRate,
      fixedPhaseQueue: List<double>.from(c.fixedPhaseQueue),
      learningStep: c.learningStep,
      consecutiveLapses: c.consecutiveLapses,
      repetitionCount: c.repetitionCount,
      lifetimeReviewCount: c.lifetimeReviewCount,
      lifetimeCorrectCount: c.lifetimeCorrectCount,
      lifetimeWrongCount: c.lifetimeWrongCount,
      totalStudyTimeMs: c.totalStudyTimeMs,
      state: c.state,
    );
  }

  void applyTo(Flashcard c) {
    c.nextReview = nextReview;
    c.lastReview = lastReview;
    c.decayRate = decayRate;
    c.fixedPhaseQueue = List<double>.from(fixedPhaseQueue);
    c.learningStep = learningStep;
    c.consecutiveLapses = consecutiveLapses;
    c.repetitionCount = repetitionCount;
    c.lifetimeReviewCount = lifetimeReviewCount;
    c.lifetimeCorrectCount = lifetimeCorrectCount;
    c.lifetimeWrongCount = lifetimeWrongCount;
    c.totalStudyTimeMs = totalStudyTimeMs;
    c.state = state;
  }
}

class _UndoAction {
  final int prevIndex;
  final int cardId;
  final _FlashcardSnapshot snapshot;

  int? reviewLogId;
  bool didAppendToQueue = false;
  bool didIncrementNewCounter = false;
  int? deckSettingsId;
  late int prevNewCardsSeenToday;
  DateTime? prevLastNewCardStudyDate;
  DateTime? reviewStudyDay;

  _UndoAction({
    required this.prevIndex,
    required this.cardId,
    required this.snapshot,
  });
}

class _WriteModeCardData {
  final List<String> prompts;
  final List<String> targets;

  const _WriteModeCardData({required this.prompts, required this.targets});
}

class _WriteDiffResult {
  final String html;
  final int percent;

  const _WriteDiffResult({required this.html, required this.percent});
}

class _WriteModeEvaluation {
  final int score;
  final String resultHtml;
  final String userRawHtml;

  const _WriteModeEvaluation({
    required this.score,
    required this.resultHtml,
    required this.userRawHtml,
  });
}

class _StudyWritePalette {
  final Color card;
  final Color panel;
  final Color text;
  final Color soft;
  final Color accent;
  final Color accentDark;
  final Color line;
  final Color shadow;

  const _StudyWritePalette({
    required this.card,
    required this.panel,
    required this.text,
    required this.soft,
    required this.accent,
    required this.accentDark,
    required this.line,
    required this.shadow,
  });

  factory _StudyWritePalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return _StudyWritePalette(
      card: scheme.surface,
      panel: AppUiColors.lavender(
        context,
      ).withValues(alpha: isDark ? 0.16 : 0.12),
      text: AppUiColors.studyText(context),
      soft: AppUiColors.mutedText(context),
      accent: AppUiColors.studyWord(context),
      accentDark: AppUiColors.lavender(context),
      line: AppUiColors.studyLine(context),
      shadow: isDark
          ? Colors.black.withValues(alpha: 0.32)
          : AppUiColors.lavender(context).withValues(alpha: 0.18),
    );
  }
}
