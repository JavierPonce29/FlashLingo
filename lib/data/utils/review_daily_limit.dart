import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/utils/study_day.dart';

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

bool isZeroDateTime(DateTime value) => value.millisecondsSinceEpoch == 0;

DateTime reviewDayAnchor(DateTime labelDay, DeckSettings settings) {
  return DateTime(
    labelDay.year,
    labelDay.month,
    labelDay.day,
    StudyDay.cutoffHour(settings),
    StudyDay.cutoffMinute(settings),
  );
}

DateTime effectiveReviewPriorityAnchor(Flashcard card) {
  return isZeroDateTime(card.reviewPriorityAnchor)
      ? card.nextReview
      : card.reviewPriorityAnchor;
}

DateTime? effectiveManualReviewOverrideDay(Flashcard card) {
  return isZeroDateTime(card.manualReviewOverrideDay)
      ? null
      : card.manualReviewOverrideDay;
}

void markFlashcardManuallyAvailableToday(
  Flashcard card,
  DeckSettings settings,
  DateTime now,
) {
  final labelToday = StudyDay.label(now, settings);
  card.nextReview = now;
  card.reviewPriorityAnchor = reviewDayAnchor(labelToday, settings);
  card.manualReviewOverrideDay = labelToday;
}

class ReviewDailyLimitEntry<T> {
  final T item;
  final DateTime scheduledDay;
  final DateTime priorityAnchor;
  final DateTime? manualOverrideDay;
  final int stableOrder;

  const ReviewDailyLimitEntry({
    required this.item,
    required this.scheduledDay,
    required this.priorityAnchor,
    required this.manualOverrideDay,
    required this.stableOrder,
  });
}

class ReviewDailyLimitAssignment<T> {
  final T item;
  final DateTime scheduledDay;
  final DateTime assignedDay;
  final DateTime priorityAnchor;
  final bool isManualOverrideToday;

  const ReviewDailyLimitAssignment({
    required this.item,
    required this.scheduledDay,
    required this.assignedDay,
    required this.priorityAnchor,
    required this.isManualOverrideToday,
  });

  bool get wasDeferred => assignedDay.isAfter(scheduledDay);
}

class ReviewDailyLimitPlan<T> {
  final DateTime today;
  final int maxReviewsPerDay;
  final List<ReviewDailyLimitAssignment<T>> assignments;
  final int overflowTodayCount;

  const ReviewDailyLimitPlan({
    required this.today,
    required this.maxReviewsPerDay,
    required this.assignments,
    required this.overflowTodayCount,
  });

  bool get hasOverflowToday => overflowTodayCount > 0;

  Iterable<ReviewDailyLimitAssignment<T>> assignmentsForDay(DateTime day) {
    return assignments.where((assignment) => _sameDay(assignment.assignedDay, day));
  }
}

ReviewDailyLimitPlan<T> planReviewDailyLimit<T>({
  required Iterable<ReviewDailyLimitEntry<T>> entries,
  required DateTime today,
  required int maxReviewsPerDay,
}) {
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final source = entries.toList(growable: false);

  if (maxReviewsPerDay <= 0) {
    return ReviewDailyLimitPlan<T>(
      today: normalizedToday,
      maxReviewsPerDay: maxReviewsPerDay,
      overflowTodayCount: 0,
      assignments: source
          .map(
            (entry) => ReviewDailyLimitAssignment<T>(
              item: entry.item,
              scheduledDay: entry.scheduledDay,
              assignedDay: entry.scheduledDay,
              priorityAnchor: entry.priorityAnchor,
              isManualOverrideToday:
                  entry.manualOverrideDay != null &&
                  _sameDay(entry.manualOverrideDay!, normalizedToday),
            ),
          )
          .toList(growable: false),
    );
  }

  final manualToday = <ReviewDailyLimitEntry<T>>[];
  final automatic = <ReviewDailyLimitEntry<T>>[];
  for (final entry in source) {
    final manualDay = entry.manualOverrideDay;
    if (manualDay != null && _sameDay(manualDay, normalizedToday)) {
      manualToday.add(entry);
      continue;
    }
    automatic.add(entry);
  }

  int compareEntries(
    ReviewDailyLimitEntry<T> a,
    ReviewDailyLimitEntry<T> b,
  ) {
    final priorityCompare = a.priorityAnchor.compareTo(b.priorityAnchor);
    if (priorityCompare != 0) return priorityCompare;
    final scheduledCompare = a.scheduledDay.compareTo(b.scheduledDay);
    if (scheduledCompare != 0) return scheduledCompare;
    return a.stableOrder.compareTo(b.stableOrder);
  }

  manualToday.sort(compareEntries);
  automatic.sort(compareEntries);

  final assignments = <ReviewDailyLimitAssignment<T>>[];
  for (final entry in manualToday) {
    assignments.add(
      ReviewDailyLimitAssignment<T>(
        item: entry.item,
        scheduledDay: entry.scheduledDay,
        assignedDay: normalizedToday,
        priorityAnchor: entry.priorityAnchor,
        isManualOverrideToday: true,
      ),
    );
  }

  final capacityByDay = <DateTime, int>{};
  int overflowTodayCount = 0;
  for (final entry in automatic) {
    var candidateDay = entry.scheduledDay.isBefore(normalizedToday)
        ? normalizedToday
        : entry.scheduledDay;
    while ((capacityByDay[candidateDay] ?? maxReviewsPerDay) <= 0) {
      candidateDay = candidateDay.add(const Duration(days: 1));
    }
    capacityByDay[candidateDay] =
        (capacityByDay[candidateDay] ?? maxReviewsPerDay) - 1;
    if (!entry.scheduledDay.isAfter(normalizedToday) &&
        candidateDay.isAfter(normalizedToday)) {
      overflowTodayCount++;
    }
    assignments.add(
      ReviewDailyLimitAssignment<T>(
        item: entry.item,
        scheduledDay: entry.scheduledDay,
        assignedDay: candidateDay,
        priorityAnchor: entry.priorityAnchor,
        isManualOverrideToday: false,
      ),
    );
  }

  return ReviewDailyLimitPlan<T>(
    today: normalizedToday,
    maxReviewsPerDay: maxReviewsPerDay,
    assignments: assignments,
    overflowTodayCount: overflowTodayCount,
  );
}

ReviewDailyLimitPlan<Flashcard> planFlashcardReviewDailyLimit({
  required List<Flashcard> cards,
  required DeckSettings settings,
  required DateTime now,
}) {
  final labelToday = StudyDay.label(now, settings);
  return planReviewDailyLimit<Flashcard>(
    today: labelToday,
    maxReviewsPerDay: settings.maxReviewsPerDay,
    entries: [
      for (int index = 0; index < cards.length; index++)
        ReviewDailyLimitEntry<Flashcard>(
          item: cards[index],
          scheduledDay: StudyDay.label(cards[index].nextReview, settings),
          priorityAnchor: effectiveReviewPriorityAnchor(cards[index]),
          manualOverrideDay: effectiveManualReviewOverrideDay(cards[index]),
          stableOrder: index,
        ),
    ],
  );
}

class FlashcardReviewDailyLimitSyncResult {
  final ReviewDailyLimitPlan<Flashcard> plan;
  final List<Flashcard> changedCards;

  const FlashcardReviewDailyLimitSyncResult({
    required this.plan,
    required this.changedCards,
  });
}

FlashcardReviewDailyLimitSyncResult syncFlashcardReviewDailyLimit({
  required List<Flashcard> cards,
  required DeckSettings settings,
  required DateTime now,
}) {
  final plan = planFlashcardReviewDailyLimit(
    cards: cards,
    settings: settings,
    now: now,
  );
  final labelToday = StudyDay.label(now, settings);
  final changedCards = <Flashcard>[];

  for (final assignment in plan.assignments) {
    final card = assignment.item;
    bool changed = false;
    final currentScheduledDay = StudyDay.label(card.nextReview, settings);
    final currentPriority = effectiveReviewPriorityAnchor(card);
    final currentManualDay = effectiveManualReviewOverrideDay(card);

    if (isZeroDateTime(card.reviewPriorityAnchor)) {
      card.reviewPriorityAnchor = currentPriority;
      changed = true;
    }

    if (currentManualDay != null && !_sameDay(currentManualDay, labelToday)) {
      card.manualReviewOverrideDay = _epoch;
      changed = true;
    }

    if (!assignment.isManualOverrideToday &&
        assignment.assignedDay.isAfter(currentScheduledDay)) {
      card.nextReview = reviewDayAnchor(assignment.assignedDay, settings);
      card.reviewPriorityAnchor = currentPriority;
      card.manualReviewOverrideDay = _epoch;
      changed = true;
    }

    if (!assignment.isManualOverrideToday &&
        currentManualDay != null &&
        _sameDay(currentManualDay, labelToday)) {
      card.manualReviewOverrideDay = _epoch;
      changed = true;
    }

    if (assignment.isManualOverrideToday &&
        (currentManualDay == null || !_sameDay(currentManualDay, labelToday))) {
      card.manualReviewOverrideDay = labelToday;
      changed = true;
    }

    if (changed) {
      changedCards.add(card);
    }
  }

  return FlashcardReviewDailyLimitSyncResult(
    plan: plan,
    changedCards: changedCards,
  );
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
