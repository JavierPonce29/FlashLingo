import 'package:isar/isar.dart';

part 'app_meta.g.dart';

@collection
class AppMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  int intValue = 0;
  String? stringValue;
  DateTime updatedAt = DateTime.now();
}
