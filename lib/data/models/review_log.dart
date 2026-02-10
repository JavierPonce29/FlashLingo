import 'package:isar/isar.dart';

part 'review_log.g.dart';

@collection
class ReviewLog {
  Id id = Isar.autoIncrement;

  /// Nombre del mazo (para filtrar stats / borrado por mazo)
  @Index()
  late String packName;

  /// Momento del repaso (para heatmap / rangos)
  @Index()
  late DateTime timestamp;

  /// ID lógico de la tarjeta (mismo para recog/prod) para agrupar stats si quieres
  @Index()
  late String cardOriginalId;

  /// Calificación simple (tu app usa 3=Bien, 1=Mal)
  int rating = 0;

  /// Intervalo programado (en días) después de este repaso (para análisis)
  int scheduledDays = 0;
}
