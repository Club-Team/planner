import 'package:flutter/material.dart';

class AppTheme {
  // Define colors
  static final Color primaryColor = "#4a9e99".toColor();
  static final Color backgroundColor = "#faf6f0".toColor();
  static final Color accentColor = "#5a8282".toColor(); // optional

  // Main theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(primaryColor),
      trackColor: MaterialStateProperty.all(primaryColor.withOpacity(0.4)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );
}

// Extension to convert hex string to Color
extension HexColor on String {
  Color toColor() {
    String hex = replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse(hex, radix: 16));
  }
}
