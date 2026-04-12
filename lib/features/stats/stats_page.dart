import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/features/library/flashcard_browser_page.dart';
import 'package:flashcards_app/features/library/review_history_sheet.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/stats/stats_analysis.dart';
import 'package:flashcards_app/features/stats/stats_pdf_chart_export.dart';
import 'package:flashcards_app/features/stats/stats_export_service.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';
import 'stats_provider.dart';

enum _HeatmapMode { answers, uniqueCards }

class StatsPage extends ConsumerStatefulWidget {
  final String packName;

  const StatsPage({super.key, required this.packName});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  _HeatmapMode _heatmapMode = _HeatmapMode.answers;
  bool _isExportingCsv = false;
  bool _isExportingPdf = false;
  StatsRangeOption _forecastRange = StatsRangeOption.days18;
  StatsRangeOption _studyTimeRange = StatsRangeOption.days7;
  IntervalRangeOption _intervalRange = IntervalRangeOption.month1;
  StatsRangeOption _hourlyRange = StatsRangeOption.month1;
  HourlySlotOption _hourlySlot = HourlySlotOption.hourly;
  StatsRangeOption _predictionRange = StatsRangeOption.days18;
  DeckStatsData? _cachedStats;
  final Map<_HeatmapMode, List<MonthHeatmapSlice>> _heatmapCache = {};
  final Map<StatsRangeOption, List<StackedForecastPoint>> _forecastCache = {};
  final Map<StatsRangeOption, List<StudyTimePoint>> _studyTimeCache = {};
  final Map<IntervalRangeOption, List<IntervalHistogramPoint>> _intervalCache =
      {};
  final Map<String, List<HourlyDistributionPoint>> _hourlyCache = {};
  final Map<StatsRangeOption, List<PredictionTimelinePoint>> _predictionCache =
      {};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(deckStatsProvider(widget.packName));
    final guidedTourState = ref.watch(guidedTourProvider);
    final tourStep = guidedTourState.step;
    final isTourInStats = tourStep.isStatsStep;
    final canPop = !isTourInStats || tourStep == GuidedTourStep.statsExit;

    final page = Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr(
            'stats_title',
            params: <String, Object?>{'packName': widget.packName},
          ),
        ),
        actions: [
          statsAsync.maybeWhen(
            data: (stats) => IconButton(
              tooltip: l10n.tr('stats_export_pdf'),
              onPressed: _isExportingCsv || _isExportingPdf
                  ? null
                  : () => _exportPdf(context, stats),
              icon: _isExportingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          statsAsync.maybeWhen(
            data: (stats) => IconButton(
              tooltip: l10n.tr('stats_export_csv'),
              onPressed: _isExportingCsv || _isExportingPdf
                  ? null
                  : () => _exportStats(context, stats),
              icon: _isExportingCsv
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            l10n.tr(
              'common_error_with_detail',
              params: <String, Object?>{'error': err},
            ),
          ),
        ),
        data: (stats) {
          if (stats.totalCards == 0) {
            return Center(child: Text(l10n.tr('stats_empty')));
          }

          final sections = _buildSections(context, stats, tourStep);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) => sections[index](),
          );
        },
      ),
    );

    if (!isTourInStats) return page;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(guidedTourProvider.notifier).onStatsClosed();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('onboarding_tour_stats_blocked'))),
        );
      },
      child: Stack(
        children: [
          page,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withValues(alpha: 0.24)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: TourMessageCard(
              message: _statsTourMessage(l10n, tourStep),
              actionLabel: tourStep == GuidedTourStep.statsExit
                  ? null
                  : l10n.tr('onboarding_tour_next'),
              onActionPressed: tourStep == GuidedTourStep.statsExit
                  ? null
                  : () => ref.read(guidedTourProvider.notifier).nextInStats(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportStats(BuildContext context, DeckStatsData stats) async {
    if (_isExportingCsv || _isExportingPdf) return;
    setState(() => _isExportingCsv = true);
    try {
      final isar = await ref.read(isarDbProvider.future);
      final result = await exportDeckStatsCsv(isar, widget.packName, stats);
      await shareDeckStatsCsvResult(result, text: widget.packName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.tr(
              'stats_export_success',
              params: <String, Object?>{
                'count': result.files.length,
                'path': '',
              },
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.tr(
              'common_error_with_detail',
              params: <String, Object?>{'error': error},
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCsv = false);
      }
    }
  }

  Future<void> _exportPdf(BuildContext context, DeckStatsData stats) async {
    if (_isExportingCsv || _isExportingPdf) return;
    setState(() => _isExportingPdf = true);
    try {
      final l10n = context.l10n;
      final charts = await buildDeckStatsPdfCharts(
        context,
        stats: stats,
        selection: DeckStatsPdfChartSelection(
          heatmapModeLabel: _heatmapMode == _HeatmapMode.answers
              ? l10n.tr('stats_heatmap_answers')
              : l10n.tr('stats_heatmap_unique'),
          forecastRangeLabel: _statsRangeLabel(l10n, _forecastRange),
          studyTimeRangeLabel: _statsRangeLabel(l10n, _studyTimeRange),
          intervalRangeLabel: _intervalRangeLabel(l10n, _intervalRange),
          hourlyRangeLabel: _statsRangeLabel(l10n, _hourlyRange),
          hourlySlotLabel: _hourlySlotLabel(l10n, _hourlySlot),
          predictionRangeLabel: _statsRangeLabel(l10n, _predictionRange),
        ),
        heatmapSlices: _heatmapSlices(stats),
        forecastPoints: _forecastPoints(stats),
        studyTimePoints: _studyTimePoints(stats),
        intervalPoints: _intervalPoints(stats),
        hourlyPoints: _hourlyPoints(stats),
        predictionPoints: _predictionPoints(stats),
      );
      final file = await exportDeckStatsPdf(
        widget.packName,
        stats,
        charts: charts,
      );
      await shareDeckStatsPdfFile(file, text: widget.packName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.tr(
              'stats_export_pdf_success',
              params: <String, Object?>{'path': ''},
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.tr(
              'common_error_with_detail',
              params: <String, Object?>{'error': error},
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  Future<void> _showCardHistory(
    BuildContext context,
    DeckCardInsight card,
  ) async {
    final isar = await ref.read(isarDbProvider.future);
    final logs = await isar.reviewLogs
        .filter()
        .packNameEqualTo(widget.packName)
        .flashcardIdEqualTo(card.id)
        .findAll();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (!context.mounted) return;
    await showReviewHistorySheet(context, logs);
  }

  Future<void> _bringCardToToday(
    BuildContext context,
    DeckCardInsight card,
  ) async {
    final isar = await ref.read(isarDbProvider.future);
    final flashcard = await isar.flashcards.get(card.id);
    if (flashcard == null || flashcard.state == CardState.newCard) {
      return;
    }
    await isar.writeTxn(() async {
      flashcard.nextReview = DateTime.now();
      await isar.flashcards.put(flashcard);
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.tr(
            'stats_problem_marked_today',
            params: <String, Object?>{'question': flashcard.question},
          ),
        ),
      ),
    );
  }

  void _openBrowser(BuildContext context, DeckCardInsight card) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardBrowserPage(
          packName: widget.packName,
          initialCardId: card.id,
          initialQuery: card.question,
        ),
      ),
    );
  }

  String _statsTourMessage(AppLocalizations l10n, GuidedTourStep step) {
    switch (step) {
      case GuidedTourStep.statsIntro:
        return l10n.tr('onboarding_tour_stats_intro');
      case GuidedTourStep.statsActivity:
        return l10n.tr('onboarding_tour_stats_activity');
      case GuidedTourStep.statsDistribution:
        return l10n.tr('onboarding_tour_stats_distribution');
      case GuidedTourStep.statsForecast:
        return l10n.tr('onboarding_tour_stats_forecast');
      case GuidedTourStep.statsExit:
        return l10n.tr('onboarding_tour_stats_exit');
      default:
        return '';
    }
  }

  void _resetAnalysisCacheIfNeeded(DeckStatsData stats) {
    if (identical(_cachedStats, stats)) {
      return;
    }
    _cachedStats = stats;
    _heatmapCache.clear();
    _forecastCache.clear();
    _studyTimeCache.clear();
    _intervalCache.clear();
    _hourlyCache.clear();
    _predictionCache.clear();
  }

  List<MonthHeatmapSlice> _heatmapSlices(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    return _heatmapCache.putIfAbsent(
      _heatmapMode,
      () => buildHeatmapSlices(
        stats,
        uniqueCards: _heatmapMode == _HeatmapMode.uniqueCards,
      ),
    );
  }

  List<StackedForecastPoint> _forecastPoints(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    return _forecastCache.putIfAbsent(
      _forecastRange,
      () => buildForecastSeries(stats, _forecastRange),
    );
  }

  List<StudyTimePoint> _studyTimePoints(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    return _studyTimeCache.putIfAbsent(
      _studyTimeRange,
      () => buildStudyTimeSeries(stats, _studyTimeRange),
    );
  }

  List<IntervalHistogramPoint> _intervalPoints(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    return _intervalCache.putIfAbsent(
      _intervalRange,
      () => buildIntervalHistogram(stats, _intervalRange),
    );
  }

  List<HourlyDistributionPoint> _hourlyPoints(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    final key = '${_hourlyRange.name}:${_hourlySlot.name}';
    return _hourlyCache.putIfAbsent(
      key,
      () => buildHourlyDistribution(
        stats,
        option: _hourlyRange,
        slotOption: _hourlySlot,
      ),
    );
  }

  List<PredictionTimelinePoint> _predictionPoints(DeckStatsData stats) {
    _resetAnalysisCacheIfNeeded(stats);
    return _predictionCache.putIfAbsent(
      _predictionRange,
      () => buildPredictionTimeline(stats, _predictionRange),
    );
  }

  List<Widget Function()> _buildSections(
    BuildContext context,
    DeckStatsData stats,
    GuidedTourStep tourStep,
  ) {
    final l10n = context.l10n;
    return <Widget Function()>[
      () => TourHighlight(
        highlighted: tourStep == GuidedTourStep.statsIntro,
        child: _buildHeaderCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_compare'),
        child: _buildComparisonCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_activity'),
        titleSpacing: 10,
        child: TourHighlight(
          highlighted: tourStep == GuidedTourStep.statsActivity,
          child: _buildHeatmapCard(context, stats),
        ),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_study_time_chart'),
        child: _buildStudyTimeChartCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_distribution'),
        titleSpacing: 20,
        child: TourHighlight(
          highlighted: tourStep == GuidedTourStep.statsDistribution,
          child: _buildDistributionChart(context, stats),
        ),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_forecast'),
        titleSpacing: 20,
        child: TourHighlight(
          highlighted: tourStep == GuidedTourStep.statsForecast,
          child: _buildForecastChart(context, stats),
        ),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_interval_histogram'),
        child: _buildIntervalHistogramCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_hourly_distribution'),
        child: _buildHourlyDistributionCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_prediction_repetitions'),
        child: _buildPredictionChartCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_prediction_time'),
        child: _buildPredictionTimeCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_performance'),
        child: _buildPerformanceCard(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_problem_cards'),
        child: _buildProblemCards(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_recent_sessions'),
        child: _buildRecentSessions(context, stats),
      ),
      () => _sectionBlock(
        context,
        title: l10n.tr('stats_hardest_cards'),
        bottomPadding: 24,
        child: _buildHardestCards(context, stats),
      ),
    ];
  }

  Widget _sectionBlock(
    BuildContext context, {
    required String title,
    required Widget child,
    double titleSpacing = 12,
    double topPadding = 30,
    double bottomPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, title),
          SizedBox(height: titleSpacing),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricTile(context, l10n.tr('stats_total'), '${stats.totalCards}'),
            _metricTile(
              context,
              l10n.tr('stats_new_today'),
              '${stats.newAvailableToday}',
              AppUiColors.info(context),
            ),
            _metricTile(
              context,
              l10n.tr('stats_learning_now'),
              '${stats.learningDueNow}',
              AppUiColors.warning(context),
            ),
            _metricTile(
              context,
              l10n.tr('stats_review_now'),
              '${stats.reviewDueNow}',
              AppUiColors.success(context),
            ),
            _metricTile(
              context,
              l10n.tr('stats_overdue'),
              '${stats.overdueCards}',
              AppUiColors.danger(context),
            ),
            _metricTile(
              context,
              l10n.tr('stats_accuracy_lifetime'),
              _formatPercent(stats.lifetimeAccuracy),
            ),
            _metricTile(
              context,
              l10n.tr('stats_accuracy_7d'),
              _formatPercent(stats.accuracy7d),
            ),
            _metricTile(
              context,
              l10n.tr('stats_accuracy_30d'),
              _formatPercent(stats.accuracy30d),
            ),
            _metricTile(
              context,
              l10n.tr('stats_lifetime_reviews'),
              '${stats.lifetimeReviewCount}',
            ),
            _metricTile(
              context,
              l10n.tr('stats_total_study_time'),
              _formatDuration(stats.totalStudyTimeMs),
            ),
            _metricTile(
              context,
              l10n.tr('stats_avg_answer_time'),
              _formatDuration(stats.averageAnswerTimeMs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(
    BuildContext context,
    String label,
    String value, [
    Color? color,
  ]) {
    final scheme = Theme.of(context).colorScheme;
    final muted = AppUiColors.mutedText(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: muted)),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _comparisonTile(
              context,
              label: l10n.tr('stats_accuracy_lifetime'),
              recentLabel: '7d',
              recentValue: _formatPercent(stats.accuracy7d),
              baselineLabel: '30d',
              baselineValue: _formatPercent(stats.accuracy30d),
              delta: _formatPercentPointDelta(
                stats.accuracy7d - stats.accuracy30d,
              ),
              deltaColor: _deltaColor(
                context,
                stats.accuracy7d - stats.accuracy30d,
              ),
            ),
            _comparisonTile(
              context,
              label: l10n.tr('stats_reviews_per_day'),
              recentLabel: '7d',
              recentValue: _formatPerDay(stats.reviewsPerDay7d),
              baselineLabel: '30d',
              baselineValue: _formatPerDay(stats.reviewsPerDay30d),
              delta: _formatDelta(
                stats.reviewsPerDay7d - stats.reviewsPerDay30d,
              ),
              deltaColor: _deltaColor(
                context,
                stats.reviewsPerDay7d - stats.reviewsPerDay30d,
                positive: AppUiColors.info(context),
              ),
            ),
            _comparisonTile(
              context,
              label: l10n.tr('stats_study_time_per_day'),
              recentLabel: '7d',
              recentValue: _formatDuration(stats.studyTimePerDay7dMs),
              baselineLabel: '30d',
              baselineValue: _formatDuration(stats.studyTimePerDay30dMs),
              delta: _formatDuration(
                (stats.studyTimePerDay7dMs - stats.studyTimePerDay30dMs).abs(),
                withSign:
                    stats.studyTimePerDay7dMs - stats.studyTimePerDay30dMs,
              ),
              deltaColor: _deltaColor(
                context,
                stats.studyTimePerDay7dMs - stats.studyTimePerDay30dMs,
                positive: AppUiColors.info(context),
              ),
            ),
            _comparisonTile(
              context,
              label: l10n.tr('stats_sessions_per_day'),
              recentLabel: '7d',
              recentValue: _formatPerDay(stats.sessionsPerDay7d),
              baselineLabel: '30d',
              baselineValue: _formatPerDay(stats.sessionsPerDay30d),
              delta: _formatDelta(
                stats.sessionsPerDay7d - stats.sessionsPerDay30d,
              ),
              deltaColor: _deltaColor(
                context,
                stats.sessionsPerDay7d - stats.sessionsPerDay30d,
                positive: AppUiColors.info(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonTile(
    BuildContext context, {
    required String label,
    required String recentLabel,
    required String recentValue,
    required String baselineLabel,
    required String baselineValue,
    required String delta,
    required Color deltaColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final muted = AppUiColors.mutedText(context);
    return Container(
      width: 162,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('$recentLabel: $recentValue'),
          const SizedBox(height: 4),
          Text(
            '$baselineLabel: $baselineValue',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 8),
          Text(
            delta,
            style: TextStyle(fontWeight: FontWeight.bold, color: deltaColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final slices = _heatmapSlices(stats);
    final heatmapHeight = math.min(
      520.0,
      math.max(220.0, slices.length * 148.0),
    );
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.tr('stats_heatmap_answers')),
                  selected: _heatmapMode == _HeatmapMode.answers,
                  onSelected: (_) {
                    setState(() => _heatmapMode = _HeatmapMode.answers);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.tr('stats_heatmap_unique')),
                  selected: _heatmapMode == _HeatmapMode.uniqueCards,
                  onSelected: (_) {
                    setState(() => _heatmapMode = _HeatmapMode.uniqueCards);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tr('stats_heatmap_lifetime'),
              style: TextStyle(color: AppUiColors.mutedText(context)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: heatmapHeight,
              child: ListView.separated(
                primary: false,
                itemCount: slices.length,
                itemBuilder: (context, index) {
                  return _buildMonthHeatmap(context, slices[index]);
                },
                separatorBuilder: (_, _) => const SizedBox(height: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeatmap(BuildContext context, MonthHeatmapSlice slice) {
    final l10n = context.l10n;
    final color = AppUiColors.info(context);
    final muted = AppUiColors.mutedText(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(slice.monthStart),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        HeatMap(
          datasets: slice.values,
          colorMode: ColorMode.opacity,
          showText: false,
          scrollable: true,
          colorsets: {
            1: color.withValues(alpha: 0.30),
            3: color.withValues(alpha: 0.45),
            6: color.withValues(alpha: 0.60),
            10: color.withValues(alpha: 0.78),
          },
          textColor: muted,
          startDate: slice.monthStart,
          endDate: slice.monthEnd,
          size: 26,
          onClick: (value) {
            final count = slice.values[value] ?? 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.tr(
                    _heatmapMode == _HeatmapMode.answers
                        ? 'stats_reviews_on_date'
                        : 'stats_unique_on_date',
                    params: <String, Object?>{'count': count},
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDistributionChart(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final total = stats.totalCards.toDouble();
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final info = AppUiColors.info(context);
    final warning = AppUiColors.warning(context);
    final success = AppUiColors.success(context);
    final danger = AppUiColors.danger(context);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (stats.newCards > 0)
                    _pieSection(
                      info,
                      stats.newCards.toDouble(),
                      ((stats.newCards / total) * 100).toStringAsFixed(0),
                    ),
                  if (stats.learningCards > 0)
                    _pieSection(
                      warning,
                      stats.learningCards.toDouble(),
                      ((stats.learningCards / total) * 100).toStringAsFixed(0),
                    ),
                  if (stats.reviewCards > 0)
                    _pieSection(
                      success,
                      stats.reviewCards.toDouble(),
                      ((stats.reviewCards / total) * 100).toStringAsFixed(0),
                      radius: 60,
                    ),
                  if (stats.relearningCards > 0)
                    _pieSection(
                      danger,
                      stats.relearningCards.toDouble(),
                      ((stats.relearningCards / total) * 100).toStringAsFixed(
                        0,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(
                info,
                '${l10n.tr('stats_new')} (${stats.newCards} - ${_formatWholePercent(stats.newCards, total)})',
                textColor,
              ),
              _legendItem(
                warning,
                '${l10n.tr('stats_learning')} (${stats.learningCards} - ${_formatWholePercent(stats.learningCards, total)})',
                textColor,
              ),
              _legendItem(
                success,
                '${l10n.tr('stats_review')} (${stats.reviewCards} - ${_formatWholePercent(stats.reviewCards, total)})',
                textColor,
              ),
              _legendItem(
                danger,
                '${l10n.tr('stats_difficult')} (${stats.relearningCards} - ${_formatWholePercent(stats.relearningCards, total)})',
                textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(
    Color color,
    double value,
    String percent, {
    double radius = 50,
  }) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '$percent%',
      radius: radius,
      titleStyle: TextStyle(
        color: AppUiColors.onAccent(color),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _legendItem(Color color, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final danger = AppUiColors.danger(context);
    final warning = AppUiColors.warning(context);
    final success = AppUiColors.success(context);
    final info = AppUiColors.info(context);
    final muted = AppUiColors.mutedText(context);
    final points = _forecastPoints(stats);

    int maxY = 0;
    for (final point in points) {
      if (point.total > maxY) maxY = point.total;
    }
    if (maxY == 0) maxY = 5;

    final chartWidth = math.max(
      MediaQuery.of(context).size.width - 32,
      points.length * 22.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rangeSelector(
          context,
          selected: _forecastRange,
          values: const <StatsRangeOption>[
            StatsRangeOption.days18,
            StatsRangeOption.month1,
            StatsRangeOption.months3,
            StatsRangeOption.year1,
            StatsRangeOption.life,
          ],
          labelBuilder: (value) => _statsRangeLabel(l10n, value),
          onSelected: (value) => setState(() => _forecastRange = value),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: _barTooltipData(
                    context,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final point = points[group.x.toInt()];
                      return BarTooltipItem(
                        '${_formatDateLabel(point.day)}\n'
                        '${l10n.tr('stats_forecast_overdue')}: ${point.overdue}\n'
                        '${l10n.tr('stats_forecast_learning')}: ${point.learning}\n'
                        '${l10n.tr('stats_forecast_review')}: ${point.review}\n'
                        '${l10n.tr('stats_forecast_new')}: ${point.newCards}',
                        TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10, color: muted),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        if (index == 0) {
                          return Text(
                            l10n.tr('stats_today'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: warning,
                            ),
                          );
                        }
                        final every = _labelStep(points.length);
                        if (index % every != 0) return const SizedBox.shrink();
                        return Text(
                          _formatShortDate(points[index].day),
                          style: TextStyle(fontSize: 10, color: muted),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: 0.45),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(points.length, (
                  index,
                ) {
                  final point = points[index];
                  final segments = <BarChartRodStackItem>[];
                  double fromY = 0;

                  void addSegment(int count, Color color) {
                    if (count <= 0) return;
                    final toY = fromY + count.toDouble();
                    segments.add(BarChartRodStackItem(fromY, toY, color));
                    fromY = toY;
                  }

                  addSegment(point.overdue, danger);
                  addSegment(point.learning, warning);
                  addSegment(point.review, success);
                  addSegment(point.newCards, info);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: point.total.toDouble(),
                        width: points.length > 90 ? 8 : 12,
                        rodStackItems: segments,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _legendItem(
              danger,
              l10n.tr('stats_forecast_overdue'),
              scheme.onSurface,
            ),
            _legendItem(
              warning,
              l10n.tr('stats_forecast_learning'),
              scheme.onSurface,
            ),
            _legendItem(
              success,
              l10n.tr('stats_forecast_review'),
              scheme.onSurface,
            ),
            _legendItem(info, l10n.tr('stats_forecast_new'), scheme.onSurface),
          ],
        ),
      ],
    );
  }

  Widget _buildStudyTimeChartCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final points = _studyTimePoints(stats);
    final maxY = math.max<double>(
      5,
      points.fold<double>(
        0,
        (maxValue, point) => math.max(maxValue, point.studyTimeMs / 60000),
      ),
    );
    final chartWidth = math.max(
      MediaQuery.of(context).size.width - 32,
      points.length * 20.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeSelector(
              context,
              selected: _studyTimeRange,
              values: const <StatsRangeOption>[
                StatsRangeOption.days7,
                StatsRangeOption.days18,
                StatsRangeOption.month1,
                StatsRangeOption.months3,
                StatsRangeOption.year1,
                StatsRangeOption.life,
              ],
              labelBuilder: (value) => _statsRangeLabel(l10n, value),
              onSelected: (value) => setState(() => _studyTimeRange = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: 260,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: math.max(0, points.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY * 1.2,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}m',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppUiColors.mutedText(context),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final every = _labelStep(points.length);
                            if (index % every != 0 &&
                                index != points.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              _formatShortDate(points[index].day),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppUiColors.mutedText(context),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: _lineTooltipData(
                        context,
                        getTooltipItems: (spots) => spots
                            .map(
                              (spot) => LineTooltipItem(
                                '${_formatDateLabel(points[spot.x.toInt()].day)}\n${spot.y.toStringAsFixed(1)} min',
                                TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        color: AppUiColors.info(context),
                        barWidth: 2.5,
                        dotData: FlDotData(show: points.length <= 60),
                        spots: List<FlSpot>.generate(
                          points.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            points[index].studyTimeMs / 60000,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalHistogramCard(
    BuildContext context,
    DeckStatsData stats,
  ) {
    final l10n = context.l10n;
    final points = _intervalPoints(stats);
    int maxY = 0;
    for (final point in points) {
      if (point.count > maxY) maxY = point.count;
    }
    if (maxY == 0) maxY = 5;
    final chartWidth = math.max(
      MediaQuery.of(context).size.width - 32,
      points.length * 18.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeSelector(
              context,
              selected: _intervalRange,
              values: IntervalRangeOption.values,
              labelBuilder: (value) => _intervalRangeLabel(l10n, value),
              onSelected: (value) => setState(() => _intervalRange = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: 260,
                child: BarChart(
                  BarChartData(
                    maxY: maxY.toDouble() * 1.2,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final every = _labelStep(points.length);
                            if (index % every != 0 &&
                                index != points.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${points[index].intervalDay}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppUiColors.mutedText(context),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: _barTooltipData(
                        context,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final point = points[group.x.toInt()];
                          return BarTooltipItem(
                            '${point.intervalDay}d\n${point.count} cards',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: List<BarChartGroupData>.generate(points.length, (
                      index,
                    ) {
                      final point = points[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: point.count.toDouble(),
                            width: points.length > 90 ? 8 : 12,
                            color: AppUiColors.success(context),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyDistributionCard(
    BuildContext context,
    DeckStatsData stats,
  ) {
    final l10n = context.l10n;
    final points = _hourlyPoints(stats);
    int maxY = 0;
    for (final point in points) {
      if (point.count > maxY) maxY = point.count;
    }
    if (maxY == 0) maxY = 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeSelector(
              context,
              selected: _hourlyRange,
              values: const <StatsRangeOption>[
                StatsRangeOption.month1,
                StatsRangeOption.months3,
                StatsRangeOption.year1,
              ],
              labelBuilder: (value) => _statsRangeLabel(l10n, value),
              onSelected: (value) => setState(() => _hourlyRange = value),
            ),
            const SizedBox(height: 8),
            _rangeSelector(
              context,
              selected: _hourlySlot,
              values: HourlySlotOption.values,
              labelBuilder: (value) => _hourlySlotLabel(l10n, value),
              onSelected: (value) => setState(() => _hourlySlot = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxY.toDouble() * 1.2,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final every = math.max(1, points.length ~/ 8);
                          if (index % every != 0 &&
                              index != points.length - 1) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _slotLabel(points[index]),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppUiColors.mutedText(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: _barTooltipData(
                      context,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final point = points[group.x.toInt()];
                        return BarTooltipItem(
                          '${_slotLabel(point)}\n${point.count} cards',
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  barGroups: List<BarChartGroupData>.generate(points.length, (
                    index,
                  ) {
                    final point = points[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: point.count.toDouble(),
                          width: points.length > 48 ? 5 : 8,
                          color: AppUiColors.warning(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionChartCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final points = _predictionPoints(stats);
    final maxY = math.max<double>(
      5,
      points.fold<double>(
        0,
        (maxValue, point) => math.max(
          maxValue,
          math.max(
            math.max(
              point.predictedNew.toDouble(),
              (point.predictedLearning + point.predictedReview).toDouble(),
            ),
            math.max(point.actualNew.toDouble(), point.actualReview.toDouble()),
          ),
        ),
      ),
    );
    final chartWidth = math.max(
      MediaQuery.of(context).size.width - 32,
      points.length * 16.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeSelector(
              context,
              selected: _predictionRange,
              values: const <StatsRangeOption>[
                StatsRangeOption.days18,
                StatsRangeOption.month1,
                StatsRangeOption.months3,
                StatsRangeOption.months6,
                StatsRangeOption.year1,
                StatsRangeOption.life,
              ],
              labelBuilder: (value) => _statsRangeLabel(l10n, value),
              onSelected: (value) => setState(() => _predictionRange = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: 300,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: math.max(0, points.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY * 1.2,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final every = _labelStep(points.length);
                            if (index % every != 0 &&
                                index != points.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              _formatShortDate(points[index].day),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppUiColors.mutedText(context),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: _lineTooltipData(
                        context,
                        getTooltipItems: (spots) => spots.map((spot) {
                          final point = points[spot.x.toInt()];
                          return LineTooltipItem(
                            '${_formatDateLabel(point.day)}\n${spot.y.toInt()} cards',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      _predictionBar(
                        points,
                        color: AppUiColors.info(context),
                        selector: (point) => point.predictedNew,
                      ),
                      _predictionBar(
                        points,
                        color: AppUiColors.danger(context),
                        selector: (point) =>
                            point.predictedLearning + point.predictedReview,
                      ),
                      _predictionBar(
                        points,
                        color: Colors.purple,
                        selector: (point) => point.actualNew,
                      ),
                      _predictionBar(
                        points,
                        color: AppUiColors.success(context),
                        selector: (point) => point.actualReview,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _legendItem(
                  AppUiColors.info(context),
                  l10n.tr('stats_prediction_new_predicted'),
                  Theme.of(context).colorScheme.onSurface,
                ),
                _legendItem(
                  AppUiColors.danger(context),
                  l10n.tr('stats_prediction_review_predicted'),
                  Theme.of(context).colorScheme.onSurface,
                ),
                _legendItem(
                  Colors.purple,
                  l10n.tr('stats_prediction_new_actual'),
                  Theme.of(context).colorScheme.onSurface,
                ),
                _legendItem(
                  AppUiColors.success(context),
                  l10n.tr('stats_prediction_review_actual'),
                  Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionTimeCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final points = _predictionPoints(stats);
    final maxY = math.max<double>(
      5,
      points.fold<double>(
        0,
        (maxValue, point) => math.max(maxValue, point.predictedMinutes),
      ),
    );
    final chartWidth = math.max(
      MediaQuery.of(context).size.width - 32,
      points.length * 20.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeSelector(
              context,
              selected: _predictionRange,
              values: const <StatsRangeOption>[
                StatsRangeOption.days18,
                StatsRangeOption.month1,
                StatsRangeOption.months3,
                StatsRangeOption.months6,
                StatsRangeOption.year1,
                StatsRangeOption.life,
              ],
              labelBuilder: (value) => _statsRangeLabel(l10n, value),
              onSelected: (value) => setState(() => _predictionRange = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: 280,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: math.max(0, points.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY * 1.2,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}m',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppUiColors.mutedText(context),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final every = _labelStep(points.length);
                            if (index % every != 0 &&
                                index != points.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              _formatShortDate(points[index].day),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppUiColors.mutedText(context),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: _lineTooltipData(
                        context,
                        getTooltipItems: (spots) => spots.map((spot) {
                          final point = points[spot.x.toInt()];
                          return LineTooltipItem(
                            '${_formatDateLabel(point.day)}\n${point.predictedMinutes.toStringAsFixed(1)} min',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        color: Colors.brown,
                        barWidth: 2.5,
                        dotData: FlDotData(show: points.length <= 90),
                        spots: List<FlSpot>.generate(
                          points.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            points[index].predictedMinutes,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _predictionBar(
    List<PredictionTimelinePoint> points, {
    required Color color,
    required int Function(PredictionTimelinePoint point) selector,
  }) {
    return LineChartBarData(
      isCurved: false,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: points.length <= 120),
      spots: List<FlSpot>.generate(
        points.length,
        (index) => FlSpot(index.toDouble(), selector(points[index]).toDouble()),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _insightChip(
              context,
              l10n.tr('stats_accuracy_7d'),
              _formatPercent(stats.accuracy7d),
            ),
            _insightChip(
              context,
              l10n.tr('stats_accuracy_30d'),
              _formatPercent(stats.accuracy30d),
            ),
            _insightChip(
              context,
              l10n.tr('stats_sessions_7d'),
              '${stats.sessionCount7d}',
            ),
            _insightChip(
              context,
              l10n.tr('stats_sessions_30d'),
              '${stats.sessionCount30d}',
            ),
            _insightChip(
              context,
              l10n.tr('stats_study_time_7d'),
              _formatDuration(stats.studyTime7dMs),
            ),
            _insightChip(
              context,
              l10n.tr('stats_study_time_30d'),
              _formatDuration(stats.studyTime30dMs),
            ),
            _insightChip(
              context,
              l10n.tr('stats_active_days_7d'),
              '${stats.activeDays7d}/7',
            ),
            _insightChip(
              context,
              l10n.tr('stats_active_days_30d'),
              '${stats.activeDays30d}/30',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemCards(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final muted = AppUiColors.mutedText(context);
    if (stats.problemCards.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.tr('stats_problem_cards_empty'),
            style: TextStyle(color: muted),
          ),
        ),
      );
    }

    final now = DateTime.now();
    return Column(
      children: stats.problemCards.map((card) {
        final canBringToToday =
            card.state != CardState.newCard && card.nextReview.isAfter(now);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: card.problemTags
                      .map(
                        (tag) => _tagChip(context, _problemTagLabel(l10n, tag)),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _insightChip(
                      context,
                      l10n.tr('stats_card_accuracy'),
                      _formatPercent(card.accuracy),
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_overdue'),
                      '${card.overdueDays}d',
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_avg_answer_time'),
                      _formatDuration(card.averageStudyTimeMs),
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_card_failures'),
                      '${card.lifetimeWrongCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openBrowser(context, card),
                      icon: const Icon(Icons.travel_explore),
                      label: Text(l10n.tr('stats_problem_action_open')),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCardHistory(context, card),
                      icon: const Icon(Icons.history),
                      label: Text(l10n.tr('stats_problem_action_history')),
                    ),
                    TextButton.icon(
                      onPressed: canBringToToday
                          ? () => _bringCardToToday(context, card)
                          : null,
                      icon: const Icon(Icons.bolt),
                      label: Text(l10n.tr('stats_problem_action_review_now')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentSessions(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final muted = AppUiColors.mutedText(context);
    if (stats.recentSessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.tr('stats_no_sessions'),
            style: TextStyle(color: muted),
          ),
        ),
      );
    }

    return Column(
      children: stats.recentSessions.map((session) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(_formatDateTime(session.endedAt)),
            subtitle: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  l10n.tr(
                    'stats_session_answers',
                    params: <String, Object?>{'count': session.answerCount},
                  ),
                ),
                Text(
                  l10n.tr(
                    'stats_session_unique_cards',
                    params: <String, Object?>{'count': session.uniqueCardCount},
                  ),
                ),
                Text(
                  l10n.tr(
                    'stats_session_accuracy',
                    params: <String, Object?>{
                      'percent': (session.accuracy * 100).round(),
                    },
                  ),
                ),
                Text(
                  l10n.tr(
                    'stats_session_duration',
                    params: <String, Object?>{
                      'value': _formatDuration(session.totalStudyTimeMs),
                    },
                  ),
                ),
                Text(
                  l10n.tr(
                    'stats_session_avg_answer',
                    params: <String, Object?>{
                      'value': _formatDuration(session.averageAnswerTimeMs),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHardestCards(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final muted = AppUiColors.mutedText(context);
    if (stats.hardestCards.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.tr('stats_no_card_history'),
            style: TextStyle(color: muted),
          ),
        ),
      );
    }

    return Column(
      children: stats.hardestCards.map((card) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _insightChip(
                      context,
                      l10n.tr('stats_card_accuracy'),
                      _formatPercent(card.accuracy),
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_card_failures'),
                      '${card.lifetimeWrongCount}',
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_total_study_time'),
                      _formatDuration(card.totalStudyTimeMs),
                    ),
                    _insightChip(
                      context,
                      l10n.tr('stats_lifetime_reviews'),
                      '${card.lifetimeReviewCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _rangeSelector<T>(
    BuildContext context, {
    required T selected,
    required List<T> values,
    required String Function(T value) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(labelBuilder(value)),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
            ),
          )
          .toList(),
    );
  }

  Widget _insightChip(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
    );
  }

  BarTouchTooltipData _barTooltipData(
    BuildContext context, {
    required GetBarTooltipItem getTooltipItem,
  }) {
    return BarTouchTooltipData(
      getTooltipColor: (_) =>
          Theme.of(context).colorScheme.surfaceContainerHighest,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      tooltipMargin: 10,
      maxContentWidth: 220,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItem: getTooltipItem,
    );
  }

  LineTouchTooltipData _lineTooltipData(
    BuildContext context, {
    required GetLineTooltipItems getTooltipItems,
  }) {
    return LineTouchTooltipData(
      getTooltipColor: (_) =>
          Theme.of(context).colorScheme.surfaceContainerHighest,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      tooltipMargin: 10,
      maxContentWidth: 220,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      showOnTopOfTheChartBoxArea: true,
      getTooltipItems: getTooltipItems,
    );
  }

  Widget _tagChip(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _problemTagLabel(AppLocalizations l10n, String tag) {
    switch (tag) {
      case 'overdue':
        return l10n.tr('stats_problem_overdue');
      case 'low_accuracy':
        return l10n.tr('stats_problem_low_accuracy');
      case 'lapses':
        return l10n.tr('stats_problem_lapses');
      case 'slow':
        return l10n.tr('stats_problem_slow');
      default:
        return tag;
    }
  }

  Color _deltaColor(BuildContext context, double delta, {Color? positive}) {
    if (delta > 0) return positive ?? AppUiColors.success(context);
    if (delta < 0) return AppUiColors.danger(context);
    return AppUiColors.mutedText(context);
  }

  String _formatPercent(double value) => '${(value * 100).round()}%';

  String _formatWholePercent(num value, double total) {
    if (total <= 0) return '0%';
    return '${((value / total) * 100).round()}%';
  }

  String _formatPercentPointDelta(double delta) {
    final value = (delta * 100).toStringAsFixed(1);
    return '${delta >= 0 ? '+' : ''}$value pp';
  }

  String _formatPerDay(double value) => '${value.toStringAsFixed(1)}/d';

  String _formatDelta(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}';
  }

  String _formatDuration(num totalMs, {num? withSign}) {
    final prefix = withSign == null
        ? ''
        : (withSign > 0
              ? '+'
              : withSign < 0
              ? '-'
              : '');
    final ms = totalMs.abs().round();
    if (ms <= 0) return '${prefix}0s';
    final totalSeconds = Duration(milliseconds: ms).inSeconds;
    if (totalSeconds < 60) return '$prefix${totalSeconds}s';
    final totalMinutes = Duration(milliseconds: ms).inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '$prefix${minutes}m';
    if (minutes == 0) return '$prefix${hours}h';
    return '$prefix${hours}h ${minutes}m';
  }

  String _statsRangeLabel(AppLocalizations l10n, StatsRangeOption option) {
    switch (option) {
      case StatsRangeOption.days7:
        return l10n.tr('stats_range_7d');
      case StatsRangeOption.days18:
        return l10n.tr('stats_range_18d');
      case StatsRangeOption.month1:
        return l10n.tr('stats_range_1m');
      case StatsRangeOption.months3:
        return l10n.tr('stats_range_3m');
      case StatsRangeOption.months6:
        return l10n.tr('stats_range_6m');
      case StatsRangeOption.year1:
        return l10n.tr('stats_range_1y');
      case StatsRangeOption.life:
        return l10n.tr('stats_range_life');
    }
  }

  String _intervalRangeLabel(
    AppLocalizations l10n,
    IntervalRangeOption option,
  ) {
    switch (option) {
      case IntervalRangeOption.month1:
        return l10n.tr('stats_range_1m');
      case IntervalRangeOption.months3:
        return l10n.tr('stats_range_3m');
      case IntervalRangeOption.lifeHalf:
        return l10n.tr('stats_range_life_half');
      case IntervalRangeOption.lifeFull:
        return l10n.tr('stats_range_life_full');
    }
  }

  String _hourlySlotLabel(AppLocalizations l10n, HourlySlotOption option) {
    switch (option) {
      case HourlySlotOption.hourly:
        return l10n.tr('stats_hourly_60');
      case HourlySlotOption.halfHourly:
        return l10n.tr('stats_hourly_30');
      case HourlySlotOption.quarterHourly:
        return l10n.tr('stats_hourly_15');
    }
  }

  int _labelStep(int length) {
    if (length <= 18) return 3;
    if (length <= 45) return 6;
    if (length <= 120) return 12;
    if (length <= 365) return 30;
    return math.max(30, length ~/ 12);
  }

  String _slotLabel(HourlyDistributionPoint point) {
    final totalMinutes = point.slotIndex * point.slotMinutes;
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _formatShortDate(DateTime value) {
    return DateFormat('MM/dd').format(value);
  }

  String _formatDateLabel(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  String _formatDateTime(DateTime value) {
    if (value.millisecondsSinceEpoch == 0) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }
}
