import 'package:flutter/material.dart';

class AppTheme {
  // Define colors
  static final Color primaryColor = "#559390".toColor();
  static final Color backgroundColor = "#F7F0E6".toColor();
  static final Color accentColor = "#5a8282".toColor(); // optional

  // Main theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Rubik',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: const Color.fromRGBO(250, 246, 237, 1.0),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: const Color(0xFF272725),
      secondary: accentColor,
      onSecondary: const Color(0xFF23302F),
      error: const Color(0xFFBA1A1A),
      onError: const Color(0xFFFFFFFF),
      background: backgroundColor,
      onBackground: const Color.fromRGBO(39, 39, 37, 1.0),
      surface: const Color.fromRGBO(250, 246, 237, 1.0),
      onSurface: const Color.fromRGBO(39, 39, 37, 1.0),
      surfaceVariant: const Color(0xFFE7E1D7),
      onSurfaceVariant: const Color(0xFF49473F),
      outline: const Color(0xFF7E7667),
      shadow: Colors.black.withOpacity(0.25),
      inverseSurface: const Color(0xFF2E312F),
      onInverseSurface: const Color(0xFFE6E1DB),
      inversePrimary: const Color(0xFF4AB2AE),
      // M3 requires 'tertiary' too; map to accent variant
      tertiary: const Color(0xFF7BB2AF),
      onTertiary: const Color(0xFF223130),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: const Color.fromRGBO(39, 39, 37, 1.0),
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
        foregroundColor: const Color.fromRGBO(39, 39, 37, 1.0),
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
      bodyLarge: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0)),
      bodyMedium: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0)),
      bodySmall: TextStyle(color: Color.fromRGBO(39, 39, 37, 1.0)),
      titleMedium: TextStyle(
        color: Color.fromRGBO(39, 39, 37, 1.0),
        fontWeight: FontWeight.w700,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: const Color(0xFF1E1E1B),
      elevation: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor; // Thumb when ON
        }
        return Colors.grey.shade500; // Thumb when OFF (darker for contrast)
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.7); // Track when ON (more visible)
        }
        return Colors.grey.shade400
            .withOpacity(0.3); // Track when OFF (more muted)
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return primaryColor
              .withOpacity(0.3); // Ripple when pressed (slightly stronger)
        }
        return Colors.transparent;
      }),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      textColor: const Color.fromRGBO(39, 39, 37,
          1.0), // title text color for all ListTiles & SwitchListTiles
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(250, 246, 237, 1.0),
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
    dividerTheme: DividerThemeData(
      color: Colors.black12,
      thickness: 1,
      space: 24,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: primaryColor.withOpacity(0.2),
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.12),
      trackHeight: 4,
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
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
