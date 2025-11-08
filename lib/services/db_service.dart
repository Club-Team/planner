import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/models/completion_model.dart';

class DBService {
  DBService._private();
  static final DBService instance = DBService._private();

  static Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dayline.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate, onOpen: (db) async {
        // Enable foreign key constraints in SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        section TEXT,
        isRecurring INTEGER,
        recurrenceType INTEGER,
        everyNDays INTEGER,
        weekdays TEXT,
        date TEXT,
        createdAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        dateIso TEXT,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<int> insertTask(TaskModel t) async {
    return await _db!.insert('tasks', t.toMap());
  }

  Future<int> updateTask(TaskModel t) async {
    return await _db!
        .update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTask(int id) async {
    return await _db!.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final rows = await _db!.query('tasks');
    return rows.map((r) => TaskModel.fromMap(r)).toList();
  }

  Future<int> addCompletion(Completion c) async {
    return await _db!.insert('completions', c.toMap());
  }

  Future<int> removeCompletion(int taskId, String dateIso) async {
    return await _db!.delete('completions',
        where: 'taskId = ? AND dateIso = ?', whereArgs: [taskId, dateIso]);
  }

  Future<List<Completion>> getCompletionsForDate(String dateIso) async {
    final rows = await _db!
        .query('completions', where: 'dateIso = ?', whereArgs: [dateIso]);
    return rows.map((r) => Completion.fromMap(r)).toList();
  }

  Future<List<Completion>> getAllCompletions() async {
    final rows = await _db!.query('completions');
    return rows.map((r) => Completion.fromMap(r)).toList();
  }
}
