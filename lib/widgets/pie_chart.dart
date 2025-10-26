import 'package:dayline_planner/models/section_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatefulWidget {
  final List<PieChartDataItem> data;

  const CustomPieChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = response.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 1,
          centerSpaceRadius: 0,
          sections: _buildSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.data.length, (i) {
      final item = widget.data[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      return PieChartSectionData(
        color: item.theme.colorScheme.primary,
        value: item.value,
        title: '${item.value}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: item.theme.cardColor,
        ),
        badgeWidget: _Badge(
          backColor: item.theme.cardColor,
          iconData: item.icon,
          size: widgetSize,
          iconColor: item.theme.colorScheme.primary,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class PieChartDataItem {
  final double value;
  final IconData icon;
  final ThemeData theme;

  PieChartDataItem({
    required this.value,
    required this.theme,
    required this.icon
  });
}

class _Badge extends StatelessWidget {
  final Color backColor;
  final IconData iconData;
  final double size;
  final Color iconColor;

  const _Badge({
    required this.backColor,
    required this.iconData,
    required this.size,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backColor,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: size * 0.6,
        ),
      ),
    );
  }
}
