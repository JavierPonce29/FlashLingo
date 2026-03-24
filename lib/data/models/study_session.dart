import 'package:isar/isar.dart';
part 'study_session.g.dart';

@collection
class StudySession {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String packName;
  @Index(unique: true, replace: true)
  String sessionId = '';
  List<int> queueCardIds = [];
  int currentIndex = 0;
  @Index()
  DateTime sessionDay = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(0);
}
