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
  late String cardOriginalId;
  int rating = 0;
  int scheduledDays = 0;
}
