import 'package:isar/isar.dart';

part 'deck_settings.g.dart';

/// Modos de orden/mezcla de tarjetas al iniciar una sesión nueva.
/// Se guarda como String en Isar para evitar problemas de compatibilidad.
class DeckStudyMixMode {
  static const String newFirst = 'new_first';
  static const String reviewsFirst = 'reviews_first';
  static const String interleaveReviewsThenNew = 'interleave_reviews_then_new';
  static const String interleaveNewThenReviews = 'interleave_new_then_reviews';

  static const List<String> values = [
    newFirst,
    reviewsFirst,
    interleaveReviewsThenNew,
    interleaveNewThenReviews,
  ];
}

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
  // Day Cutoff (inicio del día de estudio)
  // =========================
  /// Hora (0..23) en la que empieza el "día de estudio". Default 4 AM.
  /// Nullable para compatibilidad: null => 4.
  int? dayCutoffHour = 4;

  /// Minuto (0..59) del cutoff. Default 0.
  /// Nullable para compatibilidad: null => 0.
  int? dayCutoffMinute = 0;

  // =========================
  // Nuevas (mínimo de aciertos el primer día)
  // =========================

  /// Aciertos mínimos antes de permitir que una tarjeta NUEVA pase a un día futuro.
  int newCardMinCorrectReps = 2;

  /// Minutos del paso intra-día usado para nuevas cuando newCardMinCorrectReps > 1.
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
  // Write Mode
  // =========================
  bool enableWriteMode = false;
  int writeModeThreshold = 80;
  int writeModeMaxReps = 0;

  // =========================
  // Undo
  // =========================
  bool enableUndo = true;

  // =========================
  // Mezcla / orden de sesión
  // =========================
  String studyMixMode = DeckStudyMixMode.reviewsFirst;

  int interleaveReviewsCount = 2;
  int interleaveNewCardsCount = 1;
}