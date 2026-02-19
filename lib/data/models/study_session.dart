import 'package:isar/isar.dart';

part 'study_session.g.dart';

@collection
class StudySession {
  Id id = Isar.autoIncrement;

  /// Identificador del mazo (único). Permite una sesión activa por mazo.
  @Index(unique: true, replace: true)
  late String packName;

  /// Cola persistida en orden (permite duplicados). Guarda IDs de Flashcard.
  List<int> queueCardIds = [];

  /// Índice actual dentro de la cola.
  int currentIndex = 0;

  /// Día de la sesión (solo fecha). Si cambia el día, la sesión se descarta.
  @Index()
  DateTime sessionDay = DateTime.fromMillisecondsSinceEpoch(0);

  /// Para debug/soporte: última vez que se actualizó el progreso.
  DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(0);
}
