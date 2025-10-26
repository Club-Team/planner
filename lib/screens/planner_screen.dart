import 'dart:io';
import 'package:dayline_planner/models/section_model.dart';
import 'package:dayline_planner/utils/icon_helper.dart';
import 'package:dayline_planner/widgets/pie_chart.dart';
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
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_fabVisible) setState(() => _fabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
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

  final sections = ['wake', 'morning', 'noon', 'afternoon', 'evening'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: _avatarPath != null
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
              layoutBuilder: (currentChild, _) =>
                  currentChild ?? const SizedBox(),
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

  Widget _buildDayContent(
      DateTime day, TaskProvider provider, ThemeData theme) {
    final tasks = provider.tasksForDate(day);
    final sectionProvider = Provider.of<SectionProvider>(context);
    List<Section> tasksSections = sectionProvider.fullSections.where((s) => tasks.map((t) => t.section).toList().contains(s.id)).toList();
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    List<Section> sections;

    if (normalizedDay.isBefore(normalizedToday)) {
      sections = tasksSections;
    } else {
      sections = sectionProvider.fullSections;
    }

    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'No Tasks Found',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have no tasks scheduled for this day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sections.map((section) {
            final sectionTasks =
                tasks.where((t) => t.section == section.id).toList();
            final start = section.startTime.format(context);
            final end = section.endTime.format(context);
            return Card(
              color: theme.cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          IconHelper.getIconData(section.iconName),
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${section.title} ($start - $end)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        if (!normalizedDay.isBefore(normalizedToday)) ...[
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: theme.colorScheme.primary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTaskScreen(
                                    task: null,
                                    initialDate: day,
                                    section: section.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ]
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
            child: !normalizedDay.isBefore(normalizedToday)
              ?BarChart(
                BarChartDataBuilder.build(
                  theme,
                  sections.map((s) {
                    final total =
                        tasks.where((t) => t.section == s.id).length.toDouble();
                    final completed = tasks
                        .where((t) =>
                            t.section == s.id &&
                            provider.isTaskCompletedOn(
                                t, dateForIndex(selectedDayIndex)))
                        .length
                        .toDouble();
                    return [total, completed];
                  }).toList(),
                  sections: sections,
                ),
              )
              : Center(child: CustomPieChart(
                data: sections.map((s) {
                  final total =
                        tasks.where((t) => t.section == s.id).length.toDouble();
                  final completed = tasks
                      .where((t) =>
                          t.section == s.id &&
                          provider.isTaskCompletedOn(
                              t, dateForIndex(selectedDayIndex)))
                      .length
                      .toDouble();
                  return PieChartDataItem(
                    value: ((completed / total) * 100).round().toDouble(),
                    theme: theme,
                    icon: IconHelper.getIconData(s.iconName)
                  );
                }).toList(),
              ))
          ),
        ],
      ),
    );
  }
}