import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cima_mens/providers/cycle_provider.dart';

/// CycleGraphScreen — Layar grafik siklus.
/// Menampilkan LineChart dari fl_chart yang memvisualisasikan
/// panjang siklus dari waktu ke waktu dan garis rata-rata.
class CycleGraphScreen extends StatelessWidget {
  const CycleGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cycles = cycleProvider.cycles;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Grafik Siklus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: cycles.length < 2
          ? _buildInsufficientData(primaryColor)
          : _buildGraph(context, cycles, cycleProvider, primaryColor),
    );
  }

  /// Grafik utama
  Widget _buildGraph(BuildContext context, List cycles,
      CycleProvider cycleProvider, Color primaryColor) {
    // Siapkan data titik
    final spots = <FlSpot>[];
    for (int i = 0; i < cycles.length; i++) {
      spots.add(FlSpot(i.toDouble(), cycles[i].cycleLength.toDouble()));
    }

    final avgLength = cycleProvider.avgCycleLength;

    // Hitung min/max untuk sumbu Y
    final cycleLengths = cycles.map((c) => c.cycleLength.toDouble()).toList();
    final minY = (cycleLengths.reduce((a, b) => a < b ? a : b) - 3)
        .clamp(15.0, 50.0);
    final maxY = (cycleLengths.reduce((a, b) => a > b ? a : b) + 3)
        .clamp(20.0, 55.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Info rata-rata
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.12),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics_rounded,
                      color: primaryColor, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rata-rata Panjang Siklus',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${avgLength.toStringAsFixed(1)} hari',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${cycles.length} siklus',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chart
          Container(
            height: 280,
            padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (cycles.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= cycles.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Garis data siklus
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: primaryColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withOpacity(0.08),
                    ),
                  ),

                  // Garis rata-rata
                  LineChartBarData(
                    spots: [
                      FlSpot(0, avgLength.toDouble()),
                      FlSpot((cycles.length - 1).toDouble(), avgLength.toDouble()),
                    ],
                    isCurved: false,
                    color: Colors.grey.shade400,
                    barWidth: 1.5,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 1) return null; // Abaikan garis avg
                        return LineTooltipItem(
                          '${spot.y.toInt()} hari',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('Panjang Siklus', primaryColor),
              const SizedBox(width: 24),
              _legendItem('Rata-rata', Colors.grey.shade400, isDashed: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Item legend
  Widget _legendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Pesan jika data kurang dari 2
  Widget _buildInsufficientData(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data Belum Cukup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu butuh minimal 2 data siklus\nuntuk menampilkan grafik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
