import 'package:dayline_planner/models/section_model.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/widgets/section_card_header.dart';
import 'package:dayline_planner/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SectionCard extends StatelessWidget {
  final Section section;
  final List<TaskModel> tasks;
  final bool isReadOnly;
  final DateTime date;

  const SectionCard({
    required this.section,
    required this.tasks,
    required this.isReadOnly,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = tasks
        .where((t) =>
            Provider.of<TaskProvider>(context).isTaskCompletedOn(t, date))
        .length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;
    final start = section.startTime.format(context);
    final end = section.endTime.format(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        child: Column(
          children: [
            SectionCardHeader(
              section: section,
              progress: progress,
              start: start,
              end: end,
              completedCount: completedCount,
              totalTasks: tasks.length, // <-- Pass it here
              isReadOnly: isReadOnly,
              date: date,
            ),
            tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No tasks', style: theme.textTheme.bodyMedium),
                  )
                : Column(
                    children: tasks
                        .map((t) =>
                            TaskTile(task: t, date: date, readOnly: isReadOnly))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
