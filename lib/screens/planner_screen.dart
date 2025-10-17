import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'create_task_screen.dart';

class PlannerScreen extends StatefulWidget {
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
        title: const Text('Dayline Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pushNamed(context, '/tasks'),
            tooltip: 'Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, CreateTaskScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 86,
            child: _buildHorizontalDates(),
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(labelForSection(s), style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.add),
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
                                  children: sectionTasks.map((t) => _taskTile(t, day)).toList(),
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

  Widget _buildHorizontalDates() {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: windowDays,
        itemBuilder: (context, idx) {
          final d = dateForIndex(idx);
          final isToday = DateFormat('yyyy-MM-dd').format(d) == DateFormat('yyyy-MM-dd').format(DateTime.now());
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat.E().format(d), style: TextStyle(color: isToday ? Colors.white : Colors.black)),
                  const SizedBox(height: 6),
                  Text(DateFormat.d().format(d), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _taskTile(TaskModel t, DateTime date) {
    final provider = Provider.of<TaskProvider>(context);
    final done = provider.isTaskCompletedOn(t, date);
    return ListTile(
      title: Text(t.title),
      subtitle: t.description == null ? null : Text(t.description!),
      trailing: Checkbox(
        value: done,
        onChanged: (v) {
          provider.markCompleted(t, date, v ?? false);
        },
      ),
      onLongPress: () {
        // edit? not implemented fully; could route to create with editing
      },
    );
  }
}
