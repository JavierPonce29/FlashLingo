import 'dart:math';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/utils/study_day.dart';

class SrsService {
  /// Retorna `true` si la carta debe repetirse hoy dentro de la misma sesión
  bool reviewCard(Flashcard card, bool isCorrect, DeckSettings settings) {
    final now = DateTime.now();
    // Contador para desactivar write-mode:
    // Contamos SOLO cuando acierta y SOLO para tarjetas prod.
    // Importante: en fase REVIEW el contador se incrementa en _applyEbbinghausSuccess
    final bool isProd = card.cardType.endsWith('prod');
    if (isCorrect && isProd && card.state != CardState.review) {
      card.repetitionCount++;
    }
    if (card.state == CardState.newCard) {
      // NUEVA: si acierta, entra en learning con pasos fijos.
      if (isCorrect) {
        card.state = CardState.learning;
        card.learningStep = -1;
        // Para nuevas: preprendemos pasos intra-día según configuración.
        _ensureFixedQueueInitialized(card, settings, forNewCard: true);
        // Éxito en learning: avanza un paso
        return _handleLearningSuccess(card, settings, now);
      } else {
        // Si falla, se queda como new y vuelve a aparecer pronto (intra-día).
        card.learningStep = 0;
        _scheduleNextReview(card, _minutesToDays(1), now, settings); // 1 minuto
        return true;
      }
    }
    if (card.state == CardState.learning ||
        card.state == CardState.relearning) {
      if (isCorrect) {
        return _handleLearningSuccess(card, settings, now);
      } else {
        return _handleLearningFailure(card, settings, now);
      }
    }
    // REVIEW
    if (isCorrect) {
      _applyEbbinghausSuccess(card, settings, now);
      return false;
    } else {
      return _applyEbbinghausFailure(card, settings, now);
    }
  }

  // =========================
  // Learning / Relearning
  // =========================

  bool _handleLearningSuccess(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // Reset streak de lapses cuando el usuario acierta
    card.consecutiveLapses = 0;
    if (card.fixedPhaseQueue.isEmpty) {
      card.state = CardState.review;
      card.learningStep = 0;
      _calculateAndSchedule(card, settings, now);
      return false;
    }
    final nextIndex = card.learningStep + 1;
    // Si aún hay pasos por hacer
    if (nextIndex < card.fixedPhaseQueue.length) {
      card.learningStep = nextIndex;
      final intervalDays = card.fixedPhaseQueue[nextIndex];
      _scheduleNextReview(card, intervalDays, now, settings);
      // Repetir hoy si es un intervalo intra-día (< 1 día)
      return intervalDays < 1.0;
    }
    // Termina aprendizaje -> pasa a review
    card.state = CardState.review;
    card.learningStep = 0;
    _calculateAndSchedule(card, settings, now);
    return false;
  }

  bool _handleLearningFailure(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    card.learningStep = -1;
    // Reiniciar cola de pasos
    _ensureFixedQueueInitialized(card, settings);
    // Castigo intra-día
    _scheduleNextReview(card, _minutesToDays(10), now, settings);
    return true;
  }

  // =========================
  // Review
  // =========================

  bool _applyEbbinghausFailure(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // Fallo en REVIEW: incrementa la racha de lapses para que lapseTolerance funcione.
    card.consecutiveLapses++;
    // Fallo: el olvido se hace más rápido (nt sube).
    card.decayRate = card.decayRate * (1.0 + settings.beta);
    // Cap para evitar que se dispare.
    final maxAllowed = 1.0;
    final bumped = card.decayRate;
    card.decayRate = min(maxAllowed, bumped);
    // A) CASTIGO DURO: leech / reset a relearning
    if (settings.lapseTolerance > 0 &&
        card.consecutiveLapses >= settings.lapseTolerance) {
      card.state = CardState.relearning;
      card.learningStep = -1;
      _ensureFixedQueueInitialized(card, settings);
      _scheduleNextReview(card, _minutesToDays(10), now, settings);
      return true;
    }
    // B) CASTIGO SUAVE
    if (settings.useFixedIntervalOnLapse) {
      final intervalDays = settings.lapseFixedInterval;
      _scheduleNextReview(card, intervalDays, now, settings);
      return intervalDays < 1.0;
    } else {
      _calculateAndSchedule(card, settings, now);
      return false; // _calculateAndSchedule fuerza >= 1 día en esta implementación.
    }
  }

  void _applyEbbinghausSuccess(
    Flashcard card,
    DeckSettings settings,
    DateTime now,
  ) {
    // Éxito en REVIEW: reinicia la racha de lapses.
    card.consecutiveLapses = 0;
    // Éxito: el olvido se hace más lento (nt baja).
    card.decayRate = card.decayRate * (1.0 - settings.alpha);
    // Evitar valores degenerados.
    if (card.decayRate < 0.0001) {
      card.decayRate = 0.0001;
    }
    _calculateAndSchedule(card, settings, now);
    // Contador para write-mode:
    if (card.cardType.endsWith('prod')) {
      card.repetitionCount++;
    }
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
    // Intervalo mínimo siempre 1 día para fase Review
    int intervalDays = max(1, tStar.floor());
    // Fuzz pequeño para evitar picos, solo si el intervalo es grande.
    if (intervalDays > 10) {
      final fuzz = Random().nextInt(3) - 1; // -1, 0, +1
      intervalDays += fuzz;
      intervalDays = max(1, intervalDays);
    }
    _scheduleNextReview(card, intervalDays.toDouble(), now, settings);
  }

  // =========================
  // Helpers: fixed queue init
  // =========================

  void _ensureFixedQueueInitialized(
    Flashcard card,
    DeckSettings settings, {
    bool forNewCard = false,
  }) {
    // IMPORTANTE:
    // Para tarjetas NUEVAS, SIEMPRE reconstruimos la cola para inyectar
    // los pasos intra-día (newCardMinCorrectReps / newCardIntraDayMinutes),
    // incluso si la tarjeta ya trae fixedPhaseQueue desde importación.
    if (forNewCard) {
      final minReps = max(1, settings.newCardMinCorrectReps);
      final minutes = max(1, settings.newCardIntraDayMinutes);
      final List<double> queue = [];
      if (minReps > 1) {
        final step = _minutesToDays(minutes);
        for (int i = 0; i < minReps - 1; i++) {
          queue.add(step);
        }
      }
      queue.addAll(settings.learningSteps);
      card.fixedPhaseQueue = List<double>.from(queue);
      return;
    }
    if (card.fixedPhaseQueue.isNotEmpty) return;
    card.fixedPhaseQueue = List<double>.from(settings.learningSteps);
  }

  // =========================
  // Scheduling (día de estudio + cutoff configurable)
  // =========================

  void _scheduleNextReview(
    Flashcard card,
    double intervalDays,
    DateTime now,
    DeckSettings settings,
  ) {
    // Intra-día (< 1.0): minutos/horas exactas desde "ahora".
    if (intervalDays < 1.0) {
      final minutes = max(1, (intervalDays * 1440).round());
      card.nextReview = now.add(Duration(minutes: minutes));
      return;
    }
    // Días (>= 1.0): relativo al "día de estudio" (cutoff) y normalizado al cutoff.
    final days = max(1, intervalDays.ceil());
    final base = StudyDay.start(now, settings);
    final target = base.add(Duration(days: days));
    card.nextReview = target; // ya está en cutoff exacto
  }

  double _minutesToDays(int minutes) => minutes / 1440.0;
}
