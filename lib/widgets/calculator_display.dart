import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class CalculatorDisplay extends StatefulWidget {
  final String output;
  final String equation;
  final String result;
  final int cursorPosition;
  final bool showCursor;
  final Function(int)? onCursorPositionChanged;
  final String? operator;

  const CalculatorDisplay({
    super.key,
    required this.output,
    this.equation = "",
    this.result = "",
    this.cursorPosition = -1,
    this.showCursor = false,
    this.onCursorPositionChanged,
    this.operator,
  });

  @override
  State<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends State<CalculatorDisplay> {
  final ScrollController _outputScrollController = ScrollController();
  final ScrollController _equationScrollController = ScrollController();

  @override
  void dispose() {
    _outputScrollController.dispose();
    _equationScrollController.dispose();
    super.dispose();
  }

  // Build RichText with superscript for power (^)
  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    if (text.isEmpty) return const SizedBox.shrink();
    if (!text.contains('^')) {
      return Text(text, style: baseStyle);
    }

    List<InlineSpan> spans = [];
    int i = 0;
    while (i < text.length) {
      if (text[i] == '^' && i + 1 < text.length) {
        String superscriptChar = '';
        int j = i + 1;
        while (j < text.length && RegExp(r'[0-9.]').hasMatch(text[j])) {
          superscriptChar += text[j];
          j++;
        }
        if (superscriptChar.isNotEmpty) {
          final superOffset = baseStyle.fontSize! * 0.5;
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Transform.translate(
              offset: Offset(0, -superOffset),
              child: Text(
                superscriptChar,
                style: baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.5),
              ),
            ),
          ));
          i = j;
        } else {
          spans.add(TextSpan(text: text[i], style: baseStyle));
          i++;
        }
      } else {
        spans.add(TextSpan(text: text[i], style: baseStyle));
        i++;
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  // Build tappable text with cursor - uses Stack with positioned tap zones
  Widget _buildTappableTextWithCursor(String text, TextStyle baseStyle, int cursorPos, bool showCursor, Function(int)? onTap) {
    if (text.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCursor) _BlinkingCursor(color: Colors.black, height: baseStyle.fontSize ?? 24),
          Text("0", style: baseStyle.copyWith(color: Colors.grey)),
        ],
      );
    }

    // Build the display text with superscript
    List<Widget> textWidgets = [];
    List<int> charPositions = [0]; // Track character positions
    int charCount = 0;
    int i = 0;
    
    // Add cursor at position 0 if needed
    if (showCursor && cursorPos == 0) {
      textWidgets.add(_BlinkingCursor(color: Colors.black, height: baseStyle.fontSize ?? 24));
    }
    
    while (i < text.length) {
      if (text[i] == '^' && i + 1 < text.length) {
        // Handle superscript
        String superscriptChars = '';
        int j = i + 1;
        while (j < text.length && RegExp(r'[0-9.]').hasMatch(text[j])) {
          superscriptChars += text[j];
          j++;
        }
        
        if (superscriptChars.isNotEmpty) {
          final superOffset = baseStyle.fontSize! * 0.5;
          int charsInGroup = 1 + superscriptChars.length; // ^ + digits
          
          textWidgets.add(Transform.translate(
            offset: Offset(0, -superOffset),
            child: Text(
              superscriptChars,
              style: baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.5),
            ),
          ));
          
          charCount += charsInGroup;
          charPositions.add(charCount);
          
          // Add cursor after superscript if needed
          if (showCursor && cursorPos == charCount) {
            textWidgets.add(_BlinkingCursor(color: Colors.black, height: baseStyle.fontSize ?? 24));
          }
          
          i = j;
          continue;
        }
      }
      
      // Regular character
      textWidgets.add(Text(text[i], style: baseStyle));
      charCount++;
      charPositions.add(charCount);
      
      // Add cursor after this character if needed
      if (showCursor && cursorPos == charCount) {
        textWidgets.add(_BlinkingCursor(color: Colors.black, height: baseStyle.fontSize ?? 24));
      }
      
      i++;
    }

    // Wrap in GestureDetector for tap positioning
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        // Calculate which character was tapped based on position
        // For now, use a simple approach: tap anywhere moves to end
        // Users can rely on the blinking cursor for now
        final tapX = details.localPosition.dx;
        final textWidth = text.length * (baseStyle.fontSize ?? 24) * 0.6; // Approximate
        final ratio = tapX / textWidth;
        final pos = (ratio * text.length).round().clamp(0, text.length);
        onTap?.call(pos);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: textWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outputStyle = Theme.of(context).textTheme.displayLarge ?? 
        const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'Courier');
    
    const equationStyle = TextStyle(
      fontSize: 18,
      color: Colors.grey,
      fontFamily: 'Courier',
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: RetroTheme.boxDecoration(color: RetroTheme.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Top: Equation (scrollable)
          SizedBox(
            height: 24,
            child: SingleChildScrollView(
              controller: _equationScrollController,
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const ClampingScrollPhysics(),
              child: _buildFormattedText(widget.equation, equationStyle),
            ),
          ),
          
          // Middle: Result (if available)
          if (widget.result.isNotEmpty)
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.result,
                style: equationStyle.copyWith(
                  color: RetroTheme.accentMagenta,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const Spacer(),
          
          // Bottom: Main output with cursor (scrollable, tappable)
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              controller: _outputScrollController,
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const ClampingScrollPhysics(),
              child: _buildTappableTextWithCursor(
                widget.output == "0" ? "" : widget.output, 
                outputStyle, 
                widget.cursorPosition, 
                widget.showCursor,
                widget.onCursorPositionChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Blinking cursor widget
class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;

  const _BlinkingCursor({required this.color, required this.height});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: widget.height,
            color: widget.color,
          ),
        );
      },
    );
  }
}
