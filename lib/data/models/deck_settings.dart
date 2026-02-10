import 'package:isar/isar.dart';

part 'deck_settings.g.dart';

@collection
class DeckSettings {
  Id id = Isar.autoIncrement;

  /// Identificador del mazo (debe ser único).
  @Index(unique: true, replace: true)
  late String packName;

  // =========================
  // Límites diarios
  // =========================

  /// Máximo de cartas nuevas por día (solo cuenta cuando realmente se "ve" una nueva).
  int newCardsPerDay = 20;

  /// Máximo de repasos por día (cartas no nuevas que estén due).
  int maxReviewsPerDay = 200;

  /// Cuántas cartas nuevas se marcaron como vistas HOY (persistente).
  int newCardsSeenToday = 0;

  /// Fecha (timestamp) de la última sesión donde se contaron nuevas.
  /// Se usa para resetear newCardsSeenToday cuando cambia el día.
  DateTime? lastNewCardStudyDate;

  // =========================
  // Aprendizaje (pasos fijos)
  // =========================

  /// Pasos en **DÍAS**. Admite fracciones para intra-día:
  /// - 10 minutos = 10/1440 ≈ 0.00694
  /// - 1 hora = 1/24 ≈ 0.04167
  ///
  /// Ejemplo típico (días): [1, 4]
  List<double> learningSteps = [1.0, 4.0];

  // =========================
  // Algoritmo (Ebbinghaus)
  // =========================

  /// Probabilidad mínima deseada (0 < pMin < 1).
  double pMin = 0.90;

  /// Correcta: nt = nt * (1 - alpha)
  double alpha = 0.10;

  /// Incorrecta: nt = nt * (1 + beta)
  double beta = 0.50;

  /// Offset (días) que se resta al intervalo calculado.
  double offset = 0.0;

  /// Nt inicial para cartas nuevas.
  double initialNt = 0.015;

  // =========================
  // Manejo de fallos (lapses)
  // =========================

  /// Cantidad de fallos consecutivos para mandar a "relearning".
  /// 0 = desactivado.
  int lapseTolerance = 0;

  /// Si está activo, tras un fallo se programa un intervalo fijo (lapseFixedInterval).
  /// Si está desactivado, el algoritmo recalcula usando el nt actualizado.
  bool useFixedIntervalOnLapse = true;

  /// Intervalo fijo (en días) tras un fallo cuando useFixedIntervalOnLapse = true.
  double lapseFixedInterval = 1.0;

  // =========================
  // Modo escritura (producción)
  // =========================

  /// Si true, las cartas *_prod activan el modo escritura en el WebView.
  bool enableWriteMode = false;

  /// Porcentaje mínimo para permitir "Bien" en modo escritura.
  int writeModeThreshold = 80;

  /// Límite de repeticiones para escritura.
  /// 0 = siempre activo.
  int writeModeMaxReps = 0;
}
