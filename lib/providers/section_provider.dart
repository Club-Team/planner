import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/section_model.dart';

class SectionProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<Section> _sections = [];

  /// Temporary backward-compatible getter

  List<String> get sections =>
      _sections.where((s) => !s.isDeleted).map((s) => s.title).toList();

  /// Access full objects if needed
  List<String> get sortedSectionTitles {
    return fullSections.map((s) => s.title).toList();
  }

  SectionProvider() {
    loadSections();
  }
  List<Section> get fullSections {
    final activeSections = _sections.where((s) => !s.isDeleted).toList();
    activeSections.sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return activeSections;
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
            endTime: const TimeOfDay(hour: 8, minute: 0),
            iconName: 'wb_sunny'),
        Section(
            id: _uuid.v4(),
            title: 'Morning',
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endTime: const TimeOfDay(hour: 12, minute: 0),
            iconName: 'coffee'),
        Section(
            id: _uuid.v4(),
            title: 'Noon',
            startTime: const TimeOfDay(hour: 12, minute: 0),
            endTime: const TimeOfDay(hour: 14, minute: 0),
            iconName: 'lunch_dining'),
        Section(
            id: _uuid.v4(),
            title: 'Afternoon',
            startTime: const TimeOfDay(hour: 14, minute: 0),
            endTime: const TimeOfDay(hour: 18, minute: 0),
            iconName: 'work'),
        Section(
            id: _uuid.v4(),
            title: 'Evening',
            startTime: const TimeOfDay(hour: 18, minute: 0),
            endTime: const TimeOfDay(hour: 22, minute: 0),
            iconName: 'nightlight_round'),
      ];
      await _save(); // persist defaults
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userSectionsV2',
        jsonEncode(_sections.map((s) => s.toJson()).toList()));
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
      String title, TimeOfDay start, TimeOfDay end, String iconName) async {
    // if (_isOverlapping(start, end)) {
    //   return 'Time overlaps with another section';
    // }

    final newSec = Section(
      id: _uuid.v4(),
      title: title,
      startTime: start,
      endTime: end,
      iconName: iconName,
    );
    _sections.add(newSec);
    await _save();
    notifyListeners();
    return null;
  }

  Future<String?> updateSection(Section sec, String newTitle, TimeOfDay start,
      TimeOfDay end, String iconName) async {
    if (_isOverlapping(start, end, sec.id)) {
      return 'Time overlaps with another section';
    }

    sec.title = newTitle;
    sec.startTime = start;
    sec.endTime = end;
    sec.iconName = iconName;
    await _save();
    notifyListeners();
    return null;
  }

  Future<void> removeSection(String id) async {
    final sec = _sections.firstWhere((s) => s.id == id);
    sec.isDeleted = true;
    await _save();
    notifyListeners();
  }
}
