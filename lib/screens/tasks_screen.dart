import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/models/task_model.dart';

class TasksScreen extends StatelessWidget {
  static const routeName = '/tasks';
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final today = DateTime.now();
    final days = List.generate(3, (i) => today.add(Duration(days: i)));
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks (today + 2 days)')),
      body: ListView(
        children: days.map((d) {
          final tasks = provider.tasksForDate(d);
          return ExpansionTile(
            title: Text(DateFormat.yMMMMd().format(d)),
            children: tasks.isEmpty
                ? [const ListTile(title: Text('No tasks'))]
                : tasks
                    .map((t) => ListTile(
                          title: Text(t.title),
                          subtitle: Text(t.section),
                          trailing: Checkbox(
                            value: provider.isTaskCompletedOn(t, d),
                            onChanged: (v) => provider.markCompleted(t, d, v ?? false),
                          ),
                        ))
                    .toList(),
          );
        }).toList(),
      ),
    );
  }
}
