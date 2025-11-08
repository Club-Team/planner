import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/screens/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final DateTime date;
  final bool readOnly;

  const TaskTile({
    super.key,
    required this.task,
    required this.date,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final done = provider.isTaskCompletedOn(task, date);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final titleColor =
        done ? theme.disabledColor : textTheme.bodyLarge?.color ?? Colors.black;

    final subtitleColor = done
        ? theme.disabledColor.withOpacity(0.7)
        : textTheme.bodyMedium?.color?.withOpacity(0.9) ?? Colors.black87;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        task.title,
        style: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: done ? TextDecoration.lineThrough : null,
          color: titleColor,
        ),
      ),
      subtitle: task.description == null
          ? null
          : Text(
              task.description!,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
      trailing: GestureDetector(
        onTap: () {
          // if (readOnly) return;
          provider.markCompleted(task, date, !done);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? colorScheme.primary
                  : theme.dividerColor.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: done
              ? Icon(
                  Icons.check,
                  color: colorScheme.onPrimary,
                  size: 18,
                )
              : null,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditTaskScreen(task: task),
          ),
        );
      },
    );
  }
}
