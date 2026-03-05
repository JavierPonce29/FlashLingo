import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/utils/study_day.dart';

void main() {
  group('StudyDay', () {
    test('usa el dia anterior cuando la hora es antes del cutoff', () {
      final settings = DeckSettings()
        ..packName = 'demo'
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;

      final dt = DateTime(2026, 3, 5, 2, 30);
      final label = StudyDay.label(dt, settings);

      expect(label, DateTime(2026, 3, 4));
    });

    test('usa el mismo dia cuando la hora es despues del cutoff', () {
      final settings = DeckSettings()
        ..packName = 'demo'
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;

      final dt = DateTime(2026, 3, 5, 5, 0);
      final label = StudyDay.label(dt, settings);

      expect(label, DateTime(2026, 3, 5));
    });
  });
}
