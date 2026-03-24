import 'package:isar/isar.dart';
part 'review_log.g.dart';

@collection
class ReviewLog {
  Id id = Isar.autoIncrement;
  @Index()
  late String packName;
  @Index()
  late DateTime timestamp;
  @Index()
  DateTime studyDay = DateTime.fromMillisecondsSinceEpoch(0);
  @Index()
  late String cardOriginalId;
  @Index()
  int flashcardId = 0;
  @Index()
  String sessionId = '';
  String cardType = '';
  bool isCorrect = false;
  String previousState = '';
  String newState = '';
  DateTime previousNextReview = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime newNextReview = DateTime.fromMillisecondsSinceEpoch(0);
  int daysLate = 0;
  int rating = 0;
  int scheduledDays = 0;
  int studyDurationMs = 0;
}
