import 'package:flutter/material.dart';
import 'light_theme.dart'; // reuse HexColor extension

class DarkAppTheme {
  static final Color primaryColor = "#4DD0E1".toColor();
  static final Color backgroundColor = "#121212".toColor();
  static final Color accentColor = "#26C6DA".toColor();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white70),
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
