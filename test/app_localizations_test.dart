import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/l10n/app_localizations.dart';

void main() {
  test('supports only English and Spanish in v1', () {
    expect(AppLocalizations.supportedLanguageCodes, const <String>['en', 'es']);
    expect(AppLocalizations.supportedLocales, const <Locale>[
      Locale('en'),
      Locale('es'),
    ]);
    expect(AppLocalizations.normalizeLanguageCode('fr'), 'en');
  });
}
