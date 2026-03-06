import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';
import 'stats_provider.dart';

class StatsPage extends ConsumerWidget {
  final String packName;

  const StatsPage({super.key, required this.packName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(deckStatsProvider(packName));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr('stats_title', params: <String, Object?>{'packName': packName}),
        ),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            l10n.tr('common_error_with_detail', params: <String, Object?>{'error': err}),
          ),
        ),
        data: (stats) {
          if (stats.totalCards == 0) {
            return Center(child: Text(l10n.tr('stats_empty')));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, stats),
                const SizedBox(height: 30),
                _sectionTitle(context, l10n.tr('stats_activity')),
                const SizedBox(height: 10),
                _buildHeatmap(context, stats),
                const SizedBox(height: 30),
                _sectionTitle(context, l10n.tr('stats_distribution')),
                const SizedBox(height: 20),
                _buildDistributionChart(context, stats),
                const SizedBox(height: 40),
                _sectionTitle(context, l10n.tr('stats_forecast')),
                const SizedBox(height: 20),
                _buildForecastChart(context, stats),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
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
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(context, l10n.tr('stats_total'), '${stats.totalCards}'),
            _statItem(
              context,
              l10n.tr('stats_new'),
              '${stats.newCards}',
              AppUiColors.info(context),
            ),
            _statItem(
              context,
              l10n.tr('stats_review'),
              '${stats.reviewCards}',
              AppUiColors.success(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String label,
    String value, [
    Color? color,
  ]) {
    final muted = AppUiColors.mutedText(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(label, style: TextStyle(color: muted)),
      ],
    );
  }

  Widget _buildHeatmap(BuildContext context, DeckStatsData stats) {
    final l10n = context.l10n;
    final color = AppUiColors.info(context);
    final muted = AppUiColors.mutedText(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: HeatMap(
          datasets: stats.heatmapData,
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
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          endDate: DateTime.now(),
          size: 30,
          onClick: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.tr(
                    'stats_reviews_on_date',
                    params: <String, Object?>{'count': stats.heatmapData[value] ?? 0},
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
                      ((stats.relearningCards / total) * 100).toStringAsFixed(0),
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
                '${l10n.tr('stats_new')} (${stats.newCards})',
                textColor,
              ),
              _legendItem(
                warning,
                '${l10n.tr('stats_learning')} (${stats.learningCards})',
                textColor,
              ),
              _legendItem(
                success,
                '${l10n.tr('stats_review')} (${stats.reviewCards})',
                textColor,
              ),
              _legendItem(
                danger,
                '${l10n.tr('stats_difficult')} (${stats.relearningCards})',
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
    final info = AppUiColors.info(context);
    final warning = AppUiColors.warning(context);
    final muted = AppUiColors.mutedText(context);

    int maxY = 0;
    for (final count in stats.futureReviews.values) {
      if (count > maxY) maxY = count;
    }
    if (maxY == 0) maxY = 5;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.surfaceContainerHighest,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                l10n.tr(
                  'stats_tooltip_reviews',
                  params: <String, Object?>{'count': rod.toY.toInt()},
                ),
                TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  final day = value.toInt();
                  if (day == 0) {
                    return Text(
                      l10n.tr('stats_today'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: warning,
                      ),
                    );
                  }
                  if (day == 1) {
                    return Text(
                      l10n.tr('stats_tomorrow'),
                      style: TextStyle(fontSize: 10, color: muted),
                    );
                  }
                  if (day % 3 == 0) {
                    return Text(
                      '+$day',
                      style: TextStyle(fontSize: 10, color: muted),
                    );
                  }
                  return const SizedBox.shrink();
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
          barGroups: stats.futureReviews.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: entry.key == 0 ? warning : info,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY.toDouble() * 1.2,
                    color: scheme.surfaceContainerHighest,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
