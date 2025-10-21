import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/widgets/horizontal_dates.dart';
import 'package:dayline_planner/widgets/task_tile.dart';
import 'package:dayline_planner/widgets/bar_chart.dart';
import 'package:dayline_planner/screens/edit_task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayline_planner/providers/section_provider.dart';

class PlannerScreen extends StatefulWidget {
  static const routeName = '/planner';
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final int windowDays = 21; // +/- 10 days around today
  late int centerIndex;
  late int selectedDayIndex;
  String? _avatarPath;
  final ScrollController _scrollController = ScrollController();
  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();
    centerIndex = windowDays ~/ 2;
    selectedDayIndex = centerIndex;
    _loadAvatar();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_fabVisible) setState(() => _fabVisible = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_fabVisible) setState(() => _fabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatarPath');
    if (mounted) setState(() => _avatarPath = path);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Rebuild on theme change
  }

  DateTime dateForIndex(int idx) {
    final offset = idx - centerIndex;
    return DateTime.now().add(Duration(days: offset));
  }

  String labelForSection(String key) {
    switch (key) {
      case 'wake':
        return 'Wake up (6–8)';
      case 'morning':
        return 'Morning (8–12)';
      case 'noon':
        return 'Noon (12–13)';
      case 'afternoon':
        return 'Afternoon (13–17)';
      case 'evening':
        return 'Evening (17–22)';
      default:
        return key;
    }
  }

  final sections = ['wake', 'morning', 'noon', 'afternoon', 'evening'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:  _avatarPath != null
          ? CircleAvatar(
              radius: 14,
              backgroundImage: FileImage(File(_avatarPath!)),
            )
          : const Icon(Icons.person),
          tooltip: 'Profile',
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Tasks',
            onPressed: () => Navigator.pushNamed(context, '/tasks'),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _fabVisible ? Offset.zero : const Offset(2, 0),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _fabVisible ? 1 : 0,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(
                    task: null,
                    initialDate: dateForIndex(selectedDayIndex),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
              child: const Text(
                'Dayline Planner',
                style: TextStyle(
                  fontSize: 42,
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
              selectedIndex: selectedDayIndex,
              onSelected: (idx) {
                if (idx != selectedDayIndex) {
                  setState(() => selectedDayIndex = idx);
                }
              },
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
                child: ScaleTransition(
                  scale: Tween(begin: 0.97, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              layoutBuilder: (currentChild, _) => currentChild ?? const SizedBox(),
              child: KeyedSubtree(
                key: ValueKey<int>(selectedDayIndex),
                child: _buildDayContent(
                  dateForIndex(selectedDayIndex),
                  provider,
                  theme,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(DateTime day, TaskProvider provider, ThemeData theme) {
    final tasks = provider.tasksForDate(day);
    final sectionProvider = Provider.of<SectionProvider>(context);
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ... sectionProvider.sections.map((section) {
          final sectionTasks = tasks.where((t) => t.section == section).toList();
          return Card(
            color: theme.cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelForSection(section),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditTaskScreen(task: null, initialDate: dateForIndex(selectedDayIndex), section: section),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (sectionTasks.isEmpty)
                    Text(
                      'No tasks',
                      style: theme.textTheme.bodyMedium,
                    )
                  else
                    Column(
                      children: sectionTasks
                          .map((t) => TaskTile(task: t, date: day))
                          .toList(),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartDataBuilder.build(
                theme,
                sectionProvider.sections.map((s) => [tasks.where((t) => t.section == s).length.toDouble(), tasks.where((t) => t.section == s && provider.isTaskCompletedOn(t, dateForIndex(selectedDayIndex))).length.toDouble()]).toList(),
                labels: sectionProvider.sections,
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeOut,
            ),
          ),
        ]
      ),
    );
  }
}
