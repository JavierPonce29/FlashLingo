import 'package:isar/isar.dart';

part 'deck_daily_stats.g.dart';

@collection
class DeckDailyStats {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String packDayKey;

  @Index()
  late String packName;

  @Index()
  DateTime studyDay = DateTime.fromMillisecondsSinceEpoch(0);

  int reviewCount = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int uniqueCardCount = 0;
  int newReviewCount = 0;
  int learningReviewCount = 0;
  int reviewStateCount = 0;
  int sessionCount = 0;
  int totalStudyTimeMs = 0;
  int newStudyTimeMs = 0;
  int learningStudyTimeMs = 0;
  int reviewStudyTimeMs = 0;
  int averageAnswerTimeMs = 0;
  List<int> quarterHourBuckets = [];
}
