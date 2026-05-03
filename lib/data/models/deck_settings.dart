import 'package:isar/isar.dart';
part 'deck_settings.g.dart';

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
  // Icono del mazo
  // =========================
  String? deckIconUri;

  // =========================
  // Límites diarios
  // =========================
  int newCardsPerDay = 40;
  int maxReviewsPerDay = 500;
  bool hideNewCardsOnReviewOverflow = false;

  // Tracking diario (para cupo)
  int newCardsSeenToday = 0;
  DateTime? lastNewCardStudyDate;

  // =========================
  // Day Cutoff (inicio del día de estudio)
  // =========================
  int? dayCutoffHour = 4;
  int? dayCutoffMinute = 0;

  // =========================
  // Nuevas (mínimo de aciertos el primer día)
  // =========================
  int newCardMinCorrectReps = 2;
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
