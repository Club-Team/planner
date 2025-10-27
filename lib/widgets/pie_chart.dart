import 'package:dayline_planner/models/section_model.dart';
import 'package:dayline_planner/providers/section_provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/utils/icon_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPieChart extends StatefulWidget {
  final DateTime date;

  const CustomPieChart({
    required this.date,
    super.key
  });

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
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasksForDate(widget.date);
    final sectionProvider = Provider.of<SectionProvider>(context);
    final sections = sectionProvider.fullSections
            .where((s) => tasks.map((t) => t.section).contains(s.id))
            .toList();
    final data = sections.map((s) {
                  final total =
                        tasks.where((t) => t.section == s.id).length.toDouble();
                  final completed = tasks
                      .where((t) =>
                          t.section == s.id &&
                          provider.isTaskCompletedOn(
                              t, widget.date))
                      .length
                      .toDouble();
                  return ((completed / total) * 100).round().toDouble();;
                }).toList();

    return List.generate(sections.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      return PieChartSectionData(
        color: Theme.of(context).colorScheme.primary,
        value: data[i],
        title: '${data[i]}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).cardColor,
        ),
        badgeWidget: _Badge(
          backColor: Theme.of(context).cardColor,
          iconData: IconHelper.getIconData(sections[i].iconName),
          size: widgetSize,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
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