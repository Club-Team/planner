import 'package:flutter/material.dart';

class Section {
  final String id;
  String title;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isDeleted;

  Section({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isDeleted = false,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      title: json['title'],
      startTime: _parseTime(json['start']),
      endTime: _parseTime(json['end']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start': _formatTime(startTime),
        'end': _formatTime(endTime),
        'isDeleted': isDeleted,
      };

  static TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
