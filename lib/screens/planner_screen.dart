import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/widgets/horizontal_dates.dart';
import 'package:dayline_planner/widgets/task_tile.dart';
import 'create_task_screen.dart';

class PlannerScreen extends StatefulWidget {
  static const routeName = '/planner';
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late PageController _pageController;
  final int windowDays = 21; // show +/- 10 days
  late int centerIndex;
  DateTime baseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    centerIndex = windowDays ~/ 2;
    _pageController = PageController(initialPage: centerIndex);
  }

  DateTime dateForIndex(int idx) {
    final offset = idx - centerIndex;
    return DateTime.now().add(Duration(days: offset));
  }

  String labelForSection(String key) {
    switch (key) {
      case 'wake':
        return 'Wake up (6-8)';
      case 'morning':
        return 'Morning (8-12)';
      case 'noon':
        return 'Noon (12-13)';
      case 'afternoon':
        return 'Afternoon (13-17)';
      case 'evening':
        return 'Evening (17-22)';
      default:
        return key;
    }
  }

  final sections = ['wake', 'morning', 'noon', 'afternoon', 'evening'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => Navigator.pushNamed(context, '/tasks'),
            tooltip: 'Tasks',
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'Profile',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, CreateTaskScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft, // 👈 only this child is left-aligned
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0), // 👈 space from the left
              child: Text(
                'Dayline Planner',
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: HorizontalDates(
              windowDays: windowDays,
              dateForIndex: dateForIndex,
              pageController: _pageController,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: windowDays,
              onPageChanged: (idx) {
                setState(() {
                  baseDate = dateForIndex(idx);
                });
              },
              itemBuilder: (context, idx) {
                final day = dateForIndex(idx);
                final tasks = provider.tasksForDate(day);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.map((s) {
                      final sectionTasks = tasks.where((t) => t.section == s).toList();
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(labelForSection(s), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        CreateTaskScreen.routeName,
                                        arguments: {'defaultDate': day, 'defaultSection': s},
                                      );
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (sectionTasks.isEmpty)
                                const Text('No tasks')
                              else
                                Column(
                                  children: sectionTasks.map((t) => TaskTile(task: t, date: day)).toList(),
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
