import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/data/utils/review_daily_limit.dart';
import 'package:flashcards_app/data/utils/study_day.dart';

class DeckCardInsight {
  final int id;
  final String question;
  final String cardType;
  final CardState state;
  final DateTime nextReview;
  final DateTime lastReview;
  final int lifetimeReviewCount;
  final int lifetimeCorrectCount;
  final int lifetimeWrongCount;
  final int totalStudyTimeMs;
  final int consecutiveLapses;
  final int overdueDays;
  final int averageStudyTimeMs;
  final double difficultyScore;
  final List<String> problemTags;

  DeckCardInsight({
    required this.id,
    required this.question,
    required this.cardType,
    required this.state,
    required this.nextReview,
    required this.lastReview,
    required this.lifetimeReviewCount,
    required this.lifetimeCorrectCount,
    required this.lifetimeWrongCount,
    required this.totalStudyTimeMs,
    required this.consecutiveLapses,
    required this.overdueDays,
    required this.averageStudyTimeMs,
    required this.difficultyScore,
    required this.problemTags,
  });

  double get accuracy =>
      lifetimeReviewCount == 0 ? 0 : lifetimeCorrectCount / lifetimeReviewCount;
}

class DeckSessionInsight {
  final String sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int answerCount;
  final int correctCount;
  final int wrongCount;
  final int uniqueCardCount;
  final int totalStudyTimeMs;
  final int averageAnswerTimeMs;

  DeckSessionInsight({
    required this.sessionId,
    required this.startedAt,
    required this.endedAt,
    required this.answerCount,
    required this.correctCount,
    required this.wrongCount,
    required this.uniqueCardCount,
    required this.totalStudyTimeMs,
    required this.averageAnswerTimeMs,
  });

  double get accuracy => answerCount == 0 ? 0 : correctCount / answerCount;
}

class DeckStatsData {
  final DeckSettings settings;
  final DateTime labelToday;
  final List<Flashcard> cardSnapshots;
  final List<DeckDailyStats> dailyStatsRows;
  final int totalCards;
  final int newAvailableToday;
  final int newCards;
  final int learningDueNow;
  final int learningCards;
  final int reviewDueNow;
  final int reviewCards;
  final int overdueCards;
  final int relearningCards;
  final int lifetimeReviewCount;
  final int lifetimeCorrectCount;
  final int lifetimeWrongCount;
  final int totalStudyTimeMs;
  final int averageAnswerTimeMs;
  final int reviewCount7d;
  final int correctCount7d;
  final int reviewCount30d;
  final int correctCount30d;
  final int studyTime7dMs;
  final int studyTime30dMs;
  final int sessionCount7d;
  final int sessionCount30d;
  final int activeDays7d;
  final int activeDays30d;
  final List<DeckCardInsight> hardestCards;
  final List<DeckCardInsight> problemCards;
  final List<DeckSessionInsight> recentSessions;

  DeckStatsData({
    required this.settings,
    required this.labelToday,
    required this.cardSnapshots,
    required this.dailyStatsRows,
    required this.totalCards,
    required this.newAvailableToday,
    required this.newCards,
    required this.learningDueNow,
    required this.learningCards,
    required this.reviewDueNow,
    required this.reviewCards,
    required this.overdueCards,
    required this.relearningCards,
    required this.lifetimeReviewCount,
    required this.lifetimeCorrectCount,
    required this.lifetimeWrongCount,
    required this.totalStudyTimeMs,
    required this.averageAnswerTimeMs,
    required this.reviewCount7d,
    required this.correctCount7d,
    required this.reviewCount30d,
    required this.correctCount30d,
    required this.studyTime7dMs,
    required this.studyTime30dMs,
    required this.sessionCount7d,
    required this.sessionCount30d,
    required this.activeDays7d,
    required this.activeDays30d,
    required this.hardestCards,
    required this.problemCards,
    required this.recentSessions,
  });

  double get lifetimeAccuracy =>
      lifetimeReviewCount == 0 ? 0 : lifetimeCorrectCount / lifetimeReviewCount;

  double get accuracy7d =>
      reviewCount7d == 0 ? 0 : correctCount7d / reviewCount7d;

  double get accuracy30d =>
      reviewCount30d == 0 ? 0 : correctCount30d / reviewCount30d;

  double get reviewsPerDay7d => reviewCount7d / 7;

  double get reviewsPerDay30d => reviewCount30d / 30;

  double get studyTimePerDay7dMs => studyTime7dMs / 7;

  double get studyTimePerDay30dMs => studyTime30dMs / 30;

  double get sessionsPerDay7d => sessionCount7d / 7;

  double get sessionsPerDay30d => sessionCount30d / 30;

  DateTime? get firstStudyDay =>
      dailyStatsRows.isEmpty ? null : dailyStatsRows.first.studyDay;

  int get deckLifeDays {
    final firstDay = firstStudyDay;
    if (firstDay == null) return 1;
    return math.max(1, labelToday.difference(firstDay).inDays + 1);
  }
}

Future<DeckStatsData> _computeDeckStats(Isar isar, String packName) async {
  final now = DateTime.now();
  final settings =
      await isar.deckSettings.filter().packNameEqualTo(packName).findFirst() ??
      (DeckSettings()..packName = packName);

  final labelToday = StudyDay.label(now, settings);
  final last = settings.lastNewCardStudyDate;
  final lastLabel = last == null ? null : StudyDay.label(last, settings);
  final isSameStudyDay =
      lastLabel != null &&
      lastLabel.year == labelToday.year &&
      lastLabel.month == labelToday.month &&
      lastLabel.day == labelToday.day;
  final effectiveNewCardsSeenToday = isSameStudyDay
      ? settings.newCardsSeenToday
      : 0;
  final remainingQuota = math.max(
    0,
    settings.newCardsPerDay - effectiveNewCardsSeenToday,
  );

  final cards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .findAll();
  final nonNewCards = cards
      .where((card) => card.state != CardState.newCard)
      .toList(growable: false);
  final reviewPlan = planFlashcardReviewDailyLimit(
    cards: nonNewCards,
    settings: settings,
    now: now,
  );
  final planByCardId = <int, ReviewDailyLimitAssignment<Flashcard>>{
    for (final assignment in reviewPlan.assignments) assignment.item.id: assignment,
  };
  final dailyStatsRows = await isar.deckDailyStats
      .filter()
      .packNameEqualTo(packName)
      .sortByStudyDay()
      .findAll();

  int newCards = 0;
  int learningCards = 0;
  int reviewCards = 0;
  int relearningCards = 0;
  int learningDueNow = 0;
  int reviewDueNow = 0;
  int overdueCards = 0;
  int lifetimeReviewCount = 0;
  int lifetimeCorrectCount = 0;
  int lifetimeWrongCount = 0;
  int totalStudyTimeMs = 0;
  final insights = <DeckCardInsight>[];

  for (final card in cards) {
    switch (card.state) {
      case CardState.newCard:
        newCards++;
        break;
      case CardState.learning:
        learningCards++;
        break;
      case CardState.review:
        reviewCards++;
        break;
      case CardState.relearning:
        relearningCards++;
        break;
    }

    lifetimeReviewCount += card.lifetimeReviewCount;
    lifetimeCorrectCount += card.lifetimeCorrectCount;
    lifetimeWrongCount += card.lifetimeWrongCount;
    totalStudyTimeMs += card.totalStudyTimeMs;

    if (card.state == CardState.newCard) {
      continue;
    }

    final assignment = planByCardId[card.id];
    final scheduledDay =
        assignment?.scheduledDay ?? StudyDay.label(card.nextReview, settings);
    final assignedDay = assignment?.assignedDay ?? scheduledDay;
    final effectiveNextReview =
        assignedDay.isAfter(scheduledDay)
            ? reviewDayAnchor(assignedDay, settings)
            : card.nextReview;
    final isDueNow =
        _sameDay(assignedDay, labelToday) && !card.nextReview.isAfter(now);
    final isLearningCard =
        card.state == CardState.learning || card.state == CardState.relearning;
    if (isDueNow) {
      if (isLearningCard) {
        learningDueNow++;
      } else if (card.state == CardState.review) {
        reviewDueNow++;
      }
    }

    final overdueDays =
        _sameDay(assignedDay, labelToday) && scheduledDay.isBefore(labelToday)
            ? labelToday.difference(scheduledDay).inDays
            : 0;
    if (overdueDays > 0) {
      overdueCards++;
    }

    final averageStudyTimeMs = card.lifetimeReviewCount == 0
        ? 0
        : (card.totalStudyTimeMs / card.lifetimeReviewCount).round();
    final accuracy = card.lifetimeReviewCount == 0
        ? 0.0
        : card.lifetimeCorrectCount / card.lifetimeReviewCount;
    final problemTags = <String>[];
    if (overdueDays > 0) {
      problemTags.add('overdue');
    }
    if (card.lifetimeReviewCount >= 3 && accuracy < 0.75) {
      problemTags.add('low_accuracy');
    }
    if (card.consecutiveLapses >= 2 || card.state == CardState.relearning) {
      problemTags.add('lapses');
    }
    if (card.lifetimeReviewCount >= 3 && averageStudyTimeMs >= 15000) {
      problemTags.add('slow');
    }

    final difficultyScore =
        ((1 - accuracy) * 40) +
        math.min(25, overdueDays * 4) +
        math.min(20, card.consecutiveLapses * 6) +
        math.min(10, averageStudyTimeMs / 2500) +
        math.min(5, card.decayRate * 100) +
        (card.state == CardState.relearning ? 8 : 0);

    if (difficultyScore <= 0 && problemTags.isEmpty) {
      continue;
    }

    insights.add(
      DeckCardInsight(
        id: card.id,
        question: card.question,
        cardType: card.cardType,
        state: card.state,
        nextReview: effectiveNextReview,
        lastReview: card.lastReview,
        lifetimeReviewCount: card.lifetimeReviewCount,
        lifetimeCorrectCount: card.lifetimeCorrectCount,
        lifetimeWrongCount: card.lifetimeWrongCount,
        totalStudyTimeMs: card.totalStudyTimeMs,
        consecutiveLapses: card.consecutiveLapses,
        overdueDays: overdueDays,
        averageStudyTimeMs: averageStudyTimeMs,
        difficultyScore: difficultyScore,
        problemTags: problemTags,
      ),
    );
  }

  final stats7dStart = labelToday.subtract(const Duration(days: 6));
  final stats30dStart = labelToday.subtract(const Duration(days: 29));
  int reviewCount7d = 0;
  int correctCount7d = 0;
  int reviewCount30d = 0;
  int correctCount30d = 0;
  int studyTime7dMs = 0;
  int studyTime30dMs = 0;
  int sessionCount7d = 0;
  int sessionCount30d = 0;
  int activeDays7d = 0;
  int activeDays30d = 0;

  for (final row in dailyStatsRows) {
    if (!row.studyDay.isBefore(stats30dStart)) {
      reviewCount30d += row.reviewCount;
      correctCount30d += row.correctCount;
      studyTime30dMs += row.totalStudyTimeMs;
      sessionCount30d += row.sessionCount;
      if (row.reviewCount > 0) {
        activeDays30d++;
      }
    }
    if (!row.studyDay.isBefore(stats7dStart)) {
      reviewCount7d += row.reviewCount;
      correctCount7d += row.correctCount;
      studyTime7dMs += row.totalStudyTimeMs;
      sessionCount7d += row.sessionCount;
      if (row.reviewCount > 0) {
        activeDays7d++;
      }
    }
  }

  final sessionHistories = await isar.studySessionHistorys
      .filter()
      .packNameEqualTo(packName)
      .sortByEndedAtDesc()
      .limit(5)
      .findAll();
  final recentSessions = sessionHistories
      .map(
        (session) => DeckSessionInsight(
          sessionId: session.sessionId,
          startedAt: session.startedAt,
          endedAt: session.endedAt,
          answerCount: session.answerCount,
          correctCount: session.correctCount,
          wrongCount: session.wrongCount,
          uniqueCardCount: session.uniqueCardCount,
          totalStudyTimeMs: session.totalStudyTimeMs,
          averageAnswerTimeMs: session.averageAnswerTimeMs,
        ),
      )
      .toList();

  final sortedByDifficulty = List<DeckCardInsight>.from(insights)
    ..sort((a, b) => b.difficultyScore.compareTo(a.difficultyScore));
  final sortedProblemCards =
      insights
          .where(
            (card) =>
                card.problemTags.isNotEmpty ||
                card.overdueDays > 0 ||
                card.difficultyScore >= 20,
          )
          .toList()
        ..sort((a, b) {
          final overdueCompare = b.overdueDays.compareTo(a.overdueDays);
          if (overdueCompare != 0) return overdueCompare;
          return b.difficultyScore.compareTo(a.difficultyScore);
        });

  return DeckStatsData(
    settings: settings,
    labelToday: labelToday,
    cardSnapshots: cards,
    dailyStatsRows: dailyStatsRows,
    totalCards: cards.length,
    newAvailableToday:
        (settings.hideNewCardsOnReviewOverflow && reviewPlan.hasOverflowToday)
            ? 0
            : math.min(newCards, remainingQuota),
    newCards: newCards,
    learningDueNow: learningDueNow,
    learningCards: learningCards,
    reviewDueNow: reviewDueNow,
    reviewCards: reviewCards,
    overdueCards: overdueCards,
    relearningCards: relearningCards,
    lifetimeReviewCount: lifetimeReviewCount,
    lifetimeCorrectCount: lifetimeCorrectCount,
    lifetimeWrongCount: lifetimeWrongCount,
    totalStudyTimeMs: totalStudyTimeMs,
    averageAnswerTimeMs: lifetimeReviewCount == 0
        ? 0
        : (totalStudyTimeMs / lifetimeReviewCount).round(),
    reviewCount7d: reviewCount7d,
    correctCount7d: correctCount7d,
    reviewCount30d: reviewCount30d,
    correctCount30d: correctCount30d,
    studyTime7dMs: studyTime7dMs,
    studyTime30dMs: studyTime30dMs,
    sessionCount7d: sessionCount7d,
    sessionCount30d: sessionCount30d,
    activeDays7d: activeDays7d,
    activeDays30d: activeDays30d,
    hardestCards: sortedByDifficulty.take(5).toList(),
    problemCards: sortedProblemCards.take(8).toList(),
    recentSessions: recentSessions,
  );
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final deckStatsProvider = StreamProvider.family
    .autoDispose<DeckStatsData, String>((ref, packName) async* {
      final isar = await ref.watch(isarDbProvider.future);

      Future<DeckStatsData> compute() => _computeDeckStats(isar, packName);

      yield await compute();

      final controller = StreamController<void>(sync: true);
      final sub1 = isar.flashcards
          .filter()
          .packNameEqualTo(packName)
          .watchLazy()
          .listen((_) {
            if (!controller.isClosed) controller.add(null);
          });
      final sub2 = isar.deckDailyStats
          .filter()
          .packNameEqualTo(packName)
          .watchLazy()
          .listen((_) {
            if (!controller.isClosed) controller.add(null);
          });
      final sub3 = isar.deckSettings
          .filter()
          .packNameEqualTo(packName)
          .watchLazy()
          .listen((_) {
            if (!controller.isClosed) controller.add(null);
          });
      final sub4 = isar.studySessionHistorys
          .filter()
          .packNameEqualTo(packName)
          .watchLazy()
          .listen((_) {
            if (!controller.isClosed) controller.add(null);
          });

      ref.onDispose(() async {
        await sub1.cancel();
        await sub2.cancel();
        await sub3.cancel();
        await sub4.cancel();
        await controller.close();
      });

      await for (final _ in controller.stream) {
        yield await compute();
      }
    });
