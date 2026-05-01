import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flashcards_app/features/home/time_machine_service.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/settings/app_language_controller.dart';
import 'package:flashcards_app/features/settings/app_theme_mode_controller.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final guidedTourState = ref.watch(guidedTourProvider);
    final tourStep = guidedTourState.step;
    final tourInsideSettings = tourStep.isGeneralSettingsStep;
    final canPopPage =
        !tourInsideSettings || tourStep == GuidedTourStep.settingsExit;

    return PopScope(
      canPop: canPopPage,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (tourInsideSettings) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.tr('onboarding_tour_settings_blocked'),
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: Text(l10n.tr('settings_general_title'))),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TourHighlight(
                  highlighted: tourStep == GuidedTourStep.settingsAppearance,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<ThemeMode>(
                        key: ValueKey(themeMode),
                        initialValue: themeMode,
                        decoration: InputDecoration(
                          labelText: l10n.tr('settings_interface_appearance'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(l10n.tr('settings_theme_system')),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(l10n.tr('settings_theme_dark')),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(l10n.tr('settings_theme_light')),
                          ),
                        ],
                        onChanged: tourInsideSettings
                            ? null
                            : (selectedMode) {
                                if (selectedMode == null) return;
                                ref
                                    .read(appThemeModeProvider.notifier)
                                    .setThemeMode(selectedMode);
                              },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tr('settings_theme_default_hint'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TourHighlight(
                  highlighted: tourStep == GuidedTourStep.settingsLanguage,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(locale.languageCode),
                        initialValue: locale.languageCode,
                        decoration: InputDecoration(
                          labelText: l10n.tr('settings_interface_language'),
                          border: const OutlineInputBorder(),
                        ),
                        items: AppLocalizations.supportedLanguageCodes
                            .map(
                              (languageCode) => DropdownMenuItem<String>(
                                value: languageCode,
                                child: Text(
                                  _languageNameForCode(l10n, languageCode),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: tourInsideSettings
                            ? null
                            : (selectedCode) {
                                if (selectedCode == null) return;
                                ref
                                    .read(appLocaleProvider.notifier)
                                    .setLanguageCode(selectedCode);
                              },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tr('settings_language_default_hint'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (kDebugMode) ...[
                  TourHighlight(
                    highlighted: tourStep == GuidedTourStep.settingsTimeMachine,
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.history_toggle_off),
                        title: Text(l10n.tr('settings_time_machine_title')),
                        subtitle: Text(
                          l10n.tr('settings_time_machine_subtitle'),
                        ),
                        onTap: tourInsideSettings
                            ? null
                            : () => _showTimeMachineDialog(context, ref),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TourHighlight(
                  highlighted: tourStep == GuidedTourStep.settingsTourButton,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.tour_outlined),
                      title: Text(l10n.tr('settings_tour_title')),
                      subtitle: Text(l10n.tr('settings_tour_subtitle')),
                      onTap: tourInsideSettings
                          ? null
                          : () {
                              ref.read(guidedTourProvider.notifier).startTour();
                              Navigator.pop(context);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: Text(l10n.tr('onboarding_download_link_label')),
                    onTap: tourInsideSettings
                        ? null
                        : () async {
                            final uri = Uri.tryParse(
                              l10n.tr('onboarding_download_link_url'),
                            );
                            if (uri == null) return;
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
          if (tourInsideSettings) ...[
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: AppUiColors.scrim(context)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: TourMessageCard(
                message: _tourMessageForStep(l10n, tourStep),
                actionLabel: tourStep == GuidedTourStep.settingsExit
                    ? null
                    : l10n.tr('onboarding_tour_next'),
                onActionPressed: tourStep == GuidedTourStep.settingsExit
                    ? null
                    : () => ref
                          .read(guidedTourProvider.notifier)
                          .nextInGeneralSettings(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _tourMessageForStep(AppLocalizations l10n, GuidedTourStep step) {
    switch (step) {
      case GuidedTourStep.settingsIntro:
        return l10n.tr('onboarding_tour_settings_intro');
      case GuidedTourStep.settingsAppearance:
        return l10n.tr('onboarding_tour_settings_appearance');
      case GuidedTourStep.settingsLanguage:
        return l10n.tr('onboarding_tour_settings_language');
      case GuidedTourStep.settingsTimeMachine:
        return l10n.tr('onboarding_tour_settings_time_machine');
      case GuidedTourStep.settingsTourButton:
        return l10n.tr('onboarding_tour_settings_tour_button');
      case GuidedTourStep.settingsExit:
        return l10n.tr('onboarding_tour_settings_exit');
      default:
        return '';
    }
  }

  String _languageNameForCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'en':
        return l10n.tr('language_en');
      case 'es':
        return l10n.tr('language_es');
      case 'ro':
        return l10n.tr('language_ro');
      case 'de':
        return l10n.tr('language_de');
      case 'fr':
        return l10n.tr('language_fr');
      case 'ja':
        return l10n.tr('language_ja');
      case 'zh':
        return l10n.tr('language_zh');
      default:
        return code;
    }
  }

  void _showTimeMachineDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.tr('settings_time_machine_dialog_title')),
        content: Text(l10n.tr('settings_time_machine_dialog_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('common_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await applyTimeTravel(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.tr('settings_time_machine_success')),
                  ),
                );
              }
            },
            child: Text(l10n.tr('settings_time_machine_action')),
          ),
        ],
      ),
    );
  }
}
