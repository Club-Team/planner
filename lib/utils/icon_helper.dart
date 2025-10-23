import 'package:flutter/material.dart';

class IconHelper {
  IconHelper._(); // private constructor to prevent instantiation
  // helper map for consistent icon lookup
  static final Map<String, IconData> _icons = {
    'wb_sunny': Icons.wb_sunny,
    'coffee': Icons.coffee,
    'lunch_dining': Icons.lunch_dining,
    'work': Icons.work,
    'nightlight_round': Icons.nightlight_round,
    'book': Icons.book,
    'fitness_center': Icons.fitness_center,
    'schedule': Icons.schedule,
    'alarm': Icons.alarm,
    'school': Icons.school,
    'music_note': Icons.music_note,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'directions_run': Icons.directions_run,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'shopping_cart': Icons.shopping_cart,
    'beach_access': Icons.beach_access,
    'pets': Icons.pets,
    'flight': Icons.flight,
    'brush': Icons.brush,
    'camera_alt': Icons.camera_alt,
    'local_grocery_store': Icons.local_grocery_store,
    'terrain': Icons.terrain,
    'directions_bike': Icons.directions_bike,
    'sports_soccer': Icons.sports_soccer,
    'theaters': Icons.theaters,
    'mic': Icons.mic,
    'gamepad': Icons.gamepad,
    'local_library': Icons.local_library,
  };
  static IconData getIconData(String name) {
    return _icons[name] ?? Icons.circle;
  }
}
