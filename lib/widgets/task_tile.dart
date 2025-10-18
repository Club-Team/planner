import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/screens/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final DateTime date;

  const TaskTile({
    super.key,
    required this.task,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final done = provider.isTaskCompletedOn(task, date);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        task.title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: done ? TextDecoration.lineThrough : null,
          color: done ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: task.description == null
          ? null
          : Text(
              task.description!,
              style: TextStyle(
                color: done ? Colors.grey : Colors.black87,
              ),
            ),
      trailing: GestureDetector(
        onTap: () {
          provider.markCompleted(task, date, !done);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: done
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
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
        onLongPress: () {
        // TODO: Add edit navigation later
      },
    );
  }
}
