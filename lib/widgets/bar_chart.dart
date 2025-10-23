import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dayline_planner/models/section_model.dart';
import 'package:dayline_planner/utils/icon_helper.dart';

class BarChartDataBuilder {
  /// Builds a [BarChartData] for the planner overview.
  ///
  /// [values] is a list of [ [totalTasks, completedTasks] ] per section.
  /// [sections] provides label & icon info.
  static BarChartData build(
    ThemeData theme,
    List<List<double>> values, {
    required List<Section> sections,
  }) {
    final barColor = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodySmall?.color ?? Colors.black87;

    final maxY = values.isNotEmpty
        ? (values.expand((inner) => inner).reduce((a, b) => a > b ? a : b) * 1.2)
        : 0.0;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sections.length) {
                return const SizedBox.shrink();
              }
              final sec = sections[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconHelper.getIconData(sec.iconName),
                    size: 16,
                    color: barColor,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sec.title,
                    style: TextStyle(fontSize: 10, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: List.generate(values.length, (index) {
        final total = values[index][0];
        final completed = values[index][1];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 18,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [
                BarChartRodStackItem(0, total, Colors.transparent,
                    borderSide: BorderSide(color: barColor, width: 2)),
                BarChartRodStackItem(0, completed, barColor),
              ],
            ),
          ],
        );
      }),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final sec = sections[group.x.toInt()];
            return BarTooltipItem(
              '${sec.title}\n'
              '${rod.toY.toStringAsFixed(0)} task${rod.toY == 1 ? '' : 's'}',
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }
}
