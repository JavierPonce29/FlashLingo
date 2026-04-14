import 'package:flashcards_app/features/library/deck_settings_validation.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizations(const Locale('en'));

  group('parseLearningSteps', () {
    test('parses comma separated step values', () {
      expect(parseLearningSteps('1, 4, 8.5'), <double>[1.0, 4.0, 8.5]);
    });

    test('rejects empty segments and invalid numbers', () {
      expect(parseLearningSteps('1,,4'), isNull);
      expect(parseLearningSteps('abc'), isNull);
      expect(parseLearningSteps(''), isNull);
    });
  });

  group('validateLearningStepsInput', () {
    test('returns localized errors for missing or invalid input', () {
      expect(validateLearningStepsInput(l10n, ''), 'Required');
      expect(
        validateLearningStepsInput(l10n, 'abc'),
        'Enter at least 1 valid step.',
      );
      expect(validateLearningStepsInput(l10n, '1, -2'), 'Steps must be > 0.');
    });

    test('accepts valid positive steps', () {
      expect(validateLearningStepsInput(l10n, '1, 4, 8'), isNull);
    });
  });
}
