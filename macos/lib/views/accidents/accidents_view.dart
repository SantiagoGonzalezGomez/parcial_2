// FILE: lib/views/accidents/accidents_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../providers/accident_provider.dart';

class AccidentsView extends ConsumerStatefulWidget {
  const AccidentsView({super.key});

  @override
  ConsumerState<AccidentsView> createState() => _AccidentsViewState();
}

class _AccidentsViewState extends ConsumerState<AccidentsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(accidentProvider);
      if (state.stats == null && !state.isLoading) {
        ref.read(accidentProvider.notifier).loadAccidents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accidentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Accidentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(accidentProvider.notifier).loadAccidents(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AccidentState state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(accidentProvider.notifier).loadAccidents(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Skeletonizer(
      enabled: state.isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.totalRecords} registros procesados con Isolate',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // 1. PieChart — Clase de accidente
            _ChartCard(
              title: 'Distribución por Clase de Accidente',
              child: state.isLoading || state.stats == null
                  ? _skeletonChart()
                  : _buildPieChart(
                      state.stats!.byClass,
                      [
                        const Color(0xFF1565C0),
                        const Color(0xFFE53935),
                        const Color(0xFF43A047),
                        const Color(0xFFFB8C00),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // 2. BarChart — Gravedad
            _ChartCard(
              title: 'Distribución por Gravedad',
              child: state.isLoading || state.stats == null
                  ? _skeletonChart()
                  : _buildBarChart(
                      state.stats!.bySeverity,
                      [
                        const Color(0xFFE53935),
                        const Color(0xFFFB8C00),
                        const Color(0xFF43A047),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // 3. BarChart — Top 5 barrios
            _ChartCard(
              title: 'Top 5 Barrios con Más Accidentes',
              child: state.isLoading || state.stats == null
                  ? _skeletonChart()
                  : _buildBarChart(
                      state.stats!.top5Neighborhoods,
                      [
                        const Color(0xFF1565C0),
                        const Color(0xFF1976D2),
                        const Color(0xFF1E88E5),
                        const Color(0xFF2196F3),
                        const Color(0xFF42A5F5),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // 4. BarChart — Día de la semana
            _ChartCard(
              title: 'Distribución por Día de la Semana',
              child: state.isLoading || state.stats == null
                  ? _skeletonChart()
                  : _buildBarChart(
                      state.stats!.byDayOfWeek,
                      [
                        const Color(0xFF6A1B9A),
                        const Color(0xFF7B1FA2),
                        const Color(0xFF8E24AA),
                        const Color(0xFF9C27B0),
                        const Color(0xFFAB47BC),
                        const Color(0xFFBA68C8),
                        const Color(0xFFCE93D8),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _skeletonChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data, List<Color> colors) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const Center(child: Text('Sin datos'));

    final entries = data.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final pct = entries[i].value / total * 100;
                return PieChartSectionData(
                  value: entries[i].value.toDouble(),
                  title: '${pct.toStringAsFixed(1)}%',
                  color: colors[i % colors.length],
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            return _LegendItem(
              color: colors[i % colors.length],
              label: '${entries[i].key} (${entries[i].value})',
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data, List<Color> colors) {
    if (data.isEmpty) return const Center(child: Text('Sin datos'));

    final entries = data.entries.toList();
    final maxVal = entries.isEmpty
        ? 1.0
        : entries
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxVal * 1.2,
              barGroups: List.generate(entries.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value.toDouble(),
                      color: colors[i % colors.length],
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final label = entries[idx].key;
                      final shortLabel =
                          label.length > 6 ? label.substring(0, 6) : label;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          shortLabel,
                          style: const TextStyle(fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            return _LegendItem(
              color: colors[i % colors.length],
              label: '${entries[i].key}: ${entries[i].value}',
            );
          }),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}