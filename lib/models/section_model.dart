import 'package:flutter/material.dart';

class Section {
  String id;
  String title;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String iconName; // <- new field
  bool isDeleted;

  Section({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.iconName = 'schedule', // default icon
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'iconName': iconName,
        'isDeleted': isDeleted,
      };

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        id: json['id'],
        title: json['title'],
        startTime: TimeOfDay(
            hour: json['startHour'] ?? 0, minute: json['startMinute'] ?? 0),
        endTime: TimeOfDay(
            hour: json['endHour'] ?? 0, minute: json['endMinute'] ?? 0),
        iconName: json['iconName'] ?? 'schedule',
        isDeleted: json['isDeleted'] ?? false,
      );

  static TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
