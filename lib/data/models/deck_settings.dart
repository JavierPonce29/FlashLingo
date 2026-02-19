import 'package:isar/isar.dart';

part 'deck_settings.g.dart';

@collection
class DeckSettings {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String packName;

  // =========================
  // Límites diarios
  // =========================
  int newCardsPerDay = 40;
  int maxReviewsPerDay = 500;

  // Tracking diario (para cupo)
  int newCardsSeenToday = 0;
  DateTime? lastNewCardStudyDate;

  // =========================
  // Nuevas (mínimo de aciertos el primer día)
  // =========================

  /// Aciertos mínimos antes de permitir que una tarjeta NUEVA pase a un día futuro.
  /// Ejemplo: 2 => la primera vez que respondes "Bien" una nueva, se reprograma intra-día
  /// y solo tras el segundo "Bien" pasa al siguiente día (según learningSteps).
  int newCardMinCorrectReps = 2;

  /// Minutos del paso intra-día usado para nuevas cuando newCardMinCorrectReps > 1.
  /// Nota: en la app actual no se fuerza esperar estos minutos; la carta se re-encola
  /// "más adelante" en la sesión, pero este valor se guarda en nextReview y sirve si
  /// el usuario sale y vuelve más tarde (o al día siguiente).
  int newCardIntraDayMinutes = 10;

  // =========================
  // Aprendizaje (pasos fijos)
  // =========================
  List<double> learningSteps = [1.0, 4.0]; // en días (admite fracciones)

  // =========================
  // Parámetros SRS (Ebbinghaus)
  // =========================
  double pMin = 0.9;
  double alpha = 0.0372;
  double beta = 0.0572;
  double offset = 2.0;
  double initialNt = 0.01;

  // =========================
  // Lapses
  // =========================
  int lapseTolerance = 0;
  bool useFixedIntervalOnLapse = true;
  double lapseFixedInterval = 1.0;

  // =========================
  // Modo escritura
  // =========================
  bool enableWriteMode = false;
  int writeModeThreshold = 80;
  int writeModeMaxReps = 0;
}
