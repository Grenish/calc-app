import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

enum ButtonType { standard, accentRed, accentCyan, accentMagenta, accentYellow }

class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final ButtonType type;
  final int flex;

  const RetroButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = ButtonType.standard,
    this.flex = 1,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  Color get _buttonColor {
    switch (widget.type) {
      case ButtonType.standard:
        return RetroTheme.white;
      case ButtonType.accentRed:
        return RetroTheme.accentRed;
      case ButtonType.accentCyan:
        return RetroTheme.accentCyan;
      case ButtonType.accentMagenta:
        return RetroTheme.accentMagenta;
       case ButtonType.accentYellow: // Added for completeness if needed
        return RetroTheme.accentYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          margin: const EdgeInsets.all(4), // Spacing for grid
          decoration: RetroTheme.boxDecoration(
            color: _buttonColor,
            isPressed: _isPressed,
          ),
          transform: _isPressed
              ? Matrix4.translationValues(2, 2, 0)
              : Matrix4.identity(),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RetroTheme.textBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
