import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/study_session/html_generator.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlGenerator', () {
    test('disables keyboard suggestions in write mode inputs', () {
      final card = Flashcard()
        ..originalId = '1'
        ..isoCode = 'ja'
        ..packName = 'Demo'
        ..cardType = 'ja_prod'
        ..question = 'cat'
        ..answer = '猫'
        ..sentence = 'A cat sleeps.'
        ..translation = '猫が寝ている。';

      final html = HtmlGenerator.generateContent(
        card,
        l10n: AppLocalizations(const Locale('es')),
        writeMode: true,
      );

      expect(html, contains('autocorrect="off"'));
      expect(html, contains('autocomplete="off"'));
      expect(html, contains('autocapitalize="off"'));
      expect(html, contains('spellcheck="false"'));
    });

    test('can render write mode without webview textareas', () {
      final card = Flashcard()
        ..originalId = '2'
        ..isoCode = 'ja'
        ..packName = 'Demo'
        ..cardType = 'ja_prod'
        ..question = 'dog'
        ..answer = '犬'
        ..sentence = 'A dog runs.'
        ..translation = '犬が走る。';

      final html = HtmlGenerator.generateContent(
        card,
        l10n: AppLocalizations(const Locale('es')),
        writeMode: true,
        nativeWriteInput: true,
      );

      expect(html, isNot(contains('id="dynamic-write-area"')));
      expect(html, isNot(contains('id="source-hidden-raw"')));
      expect(html, contains('setNativeWriteResults('));
    });
  });
}
