import 'package:dayline_planner/widgets/horizontal_dates.dart';
import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final int windowDays;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final DateTime Function(int) dateForIndex;

  const DaySelector({
    required this.windowDays,
    required this.selectedIndex,
    required this.onSelected,
    required this.dateForIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: HorizontalDates(
        windowDays: windowDays,
        selectedIndex: selectedIndex,
        dateForIndex: dateForIndex,
        onSelected: onSelected,
      ),
    );
  }
}
