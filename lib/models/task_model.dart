import 'package:flutter/foundation.dart';

enum RecurrenceType {
  none,
  daily,
  everyNDays,
  specificWeekDays,
}

class TaskModel {
  int? id;
  String title;
  String? description;
  String section; // e.g. "wake", "morning", "noon", "afternoon", "evening"
  bool isRecurring;
  RecurrenceType recurrenceType;
  int everyNDays; // used when recurrenceType == everyNDays
  List<int> weekdays; // 1..7 (Mon=1) used when specificWeekDays
  DateTime
      date; // the base date for non-recurring tasks or start date for recurring
  DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.section,
    this.isRecurring = false,
    this.recurrenceType = RecurrenceType.none,
    this.everyNDays = 1,
    List<int>? weekdays,
    DateTime? date,
    DateTime? createdAt,
  })  : weekdays = weekdays ?? [],
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'section': section,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceType': recurrenceType.index,
      'everyNDays': everyNDays,
      'weekdays': weekdays.join(','), // store as CSV
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> m) {
    final wk = (m['weekdays'] as String?) ?? '';
    return TaskModel(
      id: m['id'] as int?,
      title: m['title'] ?? '',
      description: m['description'],
      section: m['section'] ?? 'morning',
      isRecurring: (m['isRecurring'] ?? 0) == 1,
      recurrenceType: RecurrenceType.values[(m['recurrenceType'] ?? 0) as int],
      everyNDays: (m['everyNDays'] ?? 1) as int,
      weekdays: wk.isEmpty
          ? []
          : wk
              .split(',')
              .map((s) => int.tryParse(s) ?? 0)
              .where((i) => i > 0)
              .toList(),
      date: DateTime.parse(m['date']),
      createdAt: DateTime.parse(m['createdAt']),
    );
  }
}
