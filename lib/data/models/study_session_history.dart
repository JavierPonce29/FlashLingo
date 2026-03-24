import 'package:isar/isar.dart';

part 'study_session_history.g.dart';

@collection
class StudySessionHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  @Index()
  late String packName;

  @Index()
  DateTime sessionDay = DateTime.fromMillisecondsSinceEpoch(0);

  @Index()
  DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @Index()
  DateTime endedAt = DateTime.fromMillisecondsSinceEpoch(0);

  int answerCount = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int uniqueCardCount = 0;
  int totalStudyTimeMs = 0;
  int averageAnswerTimeMs = 0;
}
