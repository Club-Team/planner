import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/providers/section_provider.dart';
import 'package:dayline_planner/utils/icon_helper.dart';
import 'package:dayline_planner/widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = '/tasks';
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _daysToShow = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _daysToShow, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getRelativeDay(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final difference = normalizedDate.difference(normalizedToday).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final sectionProvider = Provider.of<SectionProvider>(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    final days = List.generate(_daysToShow, (i) => today.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Upcoming Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: theme.appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              // Remove the default bottom divider under the TabBar
              dividerColor: Colors.transparent,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: days.map((day) {
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_getRelativeDay(day)),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d').format(day),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          final tasks = provider.tasksForDate(day);
          final sections = sectionProvider.fullSections;
          
          // Filter tasks to only include those in active (non-deleted) sections
          final activeSections = sections.where((s) => !s.isDeleted).toList();
          final activeTasks = tasks.where((task) {
            return activeSections.any((section) => section.id == task.section);
          }).toList();

          if (activeTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All Clear!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No tasks scheduled for ${_getRelativeDay(day).toLowerCase()}',
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Task summary card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.assignment_outlined,
                        label: 'Total',
                        value: activeTasks.length.toString(),
                        theme: theme,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        value: activeTasks.where((t) => provider.isTaskCompletedOn(t, day)).length.toString(),
                        theme: theme,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        icon: Icons.pending_outlined,
                        label: 'Pending',
                        value: activeTasks.where((t) => !provider.isTaskCompletedOn(t, day)).length.toString(),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tasks grouped by section
              ...activeSections.where((section) {
                return activeTasks.any((task) => task.section == section.id);
              }).map((section) {
                final sectionTasks = activeTasks.where((t) => t.section == section.id).toList();
                final completedCount = sectionTasks.where((t) => provider.isTaskCompletedOn(t, day)).length;
                final progress = sectionTasks.isEmpty ? 0.0 : completedCount / sectionTasks.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: theme.cardColor,
                    child: Column(
                      children: [
                        // Section header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconHelper.getIconData(section.iconName),
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          section.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onBackground,
                                          ),
                                        ),
                                        Text(
                                          '${section.startTime.format(context)} - ${section.endTime.format(context)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$completedCount/${sectionTasks.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animatedValue, _) {
                                    return LinearProgressIndicator(
                                      value: animatedValue.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tasks list (reuse shared TaskTile for consistency with Planner screen)
                        ...sectionTasks
                            .map((t) => TaskTile(task: t, date: day))
                            .toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
