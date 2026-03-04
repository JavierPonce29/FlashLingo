import 'package:flashcards_app/data/models/deck_settings.dart';

class StudyDay {
  static const int _defaultHour = 4;
  static const int _defaultMinute = 0;
  static int cutoffHour(DeckSettings s) =>
      (s.dayCutoffHour ?? _defaultHour).clamp(0, 23);
  static int cutoffMinute(DeckSettings s) =>
      (s.dayCutoffMinute ?? _defaultMinute).clamp(0, 59);
  static DateTime start(DateTime dt, DeckSettings s) {
    final h = cutoffHour(s);
    final m = cutoffMinute(s);
    final cutoffToday = DateTime(dt.year, dt.month, dt.day, h, m);
    if (dt.isBefore(cutoffToday)) {
      return cutoffToday.subtract(const Duration(days: 1));
    }
    return cutoffToday;
  }
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