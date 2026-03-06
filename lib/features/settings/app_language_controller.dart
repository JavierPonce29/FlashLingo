import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flashcards_app/l10n/app_localizations.dart';

const _appLanguagePreferenceKey = 'app_language_code';

final appLocaleProvider = StateNotifierProvider<AppLanguageController, Locale>(
  (ref) => AppLanguageController(),
);

class AppLanguageController extends StateNotifier<Locale> {
  AppLanguageController() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final savedCode = preferences.getString(_appLanguagePreferenceKey);

    if (savedCode != null && savedCode.trim().isNotEmpty) {
      state = Locale(AppLocalizations.normalizeLanguageCode(savedCode));
      return;
    }

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    state = AppLocalizations.resolveLocale(systemLocale);
  }

  Future<void> setLanguageCode(String languageCode) async {
    final normalizedCode = AppLocalizations.normalizeLanguageCode(languageCode);
    final nextLocale = Locale(normalizedCode);
    if (state == nextLocale) return;

    state = nextLocale;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appLanguagePreferenceKey, normalizedCode);
  }
}
