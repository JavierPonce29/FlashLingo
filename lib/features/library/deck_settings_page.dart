import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/library/deck_settings_validation.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class DeckSettingsPage extends ConsumerStatefulWidget {
  final String packName;

  const DeckSettingsPage({super.key, required this.packName});

  @override
  ConsumerState<DeckSettingsPage> createState() => _DeckSettingsPageState();
}

class _DeckSettingsPageState extends ConsumerState<DeckSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dailySectionKey = GlobalKey();
  final GlobalKey _mixSectionKey = GlobalKey();
  final GlobalKey _writeSectionKey = GlobalKey();
  final GlobalKey _lapseSectionKey = GlobalKey();
  final GlobalKey _saveSectionKey = GlobalKey();
  GuidedTourStep? _lastSyncedTourStep;

  late final TextEditingController _newCardsLimitController;
  late final TextEditingController _reviewsLimitController;
  late final TextEditingController _pMinController;
  late final TextEditingController _alphaController;
  late final TextEditingController _betaController;
  late final TextEditingController _offsetController;
  late final TextEditingController _initialNtController;
  late final TextEditingController _learningStepsController;
  late final TextEditingController _newMinCorrectRepsController;
  late final TextEditingController _newIntraDayMinutesController;
  late final TextEditingController _lapseToleranceController;
  late final TextEditingController _lapseFixedIntervalController;
  late final TextEditingController _writeThresholdController;
  late final TextEditingController _writeMaxRepsController;
  late final TextEditingController _interleaveReviewsCountController;
  late final TextEditingController _interleaveNewCardsCountController;

  bool _useFixedIntervalOnLapse = true;
  bool _enableWriteMode = false;
  bool _enableUndo = true;
  String _studyMixMode = DeckStudyMixMode.reviewsFirst;
  int _dayCutoffHour = 4;
  int _dayCutoffMinute = 0;
  bool _isLoading = true;

  bool get _isInterleaveMode =>
      _studyMixMode == DeckStudyMixMode.interleaveReviewsThenNew ||
      _studyMixMode == DeckStudyMixMode.interleaveNewThenReviews;

  @override
  void initState() {
    super.initState();
    _newCardsLimitController = TextEditingController();
    _reviewsLimitController = TextEditingController();
    _pMinController = TextEditingController();
    _alphaController = TextEditingController();
    _betaController = TextEditingController();
    _offsetController = TextEditingController();
    _initialNtController = TextEditingController();
    _learningStepsController = TextEditingController();
    _newMinCorrectRepsController = TextEditingController();
    _newIntraDayMinutesController = TextEditingController();
    _lapseToleranceController = TextEditingController();
    _lapseFixedIntervalController = TextEditingController();
    _writeThresholdController = TextEditingController();
    _writeMaxRepsController = TextEditingController();
    _interleaveReviewsCountController = TextEditingController();
    _interleaveNewCardsCountController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newCardsLimitController.dispose();
    _reviewsLimitController.dispose();
    _pMinController.dispose();
    _alphaController.dispose();
    _betaController.dispose();
    _offsetController.dispose();
    _initialNtController.dispose();
    _learningStepsController.dispose();
    _newMinCorrectRepsController.dispose();
    _newIntraDayMinutesController.dispose();
    _lapseToleranceController.dispose();
    _lapseFixedIntervalController.dispose();
    _writeThresholdController.dispose();
    _writeMaxRepsController.dispose();
    _interleaveReviewsCountController.dispose();
    _interleaveNewCardsCountController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final isar = await ref.read(isarDbProvider.future);
    var settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(widget.packName)
        .findFirst();
    if (settings == null) {
      settings = DeckSettings()..packName = widget.packName;
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    _dayCutoffHour = (settings.dayCutoffHour ?? 4).clamp(0, 23);
    _dayCutoffMinute = (settings.dayCutoffMinute ?? 0).clamp(0, 59);
    _newCardsLimitController.text = settings.newCardsPerDay.toString();
    _reviewsLimitController.text = settings.maxReviewsPerDay.toString();
    _pMinController.text = settings.pMin.toString();
    _alphaController.text = settings.alpha.toString();
    _betaController.text = settings.beta.toString();
    _offsetController.text = settings.offset.toString();
    _initialNtController.text = settings.initialNt.toString();
    _learningStepsController.text = settings.learningSteps.join(', ');
    _newMinCorrectRepsController.text = settings.newCardMinCorrectReps
        .toString();
    _newIntraDayMinutesController.text = settings.newCardIntraDayMinutes
        .toString();
    _lapseToleranceController.text = settings.lapseTolerance.toString();
    _lapseFixedIntervalController.text = settings.lapseFixedInterval.toString();
    _enableWriteMode = settings.enableWriteMode;
    _writeThresholdController.text = settings.writeModeThreshold.toString();
    _writeMaxRepsController.text = settings.writeModeMaxReps.toString();
    _useFixedIntervalOnLapse = settings.useFixedIntervalOnLapse;
    _enableUndo = settings.enableUndo;
    _studyMixMode = DeckStudyMixMode.values.contains(settings.studyMixMode)
        ? settings.studyMixMode
        : DeckStudyMixMode.reviewsFirst;
    _interleaveReviewsCountController.text = settings.interleaveReviewsCount
        .toString();
    _interleaveNewCardsCountController.text = settings.interleaveNewCardsCount
        .toString();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isar = await ref.read(isarDbProvider.future);
    final newLimit = int.parse(_newCardsLimitController.text.trim());
    final revLimit = int.parse(_reviewsLimitController.text.trim());
    final tolerance = int.parse(_lapseToleranceController.text.trim());
    final lapseDays = _useFixedIntervalOnLapse
        ? double.parse(
            _lapseFixedIntervalController.text.trim().replaceAll(',', '.'),
          )
        : 1.0;
    final pMin = double.parse(_pMinController.text.trim().replaceAll(',', '.'));
    final alpha = double.parse(
      _alphaController.text.trim().replaceAll(',', '.'),
    );
    final beta = double.parse(_betaController.text.trim().replaceAll(',', '.'));
    final offset = double.parse(
      _offsetController.text.trim().replaceAll(',', '.'),
    );
    final initialNt = double.parse(
      _initialNtController.text.trim().replaceAll(',', '.'),
    );
    final learningSteps = parseLearningSteps(_learningStepsController.text)!;
    final newMinReps = int.parse(_newMinCorrectRepsController.text.trim());
    final newMinutes = int.parse(_newIntraDayMinutesController.text.trim());
    final writeThreshold = _enableWriteMode
        ? int.parse(_writeThresholdController.text.trim())
        : 80;
    final writeReps = _enableWriteMode
        ? int.parse(_writeMaxRepsController.text.trim())
        : 0;
    final interleaveReviewsCount = int.parse(
      _interleaveReviewsCountController.text.trim(),
    );
    final interleaveNewCount = int.parse(
      _interleaveNewCardsCountController.text.trim(),
    );
    final newCutoffHour = _dayCutoffHour.clamp(0, 23);
    final newCutoffMinute = _dayCutoffMinute.clamp(0, 59);

    try {
      await isar.writeTxn(() async {
        final existing = await isar.deckSettings
            .filter()
            .packNameEqualTo(widget.packName)
            .findFirst();

        final settingsToSave =
            existing ?? (DeckSettings()..packName = widget.packName);

        settingsToSave
          ..packName = widget.packName
          ..newCardsPerDay = newLimit
          ..maxReviewsPerDay = revLimit
          ..dayCutoffHour = newCutoffHour
          ..dayCutoffMinute = newCutoffMinute
          ..lapseTolerance = tolerance
          ..useFixedIntervalOnLapse = _useFixedIntervalOnLapse
          ..lapseFixedInterval = lapseDays
          ..pMin = pMin
          ..alpha = alpha
          ..beta = beta
          ..offset = offset
          ..initialNt = initialNt
          ..learningSteps = learningSteps
          ..newCardMinCorrectReps = newMinReps
          ..newCardIntraDayMinutes = newMinutes
          ..enableWriteMode = _enableWriteMode
          ..writeModeThreshold = writeThreshold
          ..writeModeMaxReps = writeReps
          ..enableUndo = _enableUndo
          ..studyMixMode = _studyMixMode
          ..interleaveReviewsCount = interleaveReviewsCount
          ..interleaveNewCardsCount = interleaveNewCount;

        await isar.deckSettings.put(settingsToSave);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.tr('deck_settings_saved')),
          backgroundColor: AppUiColors.success(context),
        ),
      );
      ref.read(guidedTourProvider.notifier).onDeckSettingsSavedAndClosed();
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.tr('deck_settings_save_error')),
          backgroundColor: AppUiColors.danger(context),
        ),
      );
    }
  }

  String? _validateInt(
    String? value, {
    required String label,
    int? min,
    int? max,
  }) {
    final l10n = context.l10n;
    final text = (value ?? '').trim();
    if (text.isEmpty) return l10n.tr('common_required');
    final parsed = int.tryParse(text);
    if (parsed == null) return l10n.tr('common_invalid_number');
    if (min != null && parsed < min) {
      return l10n.tr(
        'validation_min_int',
        params: <String, Object?>{'label': label, 'value': min},
      );
    }
    if (max != null && parsed > max) {
      return l10n.tr(
        'validation_max_int',
        params: <String, Object?>{'label': label, 'value': max},
      );
    }
    return null;
  }

  String? _validateDouble(
    String? value, {
    required String label,
    double? min,
    double? max,
  }) {
    final l10n = context.l10n;
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return l10n.tr('common_required');
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return l10n.tr('common_invalid_number');
    if (min != null && parsed < min) {
      return l10n.tr(
        'validation_min_double',
        params: <String, Object?>{'label': label, 'value': min},
      );
    }
    if (max != null && parsed > max) {
      return l10n.tr(
        'validation_max_double',
        params: <String, Object?>{'label': label, 'value': max},
      );
    }
    return null;
  }

  String? _validateLearningSteps(String? value) {
    return validateLearningStepsInput(context.l10n, value);
  }

  String? _validateInterleaveCount(String? value, {required String label}) {
    if (!_isInterleaveMode) return null;
    return _validateInt(value, label: label, min: 1, max: 9999);
  }

  String _mixModeLabel(AppLocalizations l10n, String mode) {
    switch (mode) {
      case DeckStudyMixMode.newFirst:
        return l10n.tr('deck_settings_mix_new_first');
      case DeckStudyMixMode.reviewsFirst:
        return l10n.tr('deck_settings_mix_reviews_first');
      case DeckStudyMixMode.interleaveReviewsThenNew:
        return l10n.tr('deck_settings_mix_interleave_reviews_new');
      case DeckStudyMixMode.interleaveNewThenReviews:
        return l10n.tr('deck_settings_mix_interleave_new_reviews');
      default:
        return mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mixModes = DeckStudyMixMode.values.toList(growable: false);
    final guidedTourState = ref.watch(guidedTourProvider);
    final tourStep = guidedTourState.step;
    final isTourInDeckSettings = tourStep.isDeckSettingsStep;
    final canPop =
        !isTourInDeckSettings || tourStep == GuidedTourStep.deckSettingsExit;
    final canSave =
        !_isLoading &&
        (!isTourInDeckSettings || tourStep == GuidedTourStep.deckSettingsExit);
    final highlightDaily =
        tourStep == GuidedTourStep.deckSettingsIntro ||
        tourStep == GuidedTourStep.deckSettingsDaily;
    final highlightMix = tourStep == GuidedTourStep.deckSettingsMix;
    final highlightWrite =
        tourStep == GuidedTourStep.deckSettingsWriteToggleOn ||
        tourStep == GuidedTourStep.deckSettingsWriteOptions ||
        tourStep == GuidedTourStep.deckSettingsWriteToggleOff;
    final highlightLapse =
        tourStep == GuidedTourStep.deckSettingsLapseToggleOn ||
        tourStep == GuidedTourStep.deckSettingsLapseOptions ||
        tourStep == GuidedTourStep.deckSettingsLapseToggleOff;
    final highlightSave = tourStep == GuidedTourStep.deckSettingsExit;

    if (_lastSyncedTourStep != tourStep) {
      _lastSyncedTourStep = tourStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncTourViewport(tourStep);
      });
    }

    if (tourStep == GuidedTourStep.deckSettingsWriteToggleOn &&
        _enableWriteMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(guidedTourProvider.notifier).onWriteModeChanged(true);
      });
    }
    if (tourStep == GuidedTourStep.deckSettingsLapseToggleOn &&
        _useFixedIntervalOnLapse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(guidedTourProvider.notifier).onLapseFixedChanged(true);
      });
    }

    final page = Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr(
            'deck_settings_title',
            params: <String, Object?>{'packName': widget.packName},
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: canSave ? _saveSettings : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TourHighlight(
                      key: _dailySectionKey,
                      highlighted: highlightDaily,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            l10n.tr('deck_settings_daily_limits'),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _newCardsLimitController,
                                  label: l10n.tr('deck_settings_new_per_day'),
                                  inputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) => _validateInt(
                                    v,
                                    label: l10n.tr('deck_settings_new_per_day'),
                                    min: 0,
                                    max: 10000,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildTextField(
                                  controller: _reviewsLimitController,
                                  label: l10n.tr(
                                    'deck_settings_reviews_per_day',
                                  ),
                                  inputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) => _validateInt(
                                    v,
                                    label: l10n.tr(
                                      'deck_settings_reviews_per_day',
                                    ),
                                    min: 0,
                                    max: 100000,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle(
                            l10n.tr('deck_settings_day_cutoff'),
                            color: AppUiColors.secondary(context),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppUiColors.panelFill(
                                context,
                                AppUiColors.secondary(context),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppUiColors.panelBorder(
                                  context,
                                  AppUiColors.secondary(context),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.tr('deck_settings_day_cutoff_help'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppUiColors.mutedText(context),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        initialValue: _dayCutoffHour,
                                        decoration: InputDecoration(
                                          labelText: l10n.tr(
                                            'deck_settings_hour',
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                        items: List.generate(
                                          24,
                                          (h) => DropdownMenuItem(
                                            value: h,
                                            child: Text(
                                              h.toString().padLeft(2, '0'),
                                            ),
                                          ),
                                        ),
                                        onChanged: (v) => setState(
                                          () => _dayCutoffHour = v ?? 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        initialValue: _dayCutoffMinute,
                                        decoration: InputDecoration(
                                          labelText: l10n.tr(
                                            'deck_settings_minute',
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                        items: List.generate(
                                          60,
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(
                                              m.toString().padLeft(2, '0'),
                                            ),
                                          ),
                                        ),
                                        onChanged: (v) => setState(
                                          () => _dayCutoffMinute = v ?? 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.tr(
                                    'deck_settings_cutoff_now',
                                    params: <String, Object?>{
                                      'time':
                                          '${_dayCutoffHour.toString().padLeft(2, '0')}:${_dayCutoffMinute.toString().padLeft(2, '0')}',
                                    },
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TourHighlight(
                      key: _mixSectionKey,
                      highlighted: highlightMix,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            l10n.tr('deck_settings_mix_section'),
                            color: AppUiColors.mint(context),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppUiColors.panelFill(
                                context,
                                AppUiColors.mint(context),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppUiColors.panelBorder(
                                  context,
                                  AppUiColors.mint(context),
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: _studyMixMode,
                                  decoration: InputDecoration(
                                    labelText: l10n.tr(
                                      'deck_settings_mix_mode',
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  selectedItemBuilder: (_) => mixModes
                                      .map(
                                        (mode) => Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _mixModeLabel(l10n, mode),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  items: mixModes
                                      .map(
                                        (mode) => DropdownMenuItem<String>(
                                          value: mode,
                                          child: Text(
                                            _mixModeLabel(l10n, mode),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _studyMixMode = value);
                                  },
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.tr('deck_settings_mix_hint'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppUiColors.mutedText(context),
                                    ),
                                  ),
                                ),
                                if (_isInterleaveMode) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller:
                                              _interleaveReviewsCountController,
                                          label: l10n.tr(
                                            'deck_settings_reviews_block',
                                          ),
                                          hint: '2',
                                          inputType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (v) =>
                                              _validateInterleaveCount(
                                                v,
                                                label: l10n.tr(
                                                  'deck_settings_reviews_block',
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller:
                                              _interleaveNewCardsCountController,
                                          label: l10n.tr(
                                            'deck_settings_new_block',
                                          ),
                                          hint: '1',
                                          inputType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (v) =>
                                              _validateInterleaveCount(
                                                v,
                                                label: l10n.tr(
                                                  'deck_settings_new_block',
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TourHighlight(
                      key: _writeSectionKey,
                      highlighted: highlightWrite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            l10n.tr('deck_settings_write_mode'),
                            color: AppUiColors.lavender(context),
                          ),
                          _buildWriteModeSection(context, l10n),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      l10n.tr('deck_settings_undo_section'),
                      color: AppUiColors.peach(context),
                    ),
                    _buildUndoSection(context, l10n),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      l10n.tr('deck_settings_learning_section'),
                    ),
                    _buildLearningSection(l10n),
                    const SizedBox(height: 20),
                    _buildSectionTitle(l10n.tr('deck_settings_algorithm')),
                    _buildAlgorithmSection(l10n),
                    const SizedBox(height: 20),
                    TourHighlight(
                      key: _lapseSectionKey,
                      highlighted: highlightLapse,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(l10n.tr('deck_settings_lapses')),
                          _buildLapseSection(l10n),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TourHighlight(
                      key: _saveSectionKey,
                      highlighted: highlightSave,
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: Text(l10n.tr('common_save')),
                          onPressed: canSave ? _saveSettings : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );

    if (!isTourInDeckSettings) return page;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tr('onboarding_tour_deck_settings_blocked')),
          ),
        );
      },
      child: Stack(
        children: [
          page,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: AppUiColors.scrim(context)),
            ),
          ),
          TourOverlayCard(
            targetKey: _targetKeyForStep(tourStep),
            message: _tourDeckSettingsMessage(l10n, tourStep),
            actionLabel: _canAdvanceDeckSettingsStep(tourStep)
                ? l10n.tr('onboarding_tour_next')
                : null,
            onActionPressed: _canAdvanceDeckSettingsStep(tourStep)
                ? () =>
                      ref.read(guidedTourProvider.notifier).nextInDeckSettings()
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _syncTourViewport(GuidedTourStep step) async {
    final targetKey = _targetKeyForStep(step);
    if (targetKey == null) return;
    final alignment = step == GuidedTourStep.deckSettingsExit ? 0.92 : 0.18;
    await ensureTourTargetVisible(targetKey, alignment: alignment);
  }

  bool _canAdvanceDeckSettingsStep(GuidedTourStep step) {
    return step == GuidedTourStep.deckSettingsIntro ||
        step == GuidedTourStep.deckSettingsDaily ||
        step == GuidedTourStep.deckSettingsMix ||
        step == GuidedTourStep.deckSettingsWriteOptions ||
        step == GuidedTourStep.deckSettingsLapseOptions;
  }

  String _tourDeckSettingsMessage(AppLocalizations l10n, GuidedTourStep step) {
    switch (step) {
      case GuidedTourStep.deckSettingsIntro:
        return l10n.tr('onboarding_tour_deck_settings_intro');
      case GuidedTourStep.deckSettingsDaily:
        return l10n.tr('onboarding_tour_deck_settings_daily');
      case GuidedTourStep.deckSettingsMix:
        return l10n.tr('onboarding_tour_deck_settings_mix');
      case GuidedTourStep.deckSettingsWriteToggleOn:
        return l10n.tr('onboarding_tour_deck_settings_write_on');
      case GuidedTourStep.deckSettingsWriteOptions:
        return l10n.tr('onboarding_tour_deck_settings_write_options');
      case GuidedTourStep.deckSettingsWriteToggleOff:
        return l10n.tr('onboarding_tour_deck_settings_write_off');
      case GuidedTourStep.deckSettingsLapseToggleOn:
        return l10n.tr('onboarding_tour_deck_settings_lapse_on');
      case GuidedTourStep.deckSettingsLapseOptions:
        return l10n.tr('onboarding_tour_deck_settings_lapse_options');
      case GuidedTourStep.deckSettingsLapseToggleOff:
        return l10n.tr('onboarding_tour_deck_settings_lapse_off');
      case GuidedTourStep.deckSettingsExit:
        return l10n.tr('onboarding_tour_deck_settings_exit');
      default:
        return '';
    }
  }

  GlobalKey? _targetKeyForStep(GuidedTourStep step) {
    return switch (step) {
      GuidedTourStep.deckSettingsIntro ||
      GuidedTourStep.deckSettingsDaily => _dailySectionKey,
      GuidedTourStep.deckSettingsMix => _mixSectionKey,
      GuidedTourStep.deckSettingsWriteToggleOn ||
      GuidedTourStep.deckSettingsWriteOptions ||
      GuidedTourStep.deckSettingsWriteToggleOff => _writeSectionKey,
      GuidedTourStep.deckSettingsLapseToggleOn ||
      GuidedTourStep.deckSettingsLapseOptions ||
      GuidedTourStep.deckSettingsLapseToggleOff => _lapseSectionKey,
      GuidedTourStep.deckSettingsExit => _saveSectionKey,
      _ => null,
    };
  }

  Widget _buildWriteModeSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppUiColors.panelFill(
          context,
          Theme.of(context).colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppUiColors.panelBorder(
            context,
            Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.tr('deck_settings_enable_write'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(l10n.tr('deck_settings_enable_write_hint')),
            value: _enableWriteMode,
            activeThumbColor: Theme.of(context).colorScheme.tertiary,
            onChanged: (val) {
              setState(() => _enableWriteMode = val);
              ref.read(guidedTourProvider.notifier).onWriteModeChanged(val);
            },
          ),
          if (_enableWriteMode) ...[
            const SizedBox(height: 10),
            _buildTextField(
              controller: _writeThresholdController,
              label: l10n.tr('deck_settings_min_accuracy'),
              helper: l10n.tr('deck_settings_min_accuracy_hint'),
              inputType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => _validateInt(
                v,
                label: l10n.tr('deck_settings_min_accuracy'),
                min: 0,
                max: 100,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _writeMaxRepsController,
              label: l10n.tr('deck_settings_write_limit'),
              helper: l10n.tr('deck_settings_write_limit_hint'),
              inputType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => _validateInt(
                v,
                label: l10n.tr('deck_settings_write_limit'),
                min: 0,
                max: 1000000,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUndoSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppUiColors.panelFill(context, AppUiColors.peach(context)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppUiColors.panelBorder(context, AppUiColors.peach(context)),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          l10n.tr('deck_settings_enable_undo'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(l10n.tr('deck_settings_enable_undo_hint')),
        value: _enableUndo,
        onChanged: (val) => setState(() => _enableUndo = val),
      ),
    );
  }

  Widget _buildLearningSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _learningStepsController,
          label: l10n.tr('deck_settings_steps'),
          helper: l10n.tr('deck_settings_steps_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateLearningSteps,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            l10n.tr('deck_settings_new_first_day'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppUiColors.mutedText(context),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _newMinCorrectRepsController,
                label: l10n.tr('deck_settings_min_correct'),
                helper: l10n.tr('deck_settings_min_correct_hint'),
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _validateInt(
                  v,
                  label: l10n.tr('deck_settings_min_correct'),
                  min: 1,
                  max: 20,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(
                controller: _newIntraDayMinutesController,
                label: l10n.tr('deck_settings_intra_minutes'),
                helper: l10n.tr('deck_settings_intra_minutes_hint'),
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _validateInt(
                  v,
                  label: l10n.tr('deck_settings_intra_minutes'),
                  min: 1,
                  max: 1440,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlgorithmSection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildTextField(
          controller: _pMinController,
          label: l10n.tr('deck_settings_p_min'),
          helper: l10n.tr('deck_settings_p_min_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => _validateDouble(
            v,
            label: l10n.tr('deck_settings_p_min'),
            min: 0.000001,
            max: 0.999999,
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _alphaController,
          label: l10n.tr('deck_settings_alpha'),
          helper: l10n.tr('deck_settings_alpha_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              _validateDouble(v, label: l10n.tr('deck_settings_alpha'), min: 0),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _betaController,
          label: l10n.tr('deck_settings_beta'),
          helper: l10n.tr('deck_settings_beta_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              _validateDouble(v, label: l10n.tr('deck_settings_beta'), min: 0),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _offsetController,
          label: l10n.tr('deck_settings_offset'),
          helper: l10n.tr('deck_settings_offset_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              _validateDouble(v, label: l10n.tr('deck_settings_offset')),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _initialNtController,
          label: l10n.tr('deck_settings_initial_nt'),
          helper: l10n.tr('deck_settings_initial_nt_hint'),
          inputType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => _validateDouble(
            v,
            label: l10n.tr('deck_settings_initial_nt'),
            min: 0.000001,
          ),
        ),
      ],
    );
  }

  Widget _buildLapseSection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildTextField(
          controller: _lapseToleranceController,
          label: l10n.tr('deck_settings_lapse_tolerance'),
          helper: l10n.tr('deck_settings_lapse_tolerance_hint'),
          inputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => _validateInt(
            v,
            label: l10n.tr('deck_settings_lapse_tolerance'),
            min: 0,
            max: 1000,
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: Text(l10n.tr('deck_settings_fixed_on_lapse')),
          subtitle: Text(l10n.tr('deck_settings_fixed_on_lapse_hint')),
          value: _useFixedIntervalOnLapse,
          onChanged: (v) {
            setState(() => _useFixedIntervalOnLapse = v);
            ref.read(guidedTourProvider.notifier).onLapseFixedChanged(v);
          },
        ),
        if (_useFixedIntervalOnLapse)
          _buildTextField(
            controller: _lapseFixedIntervalController,
            label: l10n.tr('deck_settings_fixed_interval'),
            helper: l10n.tr('deck_settings_fixed_interval_hint'),
            inputType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => _validateDouble(
              v,
              label: l10n.tr('deck_settings_fixed_interval'),
              min: 0.000001,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color ?? AppUiColors.primary(context),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helper,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
