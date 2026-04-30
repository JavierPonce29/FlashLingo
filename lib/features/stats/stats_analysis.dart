import 'dart:async';
import 'dart:math' as math;

import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

enum StatsRangeOption { days7, days18, month1, months3, months6, year1, life }

enum IntervalRangeOption { month1, months3, lifeHalf, lifeFull }

enum HourlySlotOption { hourly, halfHourly, quarterHourly }

typedef StatsComputationProgressCallback = void Function(double progress);

class MonthHeatmapSlice {
  final DateTime monthStart;
  final DateTime monthEnd;
  final Map<DateTime, int> values;

  const MonthHeatmapSlice({
    required this.monthStart,
    required this.monthEnd,
    required this.values,
  });
}

class StackedForecastPoint {
  final DateTime day;
  final int overdue;
  final int learning;
  final int review;
  final int newCards;

  const StackedForecastPoint({
    required this.day,
    required this.overdue,
    required this.learning,
    required this.review,
    required this.newCards,
  });

  int get total => overdue + learning + review + newCards;
}

class StudyTimePoint {
  final DateTime day;
  final int studyTimeMs;

  const StudyTimePoint({required this.day, required this.studyTimeMs});
}

class IntervalHistogramPoint {
  final int intervalDay;
  final int count;

  const IntervalHistogramPoint({
    required this.intervalDay,
    required this.count,
  });
}

class HourlyDistributionPoint {
  final int slotIndex;
  final int slotMinutes;
  final int count;

  const HourlyDistributionPoint({
    required this.slotIndex,
    required this.slotMinutes,
    required this.count,
  });
}

class PredictionTimelinePoint {
  final int offset;
  final DateTime day;
  final int predictedNew;
  final int predictedLearning;
  final int predictedReview;
  final int actualNew;
  final int actualReview;
  final int actualStudyTimeMs;
  final double predictedMinutes;

  const PredictionTimelinePoint({
    required this.offset,
    required this.day,
    required this.predictedNew,
    required this.predictedLearning,
    required this.predictedReview,
    required this.actualNew,
    required this.actualReview,
    required this.actualStudyTimeMs,
    required this.predictedMinutes,
  });
}

int rangeDaysForOption(StatsRangeOption option, DeckStatsData data) {
  switch (option) {
    case StatsRangeOption.days7:
      return 7;
    case StatsRangeOption.days18:
      return 18;
    case StatsRangeOption.month1:
      return 30;
    case StatsRangeOption.months3:
      return 90;
    case StatsRangeOption.months6:
      return 180;
    case StatsRangeOption.year1:
      return 365;
    case StatsRangeOption.life:
      return data.deckLifeDays;
  }
}

int forecastRangeDaysForOption(StatsRangeOption option, DeckStatsData data) {
  if (option != StatsRangeOption.life) {
    return rangeDaysForOption(option, data);
  }
  int maxExisting = 0;
  for (final card in data.cardSnapshots) {
    if (card.state == CardState.newCard) continue;
    final diff = StudyDay.label(
      card.nextReview,
      data.settings,
    ).difference(data.labelToday).inDays;
    if (diff > maxExisting) {
      maxExisting = diff;
    }
  }
  final remainingNew = data.cardSnapshots
      .where((card) => card.state == CardState.newCard)
      .length;
  final newRunway = data.settings.newCardsPerDay > 0
      ? (remainingNew / data.settings.newCardsPerDay).ceil()
      : 0;
  return math.max(18, math.max(maxExisting, newRunway));
}

int intervalRangeMaxDays(IntervalRangeOption option, DeckStatsData data) {
  int maxInterval = 0;
  for (final card in data.cardSnapshots) {
    final interval = math.max(
      0,
      StudyDay.label(
        card.nextReview,
        data.settings,
      ).difference(data.labelToday).inDays,
    );
    if (interval > maxInterval) {
      maxInterval = interval;
    }
  }
  switch (option) {
    case IntervalRangeOption.month1:
      return 30;
    case IntervalRangeOption.months3:
      return 90;
    case IntervalRangeOption.lifeHalf:
      return math.max(1, (maxInterval / 2).ceil());
    case IntervalRangeOption.lifeFull:
      return math.max(1, maxInterval);
  }
}

int hourlySlotMinutes(HourlySlotOption option) {
  switch (option) {
    case HourlySlotOption.hourly:
      return 60;
    case HourlySlotOption.halfHourly:
      return 30;
    case HourlySlotOption.quarterHourly:
      return 15;
  }
}

List<MonthHeatmapSlice> buildHeatmapSlices(
  DeckStatsData data, {
  required bool uniqueCards,
}) {
  final valuesByDay = <DateTime, int>{};
  for (final row in data.dailyStatsRows) {
    valuesByDay[row.studyDay] = uniqueCards
        ? row.uniqueCardCount
        : row.reviewCount;
  }

  final firstDay = data.firstStudyDay ?? data.labelToday;
  final firstMonth = DateTime(firstDay.year, firstDay.month);
  final currentMonth = DateTime(data.labelToday.year, data.labelToday.month);
  final slices = <MonthHeatmapSlice>[];

  DateTime month = firstMonth;
  while (!month.isAfter(currentMonth)) {
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final monthValues = <DateTime, int>{};
    valuesByDay.forEach((day, value) {
      if (day.year == month.year && day.month == month.month) {
        monthValues[day] = value;
      }
    });
    slices.add(
      MonthHeatmapSlice(
        monthStart: month,
        monthEnd: monthEnd,
        values: monthValues,
      ),
    );
    month = DateTime(month.year, month.month + 1);
  }
  return slices.reversed.toList();
}

List<StackedForecastPoint> buildForecastSeries(
  DeckStatsData data,
  StatsRangeOption option,
) {
  final days = forecastRangeDaysForOption(option, data);
  final points = List<StackedForecastPoint>.generate(
    days,
    (index) => StackedForecastPoint(
      day: data.labelToday.add(Duration(days: index)),
      overdue: 0,
      learning: 0,
      review: 0,
      newCards: 0,
    ),
  );
  final buckets = List<_MutableForecastBucket>.generate(
    days,
    (index) => _MutableForecastBucket(day: points[index].day),
  );

  for (final card in data.cardSnapshots) {
    if (card.state == CardState.newCard) continue;
    final reviewLabel = StudyDay.label(card.nextReview, data.settings);
    final isLearning =
        card.state == CardState.learning || card.state == CardState.relearning;
    if (reviewLabel.isBefore(data.labelToday)) {
      buckets.first.overdue++;
      continue;
    }
    final diff = reviewLabel.difference(data.labelToday).inDays;
    if (diff < 0 || diff >= days) continue;
    if (isLearning) {
      buckets[diff].learning++;
    } else if (card.state == CardState.review) {
      buckets[diff].review++;
    }
  }

  final remainingNew = data.cardSnapshots
      .where((card) => card.state == CardState.newCard)
      .length;
  final remainingQuotaToday = _remainingNewQuotaToday(
    data.settings,
    data.labelToday,
  );
  if (remainingNew > 0 && remainingQuotaToday > 0) {
    buckets.first.newCards = math.min(remainingNew, remainingQuotaToday);
  }

  return buckets
      .map(
        (bucket) => StackedForecastPoint(
          day: bucket.day,
          overdue: bucket.overdue,
          learning: bucket.learning,
          review: bucket.review,
          newCards: bucket.newCards,
        ),
      )
      .toList();
}

Future<List<StackedForecastPoint>> buildForecastSeriesAsync(
  DeckStatsData data,
  StatsRangeOption option, {
  StatsComputationProgressCallback? onProgress,
}) async {
  final days = forecastRangeDaysForOption(option, data);
  final points = List<StackedForecastPoint>.generate(
    days,
    (index) => StackedForecastPoint(
      day: data.labelToday.add(Duration(days: index)),
      overdue: 0,
      learning: 0,
      review: 0,
      newCards: 0,
    ),
  );
  final buckets = List<_MutableForecastBucket>.generate(
    days,
    (index) => _MutableForecastBucket(day: points[index].day),
  );

  final cards = data.cardSnapshots;
  final progressStep = _progressStep(cards.length);
  _reportProgress(onProgress, 0);
  for (int index = 0; index < cards.length; index++) {
    final card = cards[index];
    if (card.state != CardState.newCard) {
      final reviewLabel = StudyDay.label(card.nextReview, data.settings);
      final isLearning =
          card.state == CardState.learning ||
          card.state == CardState.relearning;
      if (reviewLabel.isBefore(data.labelToday)) {
        buckets.first.overdue++;
      } else {
        final diff = reviewLabel.difference(data.labelToday).inDays;
        if (diff >= 0 && diff < days) {
          if (isLearning) {
            buckets[diff].learning++;
          } else if (card.state == CardState.review) {
            buckets[diff].review++;
          }
        }
      }
    }

    if (_shouldYieldProgress(index + 1, cards.length, progressStep)) {
      await _yieldProgress(
        onProgress,
        _fraction(index + 1, cards.length) * 0.88,
      );
    }
  }

  final remainingNew = cards
      .where((card) => card.state == CardState.newCard)
      .length;
  final remainingQuotaToday = _remainingNewQuotaToday(
    data.settings,
    data.labelToday,
  );
  if (remainingNew > 0 && remainingQuotaToday > 0) {
    buckets.first.newCards = math.min(remainingNew, remainingQuotaToday);
  }

  _reportProgress(onProgress, 1);
  return buckets
      .map(
        (bucket) => StackedForecastPoint(
          day: bucket.day,
          overdue: bucket.overdue,
          learning: bucket.learning,
          review: bucket.review,
          newCards: bucket.newCards,
        ),
      )
      .toList();
}

int _remainingNewQuotaToday(DeckSettings settings, DateTime labelToday) {
  final last = settings.lastNewCardStudyDate;
  if (last == null) {
    return settings.newCardsPerDay;
  }
  final lastLabel = StudyDay.label(last, settings);
  final isSameStudyDay =
      lastLabel.year == labelToday.year &&
      lastLabel.month == labelToday.month &&
      lastLabel.day == labelToday.day;
  final seenToday = isSameStudyDay ? settings.newCardsSeenToday : 0;
  return math.max(0, settings.newCardsPerDay - seenToday);
}

List<StudyTimePoint> buildStudyTimeSeries(
  DeckStatsData data,
  StatsRangeOption option,
) {
  final days = rangeDaysForOption(option, data);
  final startDay = data.labelToday.subtract(Duration(days: days - 1));
  final map = {
    for (final row in data.dailyStatsRows) row.studyDay: row.totalStudyTimeMs,
  };
  return List<StudyTimePoint>.generate(days, (index) {
    final day = startDay.add(Duration(days: index));
    return StudyTimePoint(day: day, studyTimeMs: map[day] ?? 0);
  });
}

Future<List<StudyTimePoint>> buildStudyTimeSeriesAsync(
  DeckStatsData data,
  StatsRangeOption option, {
  StatsComputationProgressCallback? onProgress,
}) async {
  final days = rangeDaysForOption(option, data);
  final startDay = data.labelToday.subtract(Duration(days: days - 1));
  final map = <DateTime, int>{};
  final rows = data.dailyStatsRows;
  final rowStep = _progressStep(rows.length);
  _reportProgress(onProgress, 0);
  for (int index = 0; index < rows.length; index++) {
    final row = rows[index];
    map[row.studyDay] = row.totalStudyTimeMs;
    if (_shouldYieldProgress(index + 1, rows.length, rowStep)) {
      await _yieldProgress(
        onProgress,
        _fraction(index + 1, rows.length) * 0.45,
      );
    }
  }

  final points = <StudyTimePoint>[];
  final dayStep = _progressStep(days);
  for (int index = 0; index < days; index++) {
    final day = startDay.add(Duration(days: index));
    points.add(StudyTimePoint(day: day, studyTimeMs: map[day] ?? 0));
    if (_shouldYieldProgress(index + 1, days, dayStep)) {
      await _yieldProgress(
        onProgress,
        0.45 + (_fraction(index + 1, days) * 0.55),
      );
    }
  }

  _reportProgress(onProgress, 1);
  return points;
}

List<IntervalHistogramPoint> buildIntervalHistogram(
  DeckStatsData data,
  IntervalRangeOption option,
) {
  final maxDays = intervalRangeMaxDays(option, data);
  if (maxDays <= 0) {
    return const <IntervalHistogramPoint>[];
  }
  final counts = <int, int>{for (int i = 1; i <= maxDays; i++) i: 0};
  for (final card in data.cardSnapshots) {
    final interval = math.max(
      0,
      StudyDay.label(
        card.nextReview,
        data.settings,
      ).difference(data.labelToday).inDays,
    );
    if (interval <= 0 || interval > maxDays) continue;
    counts[interval] = (counts[interval] ?? 0) + 1;
  }
  return counts.entries
      .map(
        (entry) =>
            IntervalHistogramPoint(intervalDay: entry.key, count: entry.value),
      )
      .toList();
}

Future<List<IntervalHistogramPoint>> buildIntervalHistogramAsync(
  DeckStatsData data,
  IntervalRangeOption option, {
  StatsComputationProgressCallback? onProgress,
}) async {
  final maxDays = intervalRangeMaxDays(option, data);
  if (maxDays <= 0) {
    _reportProgress(onProgress, 1);
    return const <IntervalHistogramPoint>[];
  }

  final counts = <int, int>{};
  final initStep = _progressStep(maxDays);
  _reportProgress(onProgress, 0);
  for (int day = 1; day <= maxDays; day++) {
    counts[day] = 0;
    if (_shouldYieldProgress(day, maxDays, initStep)) {
      await _yieldProgress(onProgress, _fraction(day, maxDays) * 0.25);
    }
  }

  final cards = data.cardSnapshots;
  final cardStep = _progressStep(cards.length);
  for (int index = 0; index < cards.length; index++) {
    final card = cards[index];
    final interval = math.max(
      0,
      StudyDay.label(
        card.nextReview,
        data.settings,
      ).difference(data.labelToday).inDays,
    );
    if (interval > 0 && interval <= maxDays) {
      counts[interval] = (counts[interval] ?? 0) + 1;
    }
    if (_shouldYieldProgress(index + 1, cards.length, cardStep)) {
      await _yieldProgress(
        onProgress,
        0.25 + (_fraction(index + 1, cards.length) * 0.55),
      );
    }
  }

  final entries = counts.entries.toList(growable: false);
  final output = <IntervalHistogramPoint>[];
  final outputStep = _progressStep(entries.length);
  for (int index = 0; index < entries.length; index++) {
    final entry = entries[index];
    output.add(
      IntervalHistogramPoint(intervalDay: entry.key, count: entry.value),
    );
    if (_shouldYieldProgress(index + 1, entries.length, outputStep)) {
      await _yieldProgress(
        onProgress,
        0.80 + (_fraction(index + 1, entries.length) * 0.20),
      );
    }
  }

  _reportProgress(onProgress, 1);
  return output;
}

List<HourlyDistributionPoint> buildHourlyDistribution(
  DeckStatsData data, {
  required StatsRangeOption option,
  required HourlySlotOption slotOption,
}) {
  final slotMinutes = hourlySlotMinutes(slotOption);
  final slotCount = (24 * 60) ~/ slotMinutes;
  final days = rangeDaysForOption(option, data);
  final startDay = data.labelToday.subtract(Duration(days: days - 1));
  final counts = <int, int>{for (int i = 0; i < slotCount; i++) i: 0};

  for (final row in data.dailyStatsRows) {
    if (row.studyDay.isBefore(startDay) ||
        row.studyDay.isAfter(data.labelToday)) {
      continue;
    }
    final sourceBuckets = row.quarterHourBuckets;
    if (sourceBuckets.isEmpty) {
      continue;
    }
    for (int quarter = 0; quarter < sourceBuckets.length; quarter++) {
      final slot = ((quarter * 15) ~/ slotMinutes).clamp(0, slotCount - 1);
      counts[slot] = (counts[slot] ?? 0) + sourceBuckets[quarter];
    }
  }

  return counts.entries
      .map(
        (entry) => HourlyDistributionPoint(
          slotIndex: entry.key,
          slotMinutes: slotMinutes,
          count: entry.value,
        ),
      )
      .toList();
}

Future<List<HourlyDistributionPoint>> buildHourlyDistributionAsync(
  DeckStatsData data, {
  required StatsRangeOption option,
  required HourlySlotOption slotOption,
  StatsComputationProgressCallback? onProgress,
}) async {
  final slotMinutes = hourlySlotMinutes(slotOption);
  final slotCount = (24 * 60) ~/ slotMinutes;
  final days = rangeDaysForOption(option, data);
  final startDay = data.labelToday.subtract(Duration(days: days - 1));
  final counts = <int, int>{for (int i = 0; i < slotCount; i++) i: 0};

  final rows = data.dailyStatsRows;
  final rowStep = _progressStep(rows.length);
  _reportProgress(onProgress, 0);
  for (int index = 0; index < rows.length; index++) {
    final row = rows[index];
    if (!row.studyDay.isBefore(startDay) &&
        !row.studyDay.isAfter(data.labelToday)) {
      final sourceBuckets = row.quarterHourBuckets;
      if (sourceBuckets.isNotEmpty) {
        for (int quarter = 0; quarter < sourceBuckets.length; quarter++) {
          final slot = ((quarter * 15) ~/ slotMinutes).clamp(0, slotCount - 1);
          counts[slot] = (counts[slot] ?? 0) + sourceBuckets[quarter];
        }
      }
    }
    if (_shouldYieldProgress(index + 1, rows.length, rowStep)) {
      await _yieldProgress(
        onProgress,
        _fraction(index + 1, rows.length) * 0.82,
      );
    }
  }

  final entries = counts.entries.toList(growable: false);
  final output = <HourlyDistributionPoint>[];
  final outputStep = _progressStep(entries.length);
  for (int index = 0; index < entries.length; index++) {
    final entry = entries[index];
    output.add(
      HourlyDistributionPoint(
        slotIndex: entry.key,
        slotMinutes: slotMinutes,
        count: entry.value,
      ),
    );
    if (_shouldYieldProgress(index + 1, entries.length, outputStep)) {
      await _yieldProgress(
        onProgress,
        0.82 + (_fraction(index + 1, entries.length) * 0.18),
      );
    }
  }

  _reportProgress(onProgress, 1);
  return output;
}

List<PredictionTimelinePoint> buildPredictionTimeline(
  DeckStatsData data,
  StatsRangeOption option,
) {
  final startDay = data.firstStudyDay ?? data.labelToday;
  final lastActualDay = data.dailyStatsRows.isEmpty
      ? startDay
      : data.dailyStatsRows.last.studyDay;
  final totalDays = option == StatsRangeOption.life
      ? math.max(1, lastActualDay.difference(startDay).inDays + 1)
      : rangeDaysForOption(option, data);

  final actualByDay = <DateTime, _ActualDayStats>{
    for (final row in data.dailyStatsRows)
      row.studyDay: _ActualDayStats(
        newCards: row.newReviewCount,
        reviewCards: row.learningReviewCount + row.reviewStateCount,
        studyTimeMs: row.totalStudyTimeMs,
      ),
  };

  final stageAverages = _stageAveragesFromDailyRows(
    data.dailyStatsRows,
    data.averageAnswerTimeMs,
  );
  final predicted = _simulateDeckFromStart(
    data,
    startDay: startDay,
    totalDays: totalDays,
    stageAverages: stageAverages,
  );
  final points = <PredictionTimelinePoint>[];
  for (int offset = 0; offset < totalDays; offset++) {
    final day = startDay.add(Duration(days: offset));
    final actual = actualByDay[day] ?? _ActualDayStats();
    final future = predicted[day] ?? const _PredictedDayStats();
    points.add(
      PredictionTimelinePoint(
        offset: offset,
        day: day,
        predictedNew: future.newCards,
        predictedLearning: future.learningCards,
        predictedReview: future.reviewCards,
        actualNew: actual.newCards,
        actualReview: actual.reviewCards,
        actualStudyTimeMs: actual.studyTimeMs,
        predictedMinutes: future.predictedMinutes,
      ),
    );
  }
  return points;
}

Future<List<PredictionTimelinePoint>> buildPredictionTimelineAsync(
  DeckStatsData data,
  StatsRangeOption option, {
  StatsComputationProgressCallback? onProgress,
}) async {
  final startDay = data.firstStudyDay ?? data.labelToday;
  final lastActualDay = data.dailyStatsRows.isEmpty
      ? startDay
      : data.dailyStatsRows.last.studyDay;
  final totalDays = option == StatsRangeOption.life
      ? math.max(1, lastActualDay.difference(startDay).inDays + 1)
      : rangeDaysForOption(option, data);

  final actualByDay = <DateTime, _ActualDayStats>{};
  final rows = data.dailyStatsRows;
  final rowStep = _progressStep(rows.length);
  _reportProgress(onProgress, 0);
  for (int index = 0; index < rows.length; index++) {
    final row = rows[index];
    actualByDay[row.studyDay] = _ActualDayStats(
      newCards: row.newReviewCount,
      reviewCards: row.learningReviewCount + row.reviewStateCount,
      studyTimeMs: row.totalStudyTimeMs,
    );
    if (_shouldYieldProgress(index + 1, rows.length, rowStep)) {
      await _yieldProgress(
        onProgress,
        _fraction(index + 1, rows.length) * 0.10,
      );
    }
  }

  final stageAverages = _stageAveragesFromDailyRows(
    data.dailyStatsRows,
    data.averageAnswerTimeMs,
  );
  _reportProgress(onProgress, 0.12);
  final predicted = await _simulateDeckFromStartAsync(
    data,
    startDay: startDay,
    totalDays: totalDays,
    stageAverages: stageAverages,
    onProgress: (progress) {
      _reportProgress(onProgress, 0.12 + (progress * 0.68));
    },
  );

  final points = <PredictionTimelinePoint>[];
  final pointStep = _progressStep(totalDays);
  for (int offset = 0; offset < totalDays; offset++) {
    final day = startDay.add(Duration(days: offset));
    final actual = actualByDay[day] ?? _ActualDayStats();
    final future = predicted[day] ?? const _PredictedDayStats();
    points.add(
      PredictionTimelinePoint(
        offset: offset,
        day: day,
        predictedNew: future.newCards,
        predictedLearning: future.learningCards,
        predictedReview: future.reviewCards,
        actualNew: actual.newCards,
        actualReview: actual.reviewCards,
        actualStudyTimeMs: actual.studyTimeMs,
        predictedMinutes: future.predictedMinutes,
      ),
    );
    if (_shouldYieldProgress(offset + 1, totalDays, pointStep)) {
      await _yieldProgress(
        onProgress,
        0.80 + (_fraction(offset + 1, totalDays) * 0.20),
      );
    }
  }

  _reportProgress(onProgress, 1);
  return points;
}

class _MutableForecastBucket {
  final DateTime day;
  int overdue = 0;
  int learning = 0;
  int review = 0;
  int newCards = 0;

  _MutableForecastBucket({required this.day});
}

class _ActualDayStats {
  int newCards;
  int reviewCards;
  int studyTimeMs;

  _ActualDayStats({
    this.newCards = 0,
    this.reviewCards = 0,
    this.studyTimeMs = 0,
  });
}

class _PredictedDayStats {
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final double predictedMinutes;

  const _PredictedDayStats({
    this.newCards = 0,
    this.learningCards = 0,
    this.reviewCards = 0,
    this.predictedMinutes = 0,
  });
}

class _PredictedDayStatsMutable {
  int newCards = 0;
  int learningCards = 0;
  int reviewCards = 0;
  double predictedMinutes = 0;

  _PredictedDayStats freeze() => _PredictedDayStats(
    newCards: newCards,
    learningCards: learningCards,
    reviewCards: reviewCards,
    predictedMinutes: predictedMinutes,
  );
}

class _StageAverages {
  final double newMs;
  final double learningMs;
  final double reviewMs;

  const _StageAverages({
    required this.newMs,
    required this.learningMs,
    required this.reviewMs,
  });
}

class _SimCard {
  CardState state;
  DateTime nextReview;
  double decayRate;
  List<double> fixedPhaseQueue;
  int learningStep;
  int consecutiveLapses;
  final String cardType;

  _SimCard({
    required this.state,
    required this.nextReview,
    required this.decayRate,
    required this.fixedPhaseQueue,
    required this.learningStep,
    required this.consecutiveLapses,
    required this.cardType,
  });

  factory _SimCard.initial(
    String cardType,
    DeckSettings settings,
    DateTime startDay,
  ) {
    final anchor = DateTime(
      startDay.year,
      startDay.month,
      startDay.day,
      settings.dayCutoffHour ?? 4,
      settings.dayCutoffMinute ?? 0,
    );
    return _SimCard(
      state: CardState.newCard,
      nextReview: anchor,
      decayRate: settings.initialNt,
      fixedPhaseQueue: const <double>[],
      learningStep: 0,
      consecutiveLapses: 0,
      cardType: cardType,
    );
  }
}

_StageAverages _stageAveragesFromDailyRows(
  List<DeckDailyStats> rows,
  int fallbackMs,
) {
  double totalNew = 0;
  int countNew = 0;
  double totalLearning = 0;
  int countLearning = 0;
  double totalReview = 0;
  int countReview = 0;

  for (final row in rows) {
    totalNew += row.newStudyTimeMs;
    countNew += row.newReviewCount;
    totalLearning += row.learningStudyTimeMs;
    countLearning += row.learningReviewCount;
    totalReview += row.reviewStudyTimeMs;
    countReview += row.reviewStateCount;
  }

  final safeFallback = math.max(1000, fallbackMs).toDouble();
  return _StageAverages(
    newMs: countNew == 0 ? safeFallback : totalNew / countNew,
    learningMs: countLearning == 0
        ? safeFallback
        : totalLearning / countLearning,
    reviewMs: countReview == 0 ? safeFallback : totalReview / countReview,
  );
}

Map<DateTime, _PredictedDayStats> _simulateDeckFromStart(
  DeckStatsData data, {
  required DateTime startDay,
  required int totalDays,
  required _StageAverages stageAverages,
}) {
  final settings = data.settings;
  final activeCards = <_SimCard>[];
  final newPool = data.cardSnapshots
      .map((card) => _SimCard.initial(card.cardType, settings, startDay))
      .toList();

  final predicted = <DateTime, _PredictedDayStats>{};

  for (int offset = 0; offset < totalDays; offset++) {
    final day = startDay.add(Duration(days: offset));
    final queue = <_SimCard>[];
    for (final card in activeCards) {
      if (!StudyDay.label(card.nextReview, settings).isAfter(day)) {
        queue.add(card);
      }
    }

    final quota = settings.newCardsPerDay;
    if (quota > 0 && newPool.isNotEmpty) {
      final toIntroduce = math.min(quota, newPool.length);
      for (int i = 0; i < toIntroduce; i++) {
        final card = newPool.removeAt(0);
        activeCards.add(card);
        queue.add(card);
      }
    }

    final counts = _PredictedDayStatsMutable();
    final dayAnchor = DateTime(
      day.year,
      day.month,
      day.day,
      settings.dayCutoffHour ?? 4,
      settings.dayCutoffMinute ?? 0,
    );

    while (queue.isNotEmpty) {
      final card = queue.removeLast();
      final previousState = card.state;
      if (previousState == CardState.newCard) {
        counts.newCards++;
        counts.predictedMinutes += stageAverages.newMs / 60000;
      } else if (previousState == CardState.learning ||
          previousState == CardState.relearning) {
        counts.learningCards++;
        counts.predictedMinutes += stageAverages.learningMs / 60000;
      } else {
        counts.reviewCards++;
        counts.predictedMinutes += stageAverages.reviewMs / 60000;
      }

      _applySuccessfulSimulation(card, settings, dayAnchor);
      if (!StudyDay.label(card.nextReview, settings).isAfter(day)) {
        queue.add(card);
      }
    }

    predicted[day] = counts.freeze();
  }

  return predicted;
}

Future<Map<DateTime, _PredictedDayStats>> _simulateDeckFromStartAsync(
  DeckStatsData data, {
  required DateTime startDay,
  required int totalDays,
  required _StageAverages stageAverages,
  StatsComputationProgressCallback? onProgress,
}) async {
  final settings = data.settings;
  final activeCards = <_SimCard>[];
  final newPool = data.cardSnapshots
      .map((card) => _SimCard.initial(card.cardType, settings, startDay))
      .toList();

  final predicted = <DateTime, _PredictedDayStats>{};
  final dayStep = _progressStep(totalDays);

  _reportProgress(onProgress, 0);
  for (int offset = 0; offset < totalDays; offset++) {
    final day = startDay.add(Duration(days: offset));
    final queue = <_SimCard>[];
    for (final card in activeCards) {
      if (!StudyDay.label(card.nextReview, settings).isAfter(day)) {
        queue.add(card);
      }
    }

    final quota = settings.newCardsPerDay;
    int toIntroduce = 0;
    if (quota > 0 && newPool.isNotEmpty) {
      toIntroduce = math.min(quota, newPool.length);
      for (int i = 0; i < toIntroduce; i++) {
        final card = newPool.removeAt(0);
        activeCards.add(card);
        queue.add(card);
      }
    }

    final counts = _PredictedDayStatsMutable();
    final dayAnchor = DateTime(
      day.year,
      day.month,
      day.day,
      settings.dayCutoffHour ?? 4,
      settings.dayCutoffMinute ?? 0,
    );
    final estimatedDayWork = math.max(1, queue.length + toIntroduce);
    int processedDayItems = 0;

    while (queue.isNotEmpty) {
      final card = queue.removeLast();
      final previousState = card.state;
      if (previousState == CardState.newCard) {
        counts.newCards++;
        counts.predictedMinutes += stageAverages.newMs / 60000;
      } else if (previousState == CardState.learning ||
          previousState == CardState.relearning) {
        counts.learningCards++;
        counts.predictedMinutes += stageAverages.learningMs / 60000;
      } else {
        counts.reviewCards++;
        counts.predictedMinutes += stageAverages.reviewMs / 60000;
      }

      _applySuccessfulSimulation(card, settings, dayAnchor);
      if (!StudyDay.label(card.nextReview, settings).isAfter(day)) {
        queue.add(card);
      }

      processedDayItems++;
      if (processedDayItems % 128 == 0) {
        final withinDay = math.min(1.0, processedDayItems / estimatedDayWork);
        await _yieldProgress(
          onProgress,
          _fraction(offset + withinDay, totalDays.toDouble()),
        );
      }
    }

    predicted[day] = counts.freeze();
    if (_shouldYieldProgress(offset + 1, totalDays, dayStep)) {
      await _yieldProgress(onProgress, _fraction(offset + 1, totalDays));
    }
  }

  _reportProgress(onProgress, 1);
  return predicted;
}

int _progressStep(int total) {
  if (total <= 0) return 1;
  return math.max(1, total ~/ 24);
}

bool _shouldYieldProgress(int processed, int total, int step) {
  if (processed <= 0) return false;
  if (total <= 0) return processed == 1;
  return processed == total || processed % step == 0;
}

double _fraction(num processed, num total) {
  if (total <= 0) return 1;
  return (processed / total).clamp(0.0, 1.0);
}

void _reportProgress(
  StatsComputationProgressCallback? onProgress,
  double progress,
) {
  onProgress?.call(progress.clamp(0.0, 1.0));
}

Future<void> _yieldProgress(
  StatsComputationProgressCallback? onProgress,
  double progress,
) async {
  _reportProgress(onProgress, progress);
  await Future<void>.delayed(Duration.zero);
}

void _applySuccessfulSimulation(
  _SimCard card,
  DeckSettings settings,
  DateTime now,
) {
  if (card.state == CardState.newCard) {
    card.state = CardState.learning;
    card.learningStep = -1;
    _ensureFixedQueueInitialized(card, settings, forNewCard: true);
    _handleLearningSuccess(card, settings, now);
    return;
  }

  if (card.state == CardState.learning || card.state == CardState.relearning) {
    _handleLearningSuccess(card, settings, now);
    return;
  }

  card.consecutiveLapses = 0;
  card.decayRate = card.decayRate * (1.0 - settings.alpha);
  if (card.decayRate < 0.0001) {
    card.decayRate = 0.0001;
  }
  _calculateAndSchedule(card, settings, now);
}

void _handleLearningSuccess(
  _SimCard card,
  DeckSettings settings,
  DateTime now,
) {
  card.consecutiveLapses = 0;
  if (card.fixedPhaseQueue.isEmpty) {
    card.state = CardState.review;
    card.learningStep = 0;
    _calculateAndSchedule(card, settings, now);
    return;
  }

  final nextIndex = card.learningStep + 1;
  if (nextIndex < card.fixedPhaseQueue.length) {
    card.learningStep = nextIndex;
    _scheduleNextReview(card, card.fixedPhaseQueue[nextIndex], now, settings);
    return;
  }

  card.state = CardState.review;
  card.learningStep = 0;
  _calculateAndSchedule(card, settings, now);
}

void _calculateAndSchedule(_SimCard card, DeckSettings settings, DateTime now) {
  final pMinSafe = settings.pMin.clamp(1e-6, 0.999999).toDouble();
  final numerator = -math.log(pMinSafe);
  final tStar = (numerator / card.decayRate) - settings.offset;
  int intervalDays = math.max(1, tStar.floor());
  if (intervalDays > 10) {
    intervalDays = math.max(1, intervalDays);
  }
  _scheduleNextReview(card, intervalDays.toDouble(), now, settings);
}

void _ensureFixedQueueInitialized(
  _SimCard card,
  DeckSettings settings, {
  bool forNewCard = false,
}) {
  if (forNewCard) {
    final minReps = math.max(1, settings.newCardMinCorrectReps);
    final minutes = math.max(1, settings.newCardIntraDayMinutes);
    final queue = <double>[];
    if (minReps > 1) {
      final step = minutes / 1440.0;
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

void _scheduleNextReview(
  _SimCard card,
  double intervalDays,
  DateTime now,
  DeckSettings settings,
) {
  if (intervalDays < 1.0) {
    final minutes = math.max(1, (intervalDays * 1440).round());
    card.nextReview = now.add(Duration(minutes: minutes));
    return;
  }
  final days = math.max(1, intervalDays.ceil());
  final base = StudyDay.start(now, settings);
  card.nextReview = base.add(Duration(days: days));
}
