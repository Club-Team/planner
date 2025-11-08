import 'package:dayline_planner/models/section_model.dart';
import 'package:dayline_planner/screens/edit_task_screen.dart';
import 'package:dayline_planner/utils/icon_helper.dart';
import 'package:flutter/material.dart';

class SectionCardHeader extends StatelessWidget {
  final Section section;
  final double progress;
  final String start;
  final String end;
  final int completedCount;
  final int totalTasks; // <-- Add this
  final bool isReadOnly;
  final DateTime date;

  const SectionCardHeader({
    required this.section,
    required this.progress,
    required this.start,
    required this.end,
    required this.completedCount,
    required this.totalTasks, // <-- Add this
    required this.isReadOnly,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
                child: Icon(IconHelper.getIconData(section.iconName),
                    color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground)),
                    Text('$start - $end',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onBackground
                                .withOpacity(0.6))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$completedCount/$totalTasks', // <-- use totalTasks
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 12)),
              ),
              if (!isReadOnly)
                IconButton(
                  icon: const Icon(Icons.add),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTaskScreen(
                            task: null, initialDate: date, section: section.id),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) => LinearProgressIndicator(
                value: animatedValue.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.onBackground.withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
