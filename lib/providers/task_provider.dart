import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/models/completion_model.dart';
import 'package:dayline_planner/services/db_service.dart';

class TaskProvider extends ChangeNotifier {
  final DBService _db = DBService.instance;
  List<TaskModel> _tasks = [];
  List<Completion> _completions = [];

  List<TaskModel> get tasks => _tasks;
  List<Completion> get completions => _completions;

  Future<void> loadAll() async {
    _tasks = await _db.getAllTasks();
    _completions = await _db.getAllCompletions();
    notifyListeners();
  }

  Future<void> addTask(TaskModel t) async {
    final id = await _db.insertTask(t);
    t.id = id;
    _tasks.add(t);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel t) async {
    await _db.updateTask(t);
    final idx = _tasks.indexWhere((e) => e.id == t.id);
    if (idx != -1) _tasks[idx] = t;
    notifyListeners();
  }

  Future<void> deleteTask(TaskModel t) async {
    if (t.id != null) {
      await _db.deleteTask(t.id!);
      _tasks.removeWhere((e) => e.id == t.id);
      notifyListeners();
      _completions.removeWhere((e) => e.taskId == t.id);
      notifyListeners();
    }
  }

  String _dateIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> markCompleted(TaskModel t, DateTime date, bool done) async {
    final iso = _dateIso(date);
    if (t.id == null) return;
    if (done) {
      final c = Completion(taskId: t.id!, dateIso: iso);
      await _db.addCompletion(c);
      _completions.add(c);
    } else {
      await _db.removeCompletion(t.id!, iso);
      _completions.removeWhere((c) => c.taskId == t.id && c.dateIso == iso);
    }
    notifyListeners();
  }

  bool isTaskCompletedOn(TaskModel t, DateTime date) {
    final iso = _dateIso(date);
    return _completions.any((c) => c.taskId == t.id && c.dateIso == iso);
  }

  // Determine if a task occurs on given date (consider recurrence)
  bool occursOn(TaskModel t, DateTime date) {
    final dOnly = DateTime(date.year, date.month, date.day);
    final base = DateTime(t.date.year, t.date.month, t.date.day);

    if (!t.isRecurring) {
      return dOnly == base;
    }

    switch (t.recurrenceType) {
      case RecurrenceType.daily:
        return !dOnly.isBefore(base);
      case RecurrenceType.everyNDays:
        if (dOnly.isBefore(base)) return false;
        final diff = dOnly.difference(base).inDays;
        return diff % t.everyNDays == 0;
      case RecurrenceType.specificWeekDays:
        // in our model weekdays are 1..7 where Monday=1
        final weekday = dOnly.weekday; // 1..7 (Mon=1)
        if (!t.weekdays.contains(weekday)) return false;
        return !dOnly.isBefore(base);
      default:
        return false;
    }
  }

  // Return tasks for a specific date, grouped or ungrouped
  List<TaskModel> tasksForDate(DateTime date) {
    return _tasks.where((t) => occursOn(t, date)).toList()
      ..sort((a, b) => a.section.compareTo(b.section));
  }

  // total completed count across all dates
  int totalCompletedCount() => _completions.length;
}
