import 'package:flashcards_app/data/models/deck_settings.dart';

/// Helpers para trabajar con el "día de estudio" basado en un cutoff configurable.
/// Ejemplo: cutoff 04:00 => el día de estudio va de 04:00 a 03:59:59.
class StudyDay {
  static const int _defaultHour = 4;
  static const int _defaultMinute = 0;

  static int cutoffHour(DeckSettings s) =>
      (s.dayCutoffHour ?? _defaultHour).clamp(0, 23);

  static int cutoffMinute(DeckSettings s) =>
      (s.dayCutoffMinute ?? _defaultMinute).clamp(0, 59);

  /// Inicio del día de estudio que contiene [dt] (en hora de cutoff).
  static DateTime start(DateTime dt, DeckSettings s) {
    final h = cutoffHour(s);
    final m = cutoffMinute(s);

    final cutoffToday = DateTime(dt.year, dt.month, dt.day, h, m);
    if (dt.isBefore(cutoffToday)) {
      return cutoffToday.subtract(const Duration(days: 1));
    }
    return cutoffToday;
  }

  /// Etiqueta del día de estudio (date-only, 00:00).
  /// Útil para comparar "mismo día" y guardar sessionDay/lastNewCardStudyDate.
  static DateTime label(DateTime dt, DeckSettings s) {
    final st = start(dt, s);
    return DateTime(st.year, st.month, st.day);
  }

  static bool sameLabel(DateTime a, DateTime b, DeckSettings s) {
    final la = label(a, s);
    final lb = label(b, s);
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}