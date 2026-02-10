import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // <--- LIBRERÍA NUEVA
import 'stats_provider.dart';

class StatsPage extends ConsumerWidget {
  final String packName;

  const StatsPage({super.key, required this.packName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(deckStatsProvider(packName));

    return Scaffold(
      appBar: AppBar(title: Text("Estadísticas: $packName")),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (stats) {
          if (stats.totalCards == 0) {
            return const Center(child: Text("Este mazo está vacío."));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(stats),

                const SizedBox(height: 30),
                _sectionTitle(context, "Actividad de Estudio (Heatmap)"),
                const SizedBox(height: 10),
                _buildHeatmap(context, stats), // <--- NUEVO WIDGET

                const SizedBox(height: 30),
                _sectionTitle(context, "Distribución del Mazo"),
                const SizedBox(height: 20),
                _buildDistributionChart(stats),

                const SizedBox(height: 40),
                _sectionTitle(context, "Pronóstico (Próximos 14 días)"),
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
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeaderCard(DeckStatsData stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("Total", "${stats.totalCards}"),
            _statItem("Nuevas", "${stats.newCards}", Colors.blue),
            _statItem("Repaso", "${stats.reviewCards}", Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  // --- NUEVO: MAPA DE CALOR ---
  Widget _buildHeatmap(BuildContext context, DeckStatsData stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HeatMap(
          datasets: stats.heatmapData,
          colorMode: ColorMode.opacity,
          showText: false,
          scrollable: true,
          colorsets: {
            1: Theme.of(
              context,
            ).primaryColor, // Color base (se hace más oscuro con más actividad)
          },
          onClick: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Repasos en esta fecha: ${stats.heatmapData[value] ?? 0}",
                ),
              ),
            );
          },
          startDate: DateTime.now().subtract(
            const Duration(days: 60),
          ), // Mostrar últimos 2 meses
          endDate: DateTime.now().add(const Duration(days: 0)),
          size: 30, // Tamaño de los cuadritos
          textColor: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  // --- GRÁFICO DE TORTA ---
  Widget _buildDistributionChart(DeckStatsData stats) {
    final total = stats.totalCards.toDouble();
    if (total == 0) return const SizedBox();

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (stats.newCards > 0)
                    PieChartSectionData(
                      color: Colors.blue,
                      value: stats.newCards.toDouble(),
                      title:
                          '${((stats.newCards / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (stats.learningCards > 0)
                    PieChartSectionData(
                      color: Colors.orange,
                      value: stats.learningCards.toDouble(),
                      title:
                          '${((stats.learningCards / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (stats.reviewCards > 0)
                    PieChartSectionData(
                      color: Colors.green,
                      value: stats.reviewCards.toDouble(),
                      title:
                          '${((stats.reviewCards / total) * 100).toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (stats.relearningCards > 0)
                    PieChartSectionData(
                      color: Colors.red,
                      value: stats.relearningCards.toDouble(),
                      title:
                          '${((stats.relearningCards / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
              _legendItem(Colors.blue, "Nuevas (${stats.newCards})"),
              _legendItem(
                Colors.orange,
                "Aprendiendo (${stats.learningCards})",
              ),
              _legendItem(Colors.green, "Repaso (${stats.reviewCards})"),
              _legendItem(Colors.red, "Difíciles (${stats.relearningCards})"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- GRÁFICO DE BARRAS ---
  Widget _buildForecastChart(BuildContext context, DeckStatsData stats) {
    int maxY = 0;
    stats.futureReviews.forEach((_, v) {
      if (v > maxY) maxY = v;
    });
    if (maxY == 0) maxY = 5;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
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
                  if (value == 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int day = value.toInt();
                  if (day == 0)
                    return const Text(
                      "Hoy",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  if (day == 1)
                    return const Text("Mañ", style: TextStyle(fontSize: 10));
                  if (day % 3 == 0)
                    return Text("+$day", style: const TextStyle(fontSize: 10));
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          barGroups: stats.futureReviews.entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: e.key == 0
                      ? Colors.orange
                      : Theme.of(context).primaryColor,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY.toDouble() * 1.2,
                    color: Colors.grey.shade100,
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
