import 'dart:convert';
import 'package:dayline_planner/models/section_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SectionProvider extends ChangeNotifier {
  final _uuid = Uuid();
  List<Section> _sections = [];

  /// Temporary backward-compatible getter
  List<String> get sections =>
      _sections.where((s) => !s.isDeleted).map((s) => s.title).toList();

  /// Access full objects if needed
  List<Section> get fullSections => _sections;

  SectionProvider() {
    loadSections();
  }

  Future<void> loadSections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userSectionsV2');
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      _sections = decoded.map((j) => Section.fromJson(j)).toList();
    } else {
      _sections = [
        Section(
            id: _uuid.v4(),
            title: 'Wake',
            startTime: const TimeOfDay(hour: 6, minute: 0),
            endTime: const TimeOfDay(hour: 8, minute: 0)),
        Section(
            id: _uuid.v4(),
            title: 'Morning',
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endTime: const TimeOfDay(hour: 12, minute: 0)),
        Section(
            id: _uuid.v4(),
            title: 'Noon',
            startTime: const TimeOfDay(hour: 12, minute: 0),
            endTime: const TimeOfDay(hour: 13, minute: 0)),
        Section(
            id: _uuid.v4(),
            title: 'Afternoon',
            startTime: const TimeOfDay(hour: 13, minute: 0),
            endTime: const TimeOfDay(hour: 17, minute: 0)),
        Section(
            id: _uuid.v4(),
            title: 'Evening',
            startTime: const TimeOfDay(hour: 17, minute: 0),
            endTime: const TimeOfDay(hour: 21, minute: 0)),
        Section(
            id: _uuid.v4(),
            title: 'Night',
            startTime: const TimeOfDay(hour: 21, minute: 0),
            endTime: const TimeOfDay(hour: 22, minute: 0)),
      ];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'userSectionsV2', jsonEncode(_sections.map((s) => s.toJson()).toList()));
  }

  bool _isOverlapping(TimeOfDay start, TimeOfDay end, [String? excludeId]) {
    for (final s in _sections.where((s) => !s.isDeleted)) {
      if (excludeId != null && s.id == excludeId) continue;
      final sStart = s.startTime.hour * 60 + s.startTime.minute;
      final sEnd = s.endTime.hour * 60 + s.endTime.minute;
      final nStart = start.hour * 60 + start.minute;
      final nEnd = end.hour * 60 + end.minute;
      if (nStart < sEnd && nEnd > sStart) return true;
    }
    return false;
  }

  Future<String?> addSection(
      String title, TimeOfDay start, TimeOfDay end) async {
    if (_isOverlapping(start, end)) {
      return 'Time overlaps with another section';
    }

    final newSec = Section(
      id: _uuid.v4(),
      title: title,
      startTime: start,
      endTime: end,
    );
    _sections.add(newSec);
    await _save();
    notifyListeners();
    return null;
  }

  Future<String?> updateSection(
      Section sec, String newTitle, TimeOfDay start, TimeOfDay end) async {
    if (_isOverlapping(start, end, sec.id)) {
      return 'Time overlaps with another section';
    }

    sec.title = newTitle;
    sec.startTime = start;
    sec.endTime = end;
    await _save();
    notifyListeners();
    return null;
  }

  Future<void> removeSection(String id) async {
    final sec = _sections.firstWhere((s) => s.id == id);
    sec.isDeleted = true; // soft delete
    await _save();
    notifyListeners();
  }
}
