import 'package:flutter/widgets.dart';

import 'package:flashcards_app/l10n/app_strings_en.dart';
import 'package:flashcards_app/l10n/app_strings_es.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<String> supportedLanguageCodes = <String>['en', 'es'];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues =
      <String, Map<String, String>>{'en': appStringsEn, 'es': appStringsEs};

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations is not available.');
    return localizations!;
  }

  static String normalizeLanguageCode(String? code) {
    final normalized = (code ?? '').toLowerCase().trim();
    if (supportedLanguageCodes.contains(normalized)) {
      return normalized;
    }
    return 'en';
  }

  static Locale resolveLocale(Locale? locale) {
    return Locale(normalizeLanguageCode(locale?.languageCode));
  }

  String get languageCode => normalizeLanguageCode(locale.languageCode);

  String tr(String key, {Map<String, Object?> params = const {}}) {
    final values = _localizedValues[languageCode] ?? appStringsEn;
    var value = values[key] ?? appStringsEn[key] ?? key;
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLanguageCodes
      .contains(AppLocalizations.normalizeLanguageCode(locale.languageCode));

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(AppLocalizations.resolveLocale(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
