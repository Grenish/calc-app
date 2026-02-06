import 'package:flutter/material.dart';

class RetroTheme {
  // New "Retro Sine" Color Palette
  static const Color creamBackground = Color(0xFFFFFDF0); // Cream / Off-white
  static const Color accentRed = Color(0xFFFF4D4D);
  static const Color accentCyan = Color(0xFF00FFFF);
  static const Color accentMagenta = Color(0xFFFF00FF);
  static const Color accentYellow = Color(0xFFFFFF00);
  
  static const Color textBlack = Colors.black;
  static const Color white = Colors.white;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentMagenta,
        primary: accentMagenta,
        surface: creamBackground,
        onSurface: textBlack,
        brightness: Brightness.light, // Light mode for this theme
      ),
      fontFamily: 'Courier',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: accentMagenta,
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
           fontWeight: FontWeight.w600,
           color: textBlack,
        ),
      ),
    );
  }

  // Common styles
  static const double borderWidth = 3.0;
  static const Color borderColor = Colors.black;

  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> smallShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
  ];

  static Decoration boxDecoration({Color color = white, bool isPressed = false}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: isPressed ? [] : hardShadow,
    );
  }
}
