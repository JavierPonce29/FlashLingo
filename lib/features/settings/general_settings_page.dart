import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcards_app/features/home/time_machine_service.dart';
import 'package:flashcards_app/features/settings/app_language_controller.dart';
import 'package:flashcards_app/features/settings/app_theme_mode_controller.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('settings_general_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
            onChanged: (selectedMode) {
              if (selectedMode == null) return;
              ref.read(appThemeModeProvider.notifier).setThemeMode(selectedMode);
            },
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tr('settings_theme_default_hint'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
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
                    child: Text(_languageNameForCode(l10n, languageCode)),
                  ),
                )
                .toList(),
            onChanged: (selectedCode) {
              if (selectedCode == null) return;
              ref.read(appLocaleProvider.notifier).setLanguageCode(selectedCode);
            },
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tr('settings_language_default_hint'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: Text(l10n.tr('settings_time_machine_title')),
              subtitle: Text(l10n.tr('settings_time_machine_subtitle')),
              onTap: () => _showTimeMachineDialog(context, ref),
            ),
          ),
        ],
      ),
    );
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
                  SnackBar(content: Text(l10n.tr('settings_time_machine_success'))),
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
