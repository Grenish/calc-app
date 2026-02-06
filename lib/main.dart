import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';
import 'theme/retro_theme.dart';

void main() {
  runApp(const RetroCalcApp());
}

class RetroCalcApp extends StatelessWidget {
  const RetroCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Pop Calc',
      debugShowCheckedModeBanner: false,
      theme: RetroTheme.theme,
      home: const CalculatorScreen(),
    );
  }
}
