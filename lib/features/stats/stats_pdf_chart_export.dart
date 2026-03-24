import 'dart:math' as math;

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flashcards_app/features/stats/stats_analysis.dart';
import 'package:flashcards_app/features/stats/stats_export_service.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';

class DeckStatsPdfChartSelection {
  final String heatmapModeLabel;
  final String forecastRangeLabel;
  final String studyTimeRangeLabel;
  final String intervalRangeLabel;
  final String hourlyRangeLabel;
  final String hourlySlotLabel;
  final String predictionRangeLabel;

  const DeckStatsPdfChartSelection({
    required this.heatmapModeLabel,
    required this.forecastRangeLabel,
    required this.studyTimeRangeLabel,
    required this.intervalRangeLabel,
    required this.hourlyRangeLabel,
    required this.hourlySlotLabel,
    required this.predictionRangeLabel,
  });
}

Future<List<DeckStatsPdfChart>> buildDeckStatsPdfCharts(
  BuildContext context, {
  required DeckStatsData stats,
  required DeckStatsPdfChartSelection selection,
  required List<MonthHeatmapSlice> heatmapSlices,
  required List<StackedForecastPoint> forecastPoints,
  required List<StudyTimePoint> studyTimePoints,
  required List<IntervalHistogramPoint> intervalPoints,
  required List<HourlyDistributionPoint> hourlyPoints,
  required List<PredictionTimelinePoint> predictionPoints,
}) async {
  final l10n = context.l10n;
  return <DeckStatsPdfChart>[
    ..._buildHeatmapCharts(
      l10n,
      title: l10n.tr('stats_activity'),
      modeLabel: selection.heatmapModeLabel,
      slices: heatmapSlices,
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_study_time_chart'),
      subtitle: selection.studyTimeRangeLabel,
      landscape: true,
      child: _chartCard(_buildStudyTimeChart(studyTimePoints)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_distribution'),
      landscape: true,
      child: _chartCard(_buildDistributionChart(l10n, stats)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_forecast'),
      subtitle: selection.forecastRangeLabel,
      landscape: true,
      child: _chartCard(_buildForecastChart(l10n, forecastPoints)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_interval_histogram'),
      subtitle: selection.intervalRangeLabel,
      landscape: true,
      child: _chartCard(_buildIntervalHistogramChart(intervalPoints)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_hourly_distribution'),
      subtitle: '${selection.hourlyRangeLabel} | ${selection.hourlySlotLabel}',
      landscape: true,
      child: _chartCard(_buildHourlyDistributionChart(hourlyPoints)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_prediction_repetitions'),
      subtitle: selection.predictionRangeLabel,
      landscape: true,
      child: _chartCard(_buildPredictionChart(l10n, predictionPoints)),
    ),
    DeckStatsPdfChart(
      title: l10n.tr('stats_prediction_time'),
      subtitle: selection.predictionRangeLabel,
      landscape: true,
      child: _chartCard(_buildPredictionTimeChart(predictionPoints)),
    ),
  ];
}

List<DeckStatsPdfChart> _buildHeatmapCharts(
  AppLocalizations l10n, {
  required String title,
  required String modeLabel,
  required List<MonthHeatmapSlice> slices,
}) {
  if (slices.isEmpty) {
    return <DeckStatsPdfChart>[
      DeckStatsPdfChart(
        title: title,
        subtitle: modeLabel,
        child: _chartCard(
          pw.Center(child: pw.Text(l10n.tr('stats_empty'))),
          padding: const pw.EdgeInsets.all(24),
        ),
      ),
    ];
  }

  final ordered = slices.reversed.toList(growable: false);
  final charts = <DeckStatsPdfChart>[];
  const chunkSize = 4;
  for (int start = 0; start < ordered.length; start += chunkSize) {
    final chunk = ordered.skip(start).take(chunkSize).toList(growable: false);
    charts.add(
      DeckStatsPdfChart(
        title: title,
        subtitle:
            '$modeLabel | ${_monthLabel(chunk.first.monthStart)} - ${_monthLabel(chunk.last.monthStart)}',
        child: _chartCard(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: chunk
                .map(
                  (slice) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 18),
                    child: _buildMonthHeatmap(slice),
                  ),
                )
                .toList(),
          ),
          padding: const pw.EdgeInsets.fromLTRB(18, 18, 18, 6),
        ),
      ),
    );
  }
  return charts;
}

pw.Widget _buildMonthHeatmap(MonthHeatmapSlice slice) {
  const cell = 16.0;
  const spacing = 3.0;
  final daysInMonth = DateTime(
    slice.monthStart.year,
    slice.monthStart.month + 1,
    0,
  ).day;
  final leading = slice.monthStart.weekday - 1;
  final totalCells = leading + daysInMonth;
  final cells = <pw.Widget>[];

  for (int i = 0; i < leading; i++) {
    cells.add(_heatCell(label: '', color: PdfColors.white));
  }
  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(slice.monthStart.year, slice.monthStart.month, day);
    final value = slice.values[date] ?? 0;
    cells.add(
      _heatCell(
        label: '$day',
        color: _heatColor(value),
        textColor: value >= 6 ? PdfColors.white : PdfColors.blueGrey900,
      ),
    );
  }
  for (int i = totalCells; i % 7 != 0; i++) {
    cells.add(_heatCell(label: '', color: PdfColors.white));
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        DateFormat('MMMM yyyy').format(slice.monthStart),
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
            .map(
              (label) => pw.Container(
                width: cell,
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(right: spacing),
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.blueGrey600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      pw.SizedBox(height: 4),
      pw.SizedBox(
        width: (cell * 7) + (spacing * 6),
        child: pw.Wrap(spacing: spacing, runSpacing: spacing, children: cells),
      ),
    ],
  );
}

pw.Widget _heatCell({
  required String label,
  required PdfColor color,
  PdfColor textColor = PdfColors.blueGrey800,
}) {
  return pw.Container(
    width: 16,
    height: 16,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      border: pw.Border.all(color: PdfColors.blueGrey100, width: .4),
    ),
    child: label.isEmpty
        ? null
        : pw.Text(label, style: pw.TextStyle(fontSize: 6, color: textColor)),
  );
}

PdfColor _heatColor(int value) {
  if (value <= 0) return PdfColor.fromInt(0xFFF8FAFC);
  if (value < 3) return PdfColor.fromInt(0xFFBFDBFE);
  if (value < 6) return PdfColor.fromInt(0xFF60A5FA);
  if (value < 10) return PdfColor.fromInt(0xFF2563EB);
  return PdfColor.fromInt(0xFF1D4ED8);
}

pw.Widget _buildStudyTimeChart(List<StudyTimePoint> points) {
  final minutes = points.map((point) => point.studyTimeMs / 60000).toList();
  return _buildLineChart(
    labels: _dateLabels(points.map((point) => point.day).toList()),
    ticks: _yTicks(_maxDouble(minutes)),
    datasets: [
      pw.LineDataSet(
        legend: 'Study time',
        color: PdfColor.fromInt(0xFF3B82F6),
        drawSurface: true,
        data: _pointData(minutes),
      ),
    ],
    yFormatter: (value) => '${value.toInt()}m',
  );
}

pw.Widget _buildDistributionChart(AppLocalizations l10n, DeckStatsData stats) {
  final total = math.max(1, stats.totalCards);
  final segments = <({String label, int value, PdfColor color})>[
    (
      label: l10n.tr('stats_new'),
      value: stats.newCards,
      color: PdfColor.fromInt(0xFF3B82F6),
    ),
    (
      label: l10n.tr('stats_learning'),
      value: stats.learningCards,
      color: PdfColor.fromInt(0xFFF59E0B),
    ),
    (
      label: l10n.tr('stats_review'),
      value: stats.reviewCards,
      color: PdfColor.fromInt(0xFF10B981),
    ),
    (
      label: l10n.tr('stats_difficult'),
      value: stats.relearningCards,
      color: PdfColor.fromInt(0xFFEF4444),
    ),
  ].where((segment) => segment.value > 0).toList();

  if (segments.isEmpty) {
    return pw.Center(child: pw.Text(l10n.tr('stats_empty')));
  }

  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Chart(
          grid: pw.PieGrid(startAngle: 1),
          datasets: [
            for (final segment in segments)
              pw.PieDataSet(
                legend:
                    '${segment.label} (${segment.value} - ${((segment.value / total) * 100).round()}%)',
                value: segment.value,
                color: segment.color,
                innerRadius: 42,
              ),
          ],
        ),
      ),
      pw.SizedBox(width: 16),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: segments
              .map(
                (segment) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: _legendItem(
                    segment.color,
                    '${segment.label} (${segment.value} - ${((segment.value / total) * 100).round()}%)',
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

pw.Widget _buildForecastChart(
  AppLocalizations l10n,
  List<StackedForecastPoint> points,
) {
  final labels = _dateLabels(
    points.map((point) => point.day).toList(),
    emphasizeFirst: true,
  );
  final maxY = points.fold<int>(
    0,
    (value, point) => math.max(value, point.total),
  );
  final data =
      <({String legend, PdfColor color, List<double> values, double offset})>[
        (
          legend: l10n.tr('stats_forecast_overdue'),
          color: PdfColor.fromInt(0xFFEF4444),
          values: points.map((point) => point.overdue.toDouble()).toList(),
          offset: -8,
        ),
        (
          legend: l10n.tr('stats_forecast_learning'),
          color: PdfColor.fromInt(0xFFF59E0B),
          values: points.map((point) => point.learning.toDouble()).toList(),
          offset: -2.5,
        ),
        (
          legend: l10n.tr('stats_forecast_review'),
          color: PdfColor.fromInt(0xFF10B981),
          values: points.map((point) => point.review.toDouble()).toList(),
          offset: 2.5,
        ),
        (
          legend: l10n.tr('stats_forecast_new'),
          color: PdfColor.fromInt(0xFF3B82F6),
          values: points.map((point) => point.newCards.toDouble()).toList(),
          offset: 8,
        ),
      ];

  return _buildBarChart(
    labels: labels,
    ticks: _yTicks(maxY.toDouble()),
    datasets: data
        .map(
          (entry) => pw.BarDataSet(
            legend: entry.legend,
            color: entry.color,
            width: _barWidth(points.length),
            offset: entry.offset,
            data: _pointData(entry.values),
          ),
        )
        .toList(),
  );
}

pw.Widget _buildIntervalHistogramChart(List<IntervalHistogramPoint> points) {
  return _buildBarChart(
    labels: _sparseLabels(
      points.length,
      (index) => '${points[index].intervalDay}',
    ),
    ticks: _yTicks(
      points.fold<double>(
        0,
        (value, point) => math.max(value, point.count.toDouble()),
      ),
    ),
    datasets: [
      pw.BarDataSet(
        legend: 'Cards',
        color: PdfColor.fromInt(0xFF10B981),
        width: _barWidth(points.length),
        data: List<pw.PointChartValue>.generate(
          points.length,
          (index) => pw.PointChartValue(
            index.toDouble(),
            points[index].count.toDouble(),
          ),
        ),
      ),
    ],
  );
}

pw.Widget _buildHourlyDistributionChart(List<HourlyDistributionPoint> points) {
  return _buildBarChart(
    labels: _sparseLabels(points.length, (index) => _slotLabel(points[index])),
    ticks: _yTicks(
      points.fold<double>(
        0,
        (value, point) => math.max(value, point.count.toDouble()),
      ),
    ),
    datasets: [
      pw.BarDataSet(
        legend: 'Cards',
        color: PdfColor.fromInt(0xFFF59E0B),
        width: points.length > 48 ? 4 : 7,
        data: List<pw.PointChartValue>.generate(
          points.length,
          (index) => pw.PointChartValue(
            index.toDouble(),
            points[index].count.toDouble(),
          ),
        ),
      ),
    ],
  );
}

pw.Widget _buildPredictionChart(
  AppLocalizations l10n,
  List<PredictionTimelinePoint> points,
) {
  final labels = _dateLabels(points.map((point) => point.day).toList());
  final predictedReviews = points
      .map(
        (point) => (point.predictedLearning + point.predictedReview).toDouble(),
      )
      .toList();
  final maxY = <double>[
    ...points.map((point) => point.predictedNew.toDouble()),
    ...predictedReviews,
    ...points.map((point) => point.actualNew.toDouble()),
    ...points.map((point) => point.actualReview.toDouble()),
  ].fold<double>(0, math.max);

  return _buildLineChart(
    labels: labels,
    ticks: _yTicks(maxY),
    datasets: [
      pw.LineDataSet(
        legend: l10n.tr('stats_prediction_new_predicted'),
        color: PdfColor.fromInt(0xFF3B82F6),
        data: _pointData(
          points.map((point) => point.predictedNew.toDouble()).toList(),
        ),
      ),
      pw.LineDataSet(
        legend: l10n.tr('stats_prediction_review_predicted'),
        color: PdfColor.fromInt(0xFFEF4444),
        data: _pointData(predictedReviews),
      ),
      pw.LineDataSet(
        legend: l10n.tr('stats_prediction_new_actual'),
        color: PdfColor.fromInt(0xFF7C3AED),
        data: _pointData(
          points.map((point) => point.actualNew.toDouble()).toList(),
        ),
      ),
      pw.LineDataSet(
        legend: l10n.tr('stats_prediction_review_actual'),
        color: PdfColor.fromInt(0xFF10B981),
        data: _pointData(
          points.map((point) => point.actualReview.toDouble()).toList(),
        ),
      ),
    ],
  );
}

pw.Widget _buildPredictionTimeChart(List<PredictionTimelinePoint> points) {
  final minutes = points.map((point) => point.predictedMinutes).toList();
  return _buildLineChart(
    labels: _dateLabels(points.map((point) => point.day).toList()),
    ticks: _yTicks(_maxDouble(minutes)),
    datasets: [
      pw.LineDataSet(
        legend: 'Predicted time',
        color: PdfColor.fromInt(0xFF8B5E3C),
        drawSurface: true,
        surfaceOpacity: .12,
        data: _pointData(minutes),
      ),
    ],
    yFormatter: (value) => '${value.toInt()}m',
  );
}

pw.Widget _buildLineChart({
  required List<String> labels,
  required List<double> ticks,
  required List<pw.LineDataSet<pw.PointChartValue>> datasets,
  String Function(num value)? yFormatter,
}) {
  return pw.Chart(
    grid: pw.CartesianGrid(
      xAxis: _xAxis(labels),
      yAxis: _yAxis(ticks, formatter: yFormatter),
    ),
    overlay: pw.ChartLegend(
      position: pw.Alignment.topRight,
      direction: pw.Axis.horizontal,
      textStyle: const pw.TextStyle(fontSize: 7),
    ),
    datasets: datasets,
  );
}

pw.Widget _buildBarChart({
  required List<String> labels,
  required List<double> ticks,
  required List<pw.BarDataSet<pw.PointChartValue>> datasets,
}) {
  return pw.Chart(
    grid: pw.CartesianGrid(xAxis: _xAxis(labels), yAxis: _yAxis(ticks)),
    overlay: pw.ChartLegend(
      position: pw.Alignment.topRight,
      direction: pw.Axis.horizontal,
      textStyle: const pw.TextStyle(fontSize: 7),
    ),
    datasets: datasets,
  );
}

pw.FixedAxis<int> _xAxis(List<String> labels) {
  final safeLabels = labels.isEmpty
      ? <String>['', '']
      : labels.length == 1
      ? <String>[labels.first, '']
      : labels;
  return pw.FixedAxis.fromStrings(
    safeLabels,
    angle: .55,
    divisions: true,
    textStyle: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey700),
  );
}

pw.FixedAxis<double> _yAxis(
  List<double> ticks, {
  String Function(num value)? formatter,
}) {
  final safeTicks = ticks.length == 1 ? <double>[0, ticks.first] : ticks;
  return pw.FixedAxis<double>(
    safeTicks,
    divisions: true,
    format: formatter ?? (value) => value.toStringAsFixed(value >= 10 ? 0 : 1),
    textStyle: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey700),
  );
}

pw.Widget _chartCard(
  pw.Widget child, {
  pw.EdgeInsetsGeometry padding = const pw.EdgeInsets.all(18),
}) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF8FAFC),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
      border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: .8),
    ),
    padding: padding,
    child: child,
  );
}

pw.Widget _legendItem(PdfColor color, String text) {
  return pw.Row(
    children: [
      pw.Container(
        width: 10,
        height: 10,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey900),
        ),
      ),
    ],
  );
}

List<pw.PointChartValue> _pointData(List<double> values) {
  return List<pw.PointChartValue>.generate(
    values.length,
    (index) => pw.PointChartValue(index.toDouble(), values[index]),
  );
}

List<String> _dateLabels(List<DateTime> dates, {bool emphasizeFirst = false}) {
  return _sparseLabels(dates.length, (index) {
    if (emphasizeFirst && index == 0) return 'Today';
    return DateFormat('MM/dd').format(dates[index]);
  });
}

List<String> _sparseLabels(int length, String Function(int index) labelAt) {
  if (length <= 0) return <String>['', ''];
  final step = _labelStep(length);
  return List<String>.generate(length, (index) {
    if (index == 0 || index == length - 1 || index % step == 0) {
      return labelAt(index);
    }
    return '';
  });
}

List<double> _yTicks(double maxValue) {
  final maxSafe = math.max(1, maxValue);
  final rough = maxSafe / 4;
  final magnitude = math
      .pow(10, math.max(0, (math.log(rough) / math.ln10).floor()))
      .toDouble();
  final normalized = rough / magnitude;
  final step = normalized <= 1
      ? 1 * magnitude
      : normalized <= 2
      ? 2 * magnitude
      : normalized <= 5
      ? 5 * magnitude
      : 10 * magnitude;
  final top = (maxSafe / step).ceil() * step;
  final ticks = <double>[];
  for (double value = 0; value <= top + 0.0001; value += step) {
    ticks.add(value);
  }
  if (ticks.length == 1) {
    ticks.add(top > 0 ? top : 1);
  }
  return ticks;
}

double _maxDouble(List<double> values) {
  if (values.isEmpty) return 1;
  return values.fold<double>(0, math.max);
}

double _barWidth(int count) {
  if (count > 240) return 1.4;
  if (count > 120) return 2.0;
  if (count > 60) return 3.0;
  return 5.0;
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

String _monthLabel(DateTime value) => DateFormat('MMM yyyy').format(value);
