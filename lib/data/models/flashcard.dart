import 'package:isar/isar.dart';

part 'flashcard.g.dart';

@collection
class Flashcard {
  Id id = Isar.autoIncrement;

  @Index()
  late String originalId;

  @Index()
  late String isoCode;

  @Index()
  late String packName;

  @Index()
  late String cardType;

  late String question;
  late String answer;

  String? audioPath;
  String? sentenceAudioPath;
  String? imagePath;
  String? sentence;
  String? translation;
  String? extraDataJson;

  // --- VARIABLES DE ESTADO DEL ALGORITMO EBBINGHAUS ---

  @Index()
  DateTime nextReview = DateTime.now();

  /// IMPORTANTE:
  /// No usar DateTime.now() por defecto aquí, porque una tarjeta recién creada
  /// parecería "ya revisada hoy" y puede distorsionar stats/lógica.
  DateTime lastReview = DateTime.fromMillisecondsSinceEpoch(0);

  // Tasa de olvido actual (nt).
  double decayRate = 0.015;

  // Cola de fase de aprendizaje (pasos fijos en días; puede usar fracciones)
  List<double> fixedPhaseQueue = [];

  // Paso de aprendizaje (según tu lógica actual en SRS)
  int learningStep = 0;

  // Contador de fallos consecutivos en fase Repaso (tolerancia a fallos / leech)
  int consecutiveLapses = 0;

  // Estadísticas generales
  int repetitionCount = 0;

  /// Guardar enums por NOMBRE es mucho más seguro que ordinal.
  /// (Evita corrupción si reordenas/insertas valores en el enum).
  @Enumerated(EnumType.name)
  CardState state = CardState.newCard;
}

enum CardState { newCard, learning, review, relearning }
