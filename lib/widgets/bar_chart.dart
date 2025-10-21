
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartDataBuilder {
  /// Builds a configured [BarChartData] object for a minimal bar chart
  static BarChartData build(ThemeData theme, List<List<double>> values, { List<String>? labels }) {
    final barColor = theme.colorScheme.primary;
    final maxY = values.isNotEmpty ? (values.expand((innerList) => innerList).reduce((a, b) => a > b ? a : b) * 1.2) : 0.0;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      gridData: FlGridData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (labels != null && index >= 0 && index < labels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(labels[index], style: const TextStyle(fontSize: 12)),
                );
              }
              return const SizedBox.shrink();
            },
            reservedSize: 30,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: List.generate(values.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: values[index][0],
              width: 18,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [
                BarChartRodStackItem(0, values[index][0], Colors.transparent,
                    borderSide: BorderSide(color: barColor, width: 2)),
                BarChartRodStackItem(0, values[index][1], barColor),
              ],
            ),
          ],
        );
      }),
      // optional: add touch / tooltip data
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          // tootltip: Colors.grey.shade700,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toStringAsFixed(1),
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}