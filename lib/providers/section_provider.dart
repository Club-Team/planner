import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SectionProvider extends ChangeNotifier {
  List<String> _sections = [];

  List<String> get sections => _sections;

  SectionProvider() {
    loadSections();
  }

  Future<void> loadSections() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('userSections') ?? [];
    if (stored.isEmpty) {
      _sections = ['wake', 'morning', 'noon', 'afternoon', 'evening'];
    } else {
      _sections = stored;
    }
    notifyListeners();
  }

  Future<void> addSection(String section) async {
    if (!_sections.contains(section)) {
      _sections.add(section);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('userSections', _sections);
      notifyListeners();
    }
  }

  Future<void> removeSection(String section) async {
    _sections.remove(section);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('userSections', _sections);
    notifyListeners();
  }
}
