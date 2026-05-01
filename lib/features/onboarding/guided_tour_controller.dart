import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flashcards_app/features/onboarding/starter_deck_service.dart';

const _welcomeSeenPreferenceKey = 'onboarding_welcome_seen_v1';
const _tourCompletedPreferenceKey = 'onboarding_tour_completed_v1';

enum GuidedTourStep {
  none,
  homeIntro,
  homeOpenSettings,
  settingsIntro,
  settingsAppearance,
  settingsLanguage,
  settingsTimeMachine,
  settingsTourButton,
  settingsExit,
  homeImportStarter,
  importSummaryIntro,
  importSummaryCards,
  importSummarySettings,
  importSummaryMedia,
  importSummaryDiagnostics,
  importSummaryExit,
  homeDeckHighlight,
  homeDeckMenuOpen,
  deckSettingsIntro,
  deckSettingsDaily,
  deckSettingsMix,
  deckSettingsWriteToggleOn,
  deckSettingsWriteOptions,
  deckSettingsWriteToggleOff,
  deckSettingsLapseToggleOn,
  deckSettingsLapseOptions,
  deckSettingsLapseToggleOff,
  deckSettingsExit,
  homeDeckStudyPrompt,
  deckOverviewStart,
  studyIntro,
  studyTopCounter,
  studyTypeBar,
  studyWordArea,
  studySentenceArea,
  studyShowAnswerFirst,
  studyMeaningFirst,
  studyFormsFirst,
  studyTranslationFirst,
  studyRateFirst,
  studySecondCardIntro,
  studyShowAnswerSecond,
  studyRateSecond,
  studyFinishRemaining,
  studyFinishedExplain,
  homeOpenStats,
  statsIntro,
  statsComparison,
  statsActivity,
  statsStudyTime,
  statsDistribution,
  statsForecast,
  statsIntervals,
  statsHourly,
  statsPredictionRepetitions,
  statsPredictionTime,
  statsPerformance,
  statsProblemCards,
  statsRecentSessions,
  statsHardestCards,
  statsExit,
  homeDeleteDeck,
  homeDeleteConfirm,
  finalMessage,
}

extension GuidedTourStepX on GuidedTourStep {
  bool get isHomeStep =>
      this == GuidedTourStep.homeIntro ||
      this == GuidedTourStep.homeOpenSettings ||
      this == GuidedTourStep.homeImportStarter ||
      this == GuidedTourStep.homeDeckHighlight ||
      this == GuidedTourStep.homeDeckMenuOpen ||
      this == GuidedTourStep.homeDeckStudyPrompt ||
      this == GuidedTourStep.homeOpenStats ||
      this == GuidedTourStep.homeDeleteDeck ||
      this == GuidedTourStep.homeDeleteConfirm ||
      this == GuidedTourStep.finalMessage;

  bool get isGeneralSettingsStep =>
      this == GuidedTourStep.settingsIntro ||
      this == GuidedTourStep.settingsAppearance ||
      this == GuidedTourStep.settingsLanguage ||
      this == GuidedTourStep.settingsTimeMachine ||
      this == GuidedTourStep.settingsTourButton ||
      this == GuidedTourStep.settingsExit;

  bool get isImportSummaryStep =>
      this == GuidedTourStep.importSummaryIntro ||
      this == GuidedTourStep.importSummaryCards ||
      this == GuidedTourStep.importSummarySettings ||
      this == GuidedTourStep.importSummaryMedia ||
      this == GuidedTourStep.importSummaryDiagnostics ||
      this == GuidedTourStep.importSummaryExit;

  bool get isDeckSettingsStep =>
      this == GuidedTourStep.deckSettingsIntro ||
      this == GuidedTourStep.deckSettingsDaily ||
      this == GuidedTourStep.deckSettingsMix ||
      this == GuidedTourStep.deckSettingsWriteToggleOn ||
      this == GuidedTourStep.deckSettingsWriteOptions ||
      this == GuidedTourStep.deckSettingsWriteToggleOff ||
      this == GuidedTourStep.deckSettingsLapseToggleOn ||
      this == GuidedTourStep.deckSettingsLapseOptions ||
      this == GuidedTourStep.deckSettingsLapseToggleOff ||
      this == GuidedTourStep.deckSettingsExit;

  bool get isDeckOverviewStep => this == GuidedTourStep.deckOverviewStart;

  bool get isStudyStep =>
      this == GuidedTourStep.studyIntro ||
      this == GuidedTourStep.studyTopCounter ||
      this == GuidedTourStep.studyTypeBar ||
      this == GuidedTourStep.studyWordArea ||
      this == GuidedTourStep.studySentenceArea ||
      this == GuidedTourStep.studyShowAnswerFirst ||
      this == GuidedTourStep.studyMeaningFirst ||
      this == GuidedTourStep.studyFormsFirst ||
      this == GuidedTourStep.studyTranslationFirst ||
      this == GuidedTourStep.studyRateFirst ||
      this == GuidedTourStep.studySecondCardIntro ||
      this == GuidedTourStep.studyShowAnswerSecond ||
      this == GuidedTourStep.studyRateSecond ||
      this == GuidedTourStep.studyFinishRemaining ||
      this == GuidedTourStep.studyFinishedExplain;

  bool get isStatsStep =>
      this == GuidedTourStep.statsIntro ||
      this == GuidedTourStep.statsComparison ||
      this == GuidedTourStep.statsActivity ||
      this == GuidedTourStep.statsStudyTime ||
      this == GuidedTourStep.statsDistribution ||
      this == GuidedTourStep.statsForecast ||
      this == GuidedTourStep.statsIntervals ||
      this == GuidedTourStep.statsHourly ||
      this == GuidedTourStep.statsPredictionRepetitions ||
      this == GuidedTourStep.statsPredictionTime ||
      this == GuidedTourStep.statsPerformance ||
      this == GuidedTourStep.statsProblemCards ||
      this == GuidedTourStep.statsRecentSessions ||
      this == GuidedTourStep.statsHardestCards ||
      this == GuidedTourStep.statsExit;
}

class GuidedTourState {
  final bool isInitialized;
  final bool welcomeSeen;
  final bool tourCompleted;
  final GuidedTourStep step;
  final String? guidedDeckName;

  const GuidedTourState({
    required this.isInitialized,
    required this.welcomeSeen,
    required this.tourCompleted,
    required this.step,
    required this.guidedDeckName,
  });

  static const GuidedTourState initial = GuidedTourState(
    isInitialized: false,
    welcomeSeen: false,
    tourCompleted: false,
    step: GuidedTourStep.none,
    guidedDeckName: null,
  );

  bool get isTourActive => step != GuidedTourStep.none;

  GuidedTourState copyWith({
    bool? isInitialized,
    bool? welcomeSeen,
    bool? tourCompleted,
    GuidedTourStep? step,
    String? guidedDeckName,
    bool clearGuidedDeckName = false,
  }) {
    return GuidedTourState(
      isInitialized: isInitialized ?? this.isInitialized,
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
      tourCompleted: tourCompleted ?? this.tourCompleted,
      step: step ?? this.step,
      guidedDeckName: clearGuidedDeckName
          ? null
          : (guidedDeckName ?? this.guidedDeckName),
    );
  }
}

final guidedTourProvider =
    StateNotifierProvider<GuidedTourController, GuidedTourState>(
      (ref) => GuidedTourController(),
    );

class GuidedTourController extends StateNotifier<GuidedTourState> {
  GuidedTourController() : super(GuidedTourState.initial) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    state = state.copyWith(
      isInitialized: true,
      welcomeSeen: preferences.getBool(_welcomeSeenPreferenceKey) ?? false,
      tourCompleted: preferences.getBool(_tourCompletedPreferenceKey) ?? false,
    );

    // Prepara el paquete de bienvenida al arrancar la app.
    try {
      await StarterDeckService.ensureStarterPackageExists();
    } catch (_) {}
  }

  Future<void> markWelcomeSeen() async {
    if (state.welcomeSeen) return;
    state = state.copyWith(welcomeSeen: true);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_welcomeSeenPreferenceKey, true);
  }

  void startTour() {
    state = state.copyWith(
      step: GuidedTourStep.homeIntro,
      clearGuidedDeckName: true,
    );
  }

  void nextFromHomeIntro() {
    if (state.step != GuidedTourStep.homeIntro) return;
    state = state.copyWith(step: GuidedTourStep.homeOpenSettings);
  }

  void onGeneralSettingsOpened() {
    if (state.step != GuidedTourStep.homeOpenSettings) return;
    state = state.copyWith(step: GuidedTourStep.settingsIntro);
  }

  void nextInGeneralSettings() {
    switch (state.step) {
      case GuidedTourStep.settingsIntro:
        state = state.copyWith(step: GuidedTourStep.settingsAppearance);
        return;
      case GuidedTourStep.settingsAppearance:
        state = state.copyWith(step: GuidedTourStep.settingsLanguage);
        return;
      case GuidedTourStep.settingsLanguage:
        state = state.copyWith(
          step: kDebugMode
              ? GuidedTourStep.settingsTimeMachine
              : GuidedTourStep.settingsTourButton,
        );
        return;
      case GuidedTourStep.settingsTimeMachine:
        state = state.copyWith(step: GuidedTourStep.settingsTourButton);
        return;
      case GuidedTourStep.settingsTourButton:
        state = state.copyWith(step: GuidedTourStep.settingsExit);
        return;
      default:
        return;
    }
  }

  void onGeneralSettingsClosed() {
    if (state.step == GuidedTourStep.settingsExit) {
      state = state.copyWith(step: GuidedTourStep.homeImportStarter);
      return;
    }
    if (state.step.isGeneralSettingsStep) {
      state = state.copyWith(step: GuidedTourStep.homeOpenSettings);
    }
  }

  void onStarterImportCompleted(String deckName) {
    state = state.copyWith(
      step: GuidedTourStep.importSummaryIntro,
      guidedDeckName: deckName,
    );
  }

  void nextInImportSummary() {
    switch (state.step) {
      case GuidedTourStep.importSummaryIntro:
        state = state.copyWith(step: GuidedTourStep.importSummaryCards);
        return;
      case GuidedTourStep.importSummaryCards:
        state = state.copyWith(step: GuidedTourStep.importSummarySettings);
        return;
      case GuidedTourStep.importSummarySettings:
        state = state.copyWith(step: GuidedTourStep.importSummaryMedia);
        return;
      case GuidedTourStep.importSummaryMedia:
        state = state.copyWith(step: GuidedTourStep.importSummaryDiagnostics);
        return;
      case GuidedTourStep.importSummaryDiagnostics:
        state = state.copyWith(step: GuidedTourStep.importSummaryExit);
        return;
      default:
        return;
    }
  }

  void onImportSummaryClosed() {
    if (state.step.isImportSummaryStep) {
      state = state.copyWith(step: GuidedTourStep.homeDeckHighlight);
    }
  }

  void nextFromHomeDeckHighlight() {
    if (state.step != GuidedTourStep.homeDeckHighlight) return;
    state = state.copyWith(step: GuidedTourStep.homeDeckMenuOpen);
  }

  void onDeckMenuTutorialCompleted() {
    if (state.step != GuidedTourStep.homeDeckMenuOpen) return;
    state = state.copyWith(step: GuidedTourStep.deckSettingsIntro);
  }

  void onDeckSettingsOpened() {
    if (state.step != GuidedTourStep.deckSettingsIntro) return;
    state = state.copyWith(step: GuidedTourStep.deckSettingsDaily);
  }

  void nextInDeckSettings() {
    switch (state.step) {
      case GuidedTourStep.deckSettingsIntro:
        state = state.copyWith(step: GuidedTourStep.deckSettingsDaily);
        return;
      case GuidedTourStep.deckSettingsDaily:
        state = state.copyWith(step: GuidedTourStep.deckSettingsMix);
        return;
      case GuidedTourStep.deckSettingsMix:
        state = state.copyWith(step: GuidedTourStep.deckSettingsWriteToggleOn);
        return;
      case GuidedTourStep.deckSettingsWriteOptions:
        state = state.copyWith(step: GuidedTourStep.deckSettingsWriteToggleOff);
        return;
      case GuidedTourStep.deckSettingsLapseOptions:
        state = state.copyWith(step: GuidedTourStep.deckSettingsLapseToggleOff);
        return;
      default:
        return;
    }
  }

  void onWriteModeChanged(bool enabled) {
    if (state.step == GuidedTourStep.deckSettingsWriteToggleOn && enabled) {
      state = state.copyWith(step: GuidedTourStep.deckSettingsWriteOptions);
      return;
    }
    if (state.step == GuidedTourStep.deckSettingsWriteToggleOff && !enabled) {
      state = state.copyWith(step: GuidedTourStep.deckSettingsLapseToggleOn);
    }
  }

  void onLapseFixedChanged(bool enabled) {
    if (state.step == GuidedTourStep.deckSettingsLapseToggleOn && enabled) {
      state = state.copyWith(step: GuidedTourStep.deckSettingsLapseOptions);
      return;
    }
    if (state.step == GuidedTourStep.deckSettingsLapseToggleOff && !enabled) {
      state = state.copyWith(step: GuidedTourStep.deckSettingsExit);
    }
  }

  void onDeckSettingsSavedAndClosed() {
    if (state.step == GuidedTourStep.deckSettingsExit) {
      state = state.copyWith(step: GuidedTourStep.homeDeckStudyPrompt);
    }
  }

  void onDeckOverviewOpenedForStudy() {
    if (state.step != GuidedTourStep.homeDeckStudyPrompt) return;
    state = state.copyWith(step: GuidedTourStep.deckOverviewStart);
  }

  void onDeckStudyStarted() {
    if (state.step != GuidedTourStep.deckOverviewStart) return;
    state = state.copyWith(step: GuidedTourStep.studyIntro);
  }

  void nextStudyNarrationStep() {
    switch (state.step) {
      case GuidedTourStep.studyIntro:
        state = state.copyWith(step: GuidedTourStep.studyTopCounter);
        return;
      case GuidedTourStep.studyTopCounter:
        state = state.copyWith(step: GuidedTourStep.studyTypeBar);
        return;
      case GuidedTourStep.studyTypeBar:
        state = state.copyWith(step: GuidedTourStep.studyShowAnswerFirst);
        return;
      case GuidedTourStep.studySecondCardIntro:
        state = state.copyWith(step: GuidedTourStep.studyShowAnswerSecond);
        return;
      default:
        return;
    }
  }

  void onStudyAnswerShown() {
    if (state.step == GuidedTourStep.studyShowAnswerFirst) {
      state = state.copyWith(step: GuidedTourStep.studyRateFirst);
      return;
    }
    if (state.step == GuidedTourStep.studyShowAnswerSecond) {
      state = state.copyWith(step: GuidedTourStep.studyRateSecond);
    }
  }

  void onStudyRatedCard() {
    if (state.step == GuidedTourStep.studyRateFirst) {
      state = state.copyWith(step: GuidedTourStep.studySecondCardIntro);
      return;
    }
    if (state.step == GuidedTourStep.studyRateSecond) {
      state = state.copyWith(step: GuidedTourStep.studyFinishRemaining);
    }
  }

  void onStudyQueueFinished() {
    if (state.step.isStudyStep) {
      state = state.copyWith(step: GuidedTourStep.studyFinishedExplain);
    }
  }

  void onStudyFinishedScreenClosed() {
    if (state.step != GuidedTourStep.studyFinishedExplain) return;
    state = state.copyWith(step: GuidedTourStep.homeOpenStats);
  }

  void onStatsOpened() {
    if (state.step != GuidedTourStep.homeOpenStats) return;
    state = state.copyWith(step: GuidedTourStep.statsIntro);
  }

  void nextInStats() {
    switch (state.step) {
      case GuidedTourStep.statsIntro:
        state = state.copyWith(step: GuidedTourStep.statsComparison);
        return;
      case GuidedTourStep.statsComparison:
        state = state.copyWith(step: GuidedTourStep.statsActivity);
        return;
      case GuidedTourStep.statsActivity:
        state = state.copyWith(step: GuidedTourStep.statsStudyTime);
        return;
      case GuidedTourStep.statsStudyTime:
        state = state.copyWith(step: GuidedTourStep.statsDistribution);
        return;
      case GuidedTourStep.statsDistribution:
        state = state.copyWith(step: GuidedTourStep.statsForecast);
        return;
      case GuidedTourStep.statsForecast:
        state = state.copyWith(step: GuidedTourStep.statsIntervals);
        return;
      case GuidedTourStep.statsIntervals:
        state = state.copyWith(step: GuidedTourStep.statsHourly);
        return;
      case GuidedTourStep.statsHourly:
        state = state.copyWith(step: GuidedTourStep.statsPredictionRepetitions);
        return;
      case GuidedTourStep.statsPredictionRepetitions:
        state = state.copyWith(step: GuidedTourStep.statsPredictionTime);
        return;
      case GuidedTourStep.statsPredictionTime:
        state = state.copyWith(step: GuidedTourStep.statsPerformance);
        return;
      case GuidedTourStep.statsPerformance:
        state = state.copyWith(step: GuidedTourStep.statsProblemCards);
        return;
      case GuidedTourStep.statsProblemCards:
        state = state.copyWith(step: GuidedTourStep.statsRecentSessions);
        return;
      case GuidedTourStep.statsRecentSessions:
        state = state.copyWith(step: GuidedTourStep.statsHardestCards);
        return;
      case GuidedTourStep.statsHardestCards:
        state = state.copyWith(step: GuidedTourStep.statsExit);
        return;
      default:
        return;
    }
  }

  void onStatsClosed() {
    if (state.step == GuidedTourStep.statsExit || state.step.isStatsStep) {
      state = state.copyWith(step: GuidedTourStep.homeDeleteDeck);
    }
  }

  void onDeletePromptOpened() {
    if (state.step != GuidedTourStep.homeDeleteDeck) return;
    state = state.copyWith(step: GuidedTourStep.homeDeleteConfirm);
  }

  void onGuidedDeckDeleted() {
    if (state.step != GuidedTourStep.homeDeleteConfirm &&
        state.step != GuidedTourStep.homeDeleteDeck) {
      return;
    }
    state = state.copyWith(step: GuidedTourStep.finalMessage);
  }

  Future<void> completeTour() async {
    state = state.copyWith(
      step: GuidedTourStep.none,
      tourCompleted: true,
      clearGuidedDeckName: true,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_tourCompletedPreferenceKey, true);
  }
}
