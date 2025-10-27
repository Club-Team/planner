import 'package:dayline_planner/providers/section_provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DayContent extends StatelessWidget {
  final DateTime date;
  final ScrollController scrollController;

  const DayContent({
    required this.date,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasksForDate(date);
    final sectionProvider = Provider.of<SectionProvider>(context);

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(date.year, date.month, date.day);
    final isReadOnly = normalizedDay.isBefore(normalizedToday);

    final sections = isReadOnly
        ? sectionProvider.fullSections
            .where((s) => tasks.map((t) => t.section).contains(s.id))
            .toList()
        : sectionProvider.fullSections;

    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined,
                  size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 24),
              Text('No Tasks Found',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground)),
              const SizedBox(height: 12),
              Text('You have no tasks scheduled for this day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      height: 1.5)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController, 
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) {
          final sectionTasks = tasks.where((t) => t.section == section.id).toList();
          return SectionCard(
            section: section,
            tasks: sectionTasks,
            isReadOnly: isReadOnly,
            date: date,
          );
        }).toList(),
      ),
    );
  }
}
