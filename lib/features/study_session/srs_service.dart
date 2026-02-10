import 'dart:math';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

class SrsService {
  // Retorna 'true' si la carta debe repetirse HOY mismo (p. ej. por castigo intra-día).
  //
  // Convención usada aquí:
  // - settings.learningSteps (y card.fixedPhaseQueue) están en **DÍAS**.
  //   Puedes usar fracciones para pasos intra-día (ej. 10 min = 10/1440).
  // - Para intervalos >= 1 día, la próxima revisión se normaliza a las 04:00 (estilo Anki).
  bool reviewCard(Flashcard card, bool isCorrect, DeckSettings settings) {
    final now = DateTime.now();
    card.lastReview = now;

    // --- FASE 1: NUEVA ---
    if (card.state == CardState.newCard) {
      if (isCorrect) {
        card.consecutiveLapses = 0;

        // Preparar cola fija (si está vacía) para este mazo/carta.
        _ensureFixedQueueInitialized(card, settings);

        // Si no hay pasos de aprendizaje configurados, gradúa directo a Review.
        if (card.fixedPhaseQueue.isEmpty) {
          _graduateToReview(card, settings, now);
          return false;
        }

        // Entrar a Learning y programar el primer paso (índice 0).
        card.state = CardState.learning;
        card.learningStep = -1; // -1 => el próximo acierto programa el paso 0
        return _handleLearningSuccess(card, settings, now);
      } else {
        // Fallo en Nueva -> penalización intra-día y permanece como newCard
        card.learningStep = 0;
        _scheduleNextReview(card, _minutesToDays(1), now); // 1 minuto
        return true;
      }
    }

    // --- FASE 2: APRENDIZAJE (Learning / Relearning) ---
    if (card.state == CardState.learning ||
        card.state == CardState.relearning) {
      if (isCorrect) {
        return _handleLearningSuccess(card, settings, now);
      } else {
        // Fallo en Learning/Relearning -> reinicia pasos y penaliza intra-día
        card.learningStep = -1;
        _scheduleNextReview(card, _minutesToDays(1), now); // 1 minuto
        return true;
      }
    }

    // --- FASE 3: REPASO (Review - Ebbinghaus) ---
    if (card.state == CardState.review) {
      if (isCorrect) {
        card.consecutiveLapses = 0;
        _applyEbbinghausSuccess(card, settings, now);
        return false;
      } else {
        return _handleReviewFailure(card, settings, now);
      }
    }

    return false; // Fallback
  }

  // =========================
  // Learning / Relearning
  // =========================

  bool _handleLearningSuccess(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    _ensureFixedQueueInitialized(card, settings);

    if (card.fixedPhaseQueue.isEmpty) {
      _graduateToReview(card, settings, now);
      return false;
    }

    // learningStep representa "último paso completado" (o -1 si ninguno).
    final nextIndex = card.learningStep + 1;

    // ¿Se completaron todos los pasos? -> Graduación.
    if (nextIndex >= card.fixedPhaseQueue.length) {
      _graduateToReview(card, settings, now);
      return false;
    }

    // Programar el siguiente paso fijo.
    card.learningStep = nextIndex;

    final intervalDays = card.fixedPhaseQueue[nextIndex];
    _scheduleNextReview(card, intervalDays, now);

    // Repetir "hoy" solo si el intervalo es intra-día (< 1 día).
    return intervalDays < 1.0;
  }

  void _graduateToReview(Flashcard card, DeckSettings settings, DateTime now) {
    card.state = CardState.review;
    card.learningStep = 0;

    // Al graduar, puedes limpiar la cola fija si quieres ahorrar espacio.
    // (No es obligatorio; dejarla también está bien.)
    // card.fixedPhaseQueue = [];

    _applyEbbinghausSuccess(card, settings, now);
  }

  void _ensureFixedQueueInitialized(Flashcard card, DeckSettings settings) {
    if (card.fixedPhaseQueue.isEmpty) {
      // Copiamos para evitar referencias compartidas.
      card.fixedPhaseQueue = List<double>.from(settings.learningSteps);
    }
  }

  // =========================
  // Review (Ebbinghaus)
  // =========================

  bool _handleReviewFailure(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // --- FALLO (Lapse) ---
    card.consecutiveLapses++;
    card.repetitionCount++;

    // Castigo al decayRate (olvidas más rápido ahora).
    // Aumentamos nt, pero lo limitamos para no explotar.
    final bumped = card.decayRate * (1.0 + settings.beta);
    final maxAllowed = settings.initialNt * 2;
    card.decayRate = min(maxAllowed, bumped);

    // A) CASTIGO DURO: leech / reset a relearning
    if (settings.lapseTolerance > 0 &&
        card.consecutiveLapses >= settings.lapseTolerance) {
      card.state = CardState.relearning;
      card.learningStep = -1;
      _ensureFixedQueueInitialized(card, settings);

      // Castigo corto intra-día (10 min) para volver a entrar en la cola.
      _scheduleNextReview(card, _minutesToDays(10), now);
      return true;
    }

    // B) CASTIGO SUAVE
    if (settings.useFixedIntervalOnLapse) {
      final intervalDays = settings.lapseFixedInterval;
      _scheduleNextReview(card, intervalDays, now);
      return intervalDays < 1.0;
    } else {
      // El algoritmo decide (pero con decayRate ya empeorado).
      _calculateAndSchedule(card, settings, now);
      return false; // _calculateAndSchedule fuerza >= 1 día en esta implementación.
    }
  }

  void _applyEbbinghausSuccess(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // Éxito: el olvido se hace más lento (nt baja).
    card.decayRate = card.decayRate * (1.0 - settings.alpha);

    // Evitar valores degenerados.
    if (card.decayRate < 0.0001) {
      card.decayRate = 0.0001;
    }

    _calculateAndSchedule(card, settings, now);
    card.repetitionCount++;
  }

  void _calculateAndSchedule(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // Fórmula: Intervalo = (-ln(P_min) / nt) - Offset
    final pMinSafe = settings.pMin.clamp(1e-6, 0.999999).toDouble();
    final numerator = -log(pMinSafe);

    final tStar = (numerator / card.decayRate) - settings.offset;

    // Intervalo mínimo siempre 1 día para fase Review (diseño actual).
    int intervalDays = max(1, tStar.floor());

    // Fuzz pequeño para evitar picos, solo si el intervalo es grande.
    if (intervalDays > 10) {
      final fuzz = Random().nextInt(3) - 1; // -1, 0, +1
      intervalDays += fuzz;
      intervalDays = max(1, intervalDays);
    }

    _scheduleNextReview(card, intervalDays.toDouble(), now);
  }

  // =========================
  // Scheduling (normalización 04:00)
  // =========================

  void _scheduleNextReview(Flashcard card, double intervalDays, DateTime now) {
    // Permitir fracciones (intra-día): minutos/horas exactas desde "ahora".
    if (intervalDays < 1.0) {
      final minutes = max(1, (intervalDays * 1440).round());
      card.nextReview = now.add(Duration(minutes: minutes));
      return;
    }

    // 1 día o más: usar día calendario + normalizar a las 04:00.
    final days = max(1, intervalDays.ceil());
    final targetDate = now.add(Duration(days: days));

    card.nextReview = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      4, // 04:00 AM
      0,
    );
  }

  double _minutesToDays(int minutes) => minutes / 1440.0;
}
