import 'package:flutter/material.dart';

class AppTheme {
  // Define colors
  static final Color primaryColor = "#559390".toColor();
  static final Color backgroundColor = "#F7F0E6".toColor();
  static final Color accentColor = "#5a8282".toColor(); // optional

  // Main theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: Color.fromRGBO(250, 246, 237, 1.0),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: Color.fromRGBO(39, 39, 37, 1.0),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Color.fromRGBO(39, 39, 37, 1.0),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0)),
      bodyMedium: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0)),
      bodySmall: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0))
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
