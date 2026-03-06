import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:isar/isar.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/study_session/html_generator.dart';
import 'package:flashcards_app/features/study_session/srs_service.dart';

class StudyPage extends StatefulWidget {
  final String packName;
  final List<Flashcard> cards;
  final int initialIndex;
  const StudyPage({
    super.key,
    required this.packName,
    required this.cards,
    this.initialIndex = 0,
  });
  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
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
  @override
  void initState() {
    super.initState();
    studyQueue = List.from(widget.cards);
    currentIndex = widget.initialIndex
        .clamp(0, studyQueue.isEmpty ? 0 : studyQueue.length - 1)
        .toInt();
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
    super.dispose();
  }

  bool get _isFinished => currentIndex >= studyQueue.length;
  bool get _undoEnabled => _currentDeckSettings?.enableUndo ?? true;

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
      data: HtmlGenerator.generateContent(card, writeMode: isWriteModeActive),
    );
  }

  Color _cardTypeColor(Flashcard card) {
    if (card.state == CardState.newCard) return Colors.blue;
    if (card.state == CardState.learning && card.learningStep == 0)
      return Colors.orange;
    return Colors.green;
  }

  bool _isEpoch(DateTime dt) => dt.millisecondsSinceEpoch == 0;

  void _recomputeCurrentCardState({bool reloadHtml = false}) {
    if (_isFinished) return;
    final card = studyQueue[currentIndex];
    Map<String, dynamic> extra = {};
    if (card.extraDataJson != null && card.extraDataJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(card.extraDataJson!);
        if (decoded is Map<String, dynamic>) {
          extra = decoded;
        } else if (decoded is Map) {
          extra = decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }

    final readingVal = extra['reading'];
    final readingStr = (readingVal is String) ? readingVal.trim() : '';
    final bool isRecog = card.cardType.endsWith('recog');
    final bool hasReading =
        readingStr.isNotEmpty && readingStr != card.question.trim();
    final bool writeEnabled = _currentDeckSettings?.enableWriteMode ?? false;
    final bool isProd = card.cardType.endsWith('prod');
    final int maxReps = _currentDeckSettings?.writeModeMaxReps ?? 0;
    final bool withinMax = (maxReps <= 0) || (card.repetitionCount < maxReps);
    final bool writeActive = writeEnabled && isProd && withinMax;

    setState(() {
      isComplexCard = isRecog && hasReading;
      isWriteModeActive = writeActive;
      minScoreRequired = writeActive
          ? (_currentDeckSettings?.writeModeThreshold ?? 80)
          : 0;
      currentWriteScore = 0;
    });

    if (reloadHtml) _reloadCurrentHtml();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFinished) {
          await _completeSessionIfNeeded();
        } else {
          await _persistStudySession();
        }
        return true;
      },
      child: _isFinished ? _buildFinished() : _buildStudy(),
    );
  }

  Widget _buildFinished() {
    return Scaffold(
      appBar: AppBar(title: const Text("Sesion Finalizada")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              "Has terminado por ahora!",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudy() {
    final card = studyQueue[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("Estudiando (${currentIndex + 1}/${studyQueue.length})"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _cardTypeColor(card)),
        ),
        actions: [
          if (_undoEnabled && _lastUndo != null)
            IconButton(
              tooltip: "Deshacer ultimo (Undo)",
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
                  writeMode: isWriteModeActive,
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
          _buildControls(card),
        ],
      ),
    );
  }

  Widget _buildControls(Flashcard card) {
    if (!isAnswerShown) {
      if (isComplexCard && !isReadingShown) {
        return _singleButton(
          label: "Mostrar Lectura / Notas",
          color: Colors.orange,
          onPressed: () {
            setState(() => isReadingShown = true);
            webViewController?.evaluateJavascript(source: "showReading()");
            _persistStudySession();
          },
        );
      }

      return _singleButton(
        label: "Mostrar Respuesta",
        color: Colors.blue,
        onPressed: () {
          setState(() => isAnswerShown = true);
          webViewController?.evaluateJavascript(source: "showAnswer()");
          _persistStudySession();
        },
      );
    }

    if (isComplexCard && !isReadingShown) {
      return _singleButton(
        label: "Mostrar Lectura / Notas",
        color: Colors.orange,
        onPressed: () {
          setState(() => isReadingShown = true);
          webViewController?.evaluateJavascript(source: "showReading()");
          _persistStudySession();
        },
      );
    }

    final bool writePassed =
        !isWriteModeActive || (currentWriteScore >= minScoreRequired);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _ratingButton(
            "Mal",
            Colors.red,
            () => _submitAnswer(card, false),
            true,
          ),
          _ratingButton(
            "Bien",
            Colors.green,
            () => _submitAnswer(card, true),
            writePassed,
          ),
        ],
      ),
    );
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
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
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
              backgroundColor: enabled ? color : Colors.grey.shade300,
              foregroundColor: enabled ? Colors.white : Colors.grey,
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

    int daysInterval = card.nextReview.difference(now).inDays;
    if (daysInterval < 0) daysInterval = 0;

    final reviewLog = ReviewLog()
      ..packName = card.packName
      ..timestamp = now
      ..cardOriginalId = '${card.originalId}::${card.cardType}'
      ..rating = isCorrect ? 3 : 1
      ..scheduledDays = daysInterval;

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

    setState(() {
      currentIndex = action.prevIndex
          .clamp(0, studyQueue.isEmpty ? 0 : studyQueue.length - 1)
          .toInt();
      isAnswerShown = false;
      isReadingShown = false;
      currentWriteScore = 0;
      _lastUndo = null; // solo 1 nivel
    });

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
      _recomputeCurrentCardState(reloadHtml: true);
    } else {
      setState(() => currentIndex++);
      await _completeSessionIfNeeded();
    }
  }

  Future<void> _completeSessionIfNeeded() async {
    if (_sessionCleared) return;
    _sessionCleared = true;
    await _clearStudySession();
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
        ..queueCardIds = studyQueue.map((c) => c.id).toList()
        ..currentIndex = currentIndex
        ..sessionDay = day
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
  final CardState state;

  _FlashcardSnapshot({
    required this.nextReview,
    required this.lastReview,
    required this.decayRate,
    required this.fixedPhaseQueue,
    required this.learningStep,
    required this.consecutiveLapses,
    required this.repetitionCount,
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

  _UndoAction({
    required this.prevIndex,
    required this.cardId,
    required this.snapshot,
  });
}
