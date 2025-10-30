import 'package:flutter/material.dart';
import 'light_theme.dart'; // reuse HexColor extension

class DarkAppTheme {
  static final Color primaryColor = "#4DD0E1".toColor();
  static final Color backgroundColor = "#121212".toColor();
  static final Color accentColor = "#26C6DA".toColor();

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Rubik',
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.black,
      secondary: accentColor,
      onSecondary: Colors.black,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      background: backgroundColor,
      onBackground: const Color(0xFFE3E3E3),
      surface: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFE3E3E3),
      surfaceVariant: const Color(0xFF2A2A2A),
      onSurfaceVariant: const Color(0xFFCBCBCB),
      outline: const Color(0xFF8A8A8A),
      shadow: Colors.black,
      inverseSurface: const Color(0xFFE6E1DB),
      onInverseSurface: const Color(0xFF2E312F),
      inversePrimary: const Color(0xFF166A73),
      tertiary: const Color(0xFF7BB2AF),
      onTertiary: const Color(0xFF0F1716),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white70),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor; // Thumb color when ON
        }
        return Colors.grey.shade400; // Thumb color when OFF
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5); // Track when ON
        }
        return Colors.grey.shade700.withOpacity(0.4); // Track when OFF
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return primaryColor.withOpacity(0.2); // Ripple effect
        }
        return Colors.transparent;
      }),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      textColor: Colors.white70, // title text color for all ListTiles & SwitchListTiles
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      hintStyle: TextStyle(color: Colors.grey[400]),
      labelStyle: TextStyle(color: Colors.grey[600]),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x22FFFFFF),
      thickness: 1,
      space: 24,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: primaryColor.withOpacity(0.25),
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.12),
      trackHeight: 4,
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
    ),
  );
}
