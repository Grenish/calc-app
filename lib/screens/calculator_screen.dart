import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../theme/retro_theme.dart';
import '../widgets/retro_button.dart';
import '../widgets/calculator_display.dart';
import '../widgets/history_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _output = "";
  String _equation = "";
  String _result = "";
  int _cursorPosition = 0;
  final List<String> _history = [];
  bool _isRadMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == "AC") {
        _output = "";
        _equation = "";
        _result = "";
        _cursorPosition = 0;
      } else if (key == "C") {
        _output = "";
        _cursorPosition = 0;
      } else if (key == "DEL") {
        if (_cursorPosition > 0 && _output.isNotEmpty) {
          _output = _output.substring(0, _cursorPosition - 1) + _output.substring(_cursorPosition);
          _cursorPosition--;
        }
        _updateEquationLive();
      } else if (key == "=") {
        _calculateResult();
      } else if (key == "DEG" || key == "RAD") {
        _isRadMode = !_isRadMode;
      } else {
        String val = key;
        
        if (key == "π") val = "π";
        if (key == "√") val = "sqrt";
        if (key == "×") val = "×";
        if (key == "÷") val = "÷";
        if (key == "xʸ") val = "^";
        if (key == "!") val = "!";
        
        String insertText;
        if (["sin", "cos", "tan", "log", "ln", "sqrt", "abs", "exp"].contains(val)) {
           insertText = "$val(";
        } else if (key == "%") {
           insertText = "%";
        } else {
           insertText = val;
        }
        
        // Insert at cursor position
        _output = _output.substring(0, _cursorPosition) + insertText + _output.substring(_cursorPosition);
        _cursorPosition += insertText.length;
        
        _updateEquationLive();
      }
    });
  }

  void _updateEquationLive() {
    _equation = _output;
    _result = "";
  }

  String _addImplicitMultiplication(String expr) {
    String result = expr;
    result = result.replaceAllMapped(RegExp(r'\)\('), (m) => ')*(');
    result = result.replaceAllMapped(RegExp(r'\)(\d)'), (m) => ')*${m.group(1)}');
    result = result.replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m.group(1)}*(');
    return result;
  }

  // Calculate factorial using Stirling's approximation for large numbers
  String _calculateFactorial(int n) {
    if (n < 0) return "Error";
    if (n <= 1) return "1";
    if (n <= 20) {
      // Direct calculation for small numbers
      BigInt result = BigInt.one;
      for (int i = 2; i <= n; i++) {
        result *= BigInt.from(i);
      }
      return result.toString();
    } else if (n <= 170) {
      // Use double for medium numbers
      double result = 1;
      for (int i = 2; i <= n; i++) {
        result *= i;
      }
      if (result.isInfinite) {
        // Use Stirling's approximation
        return _stirlingApproximation(n);
      }
      return result.toStringAsExponential(10);
    } else {
      // Use Stirling's approximation for very large numbers
      return _stirlingApproximation(n);
    }
  }

  String _stirlingApproximation(int n) {
    // Stirling's formula: n! ≈ sqrt(2πn) * (n/e)^n
    // log10(n!) ≈ 0.5*log10(2πn) + n*log10(n/e)
    double logFactorial = 0.5 * math.log(2 * math.pi * n) / math.ln10 +
        n * (math.log(n) - 1) / math.ln10;
    
    // Extract mantissa and exponent
    int exponent = logFactorial.floor();
    double mantissa = math.pow(10, logFactorial - exponent).toDouble();
    
    return "${mantissa.toStringAsFixed(10)}E$exponent";
  }

  String _processFactorial(String expr) {
    // Replace n! with factorial value
    return expr.replaceAllMapped(RegExp(r'(\d+)!'), (match) {
      int n = int.parse(match.group(1)!);
      return _calculateFactorial(n);
    });
  }

  void _calculateResult() {
    if (_output.isEmpty) return;

    try {
      GrammarParser p = GrammarParser();
      String expression = _output
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.14159265358979');
      
      expression = _addImplicitMultiplication(expression);
      expression = _processFactorial(expression);
      expression = expression.replaceAll('ln(', 'log('); 
      
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      
      // ignore: deprecated_member_use
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      if (eval.isInfinite) {
        _result = "Value too large";
        _equation = "$_output =";
      } else if (eval.isNaN) {
        _result = "Error";
        _equation = "$_output =";
      } else {
         String resultStr;
         if (eval.abs() > 1e15 || (eval != 0 && eval.abs() < 1e-10)) {
           resultStr = eval.toStringAsExponential(10);
         } else {
           resultStr = eval.toString();
           if (resultStr.endsWith(".0")) {
             resultStr = resultStr.substring(0, resultStr.length - 2);
           }
         }
         
         String fullEq = "$_output = $resultStr";
         _history.insert(0, fullEq);
         if (_history.length > 50) _history.removeLast();
         
         _equation = "$_output =";
         _result = resultStr;
         _output = resultStr;
         _cursorPosition = _output.length;
      }

    } catch (e) {
      _result = "Error";
      _equation = "$_output =";
    }
    setState(() {});
  }

  void _clearHistory() {
     setState(() {
       _history.clear();
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black, width: 3))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "RETRO SINE",
                    style: TextStyle(
                      color: RetroTheme.accentMagenta,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isRadMode = !_isRadMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RetroTheme.accentYellow,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(2, 2))
                        ]
                      ),
                      child: Text(
                        _isRadMode ? "RAD" : "DEG",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: CalculatorDisplay(
                output: _output.isEmpty ? "0" : _output,
                equation: _equation,
                result: _result,
                cursorPosition: _output.isEmpty ? 0 : _cursorPosition,
                showCursor: true,
                onCursorPositionChanged: (pos) {
                  setState(() {
                    _cursorPosition = pos;
                  });
                },
              ),
            ),
            
             Expanded(
               flex: 3,
               child: Column(
                 children: [
                   Container(
                     margin: const EdgeInsets.symmetric(horizontal: 20),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.black, width: 2),
                       color: RetroTheme.white,
                     ),
                     child: TabBar(
                       controller: _tabController,
                       labelColor: RetroTheme.textBlack,
                       indicatorColor: RetroTheme.accentCyan,
                       indicatorWeight: 4,
                       labelStyle: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                       tabs: const [
                         Tab(text: "KEYPAD"),
                         Tab(text: "HISTORY"),
                       ],
                     ),
                   ),
                   const SizedBox(height: 10),
                   Expanded(
                     child: TabBarView(
                       controller: _tabController,
                       children: [
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                           child: _buildScientificKeypad(),
                         ),
                         HistoryPanel(history: _history, onClear: _clearHistory),
                       ],
                     ),
                   ),
                   const SizedBox(height: 10),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScientificKeypad() {
    return Column(
      children: [
        _buildRow(["AC", "C", "DEL", "!", "("], [ButtonType.accentRed, ButtonType.standard, ButtonType.standard, ButtonType.accentCyan, ButtonType.standard]),
        const SizedBox(height: 8),
        _buildRow([")", "π", "e", "sin", "cos"]),
        const SizedBox(height: 8),
        _buildRow(["tan", "log", "ln", "√", "abs"]),
        const SizedBox(height: 8),
        _buildRow(["exp", "7", "8", "9", "÷"]),
        const SizedBox(height: 8),
        _buildRow(["%", "4", "5", "6", "×"]),
        const SizedBox(height: 8),
        _buildRow(["xʸ", "1", "2", "3", "-"]),
        const SizedBox(height: 8),
        _buildRow(["0", ".", "+", "="], [ButtonType.standard, ButtonType.standard, ButtonType.accentCyan, ButtonType.accentMagenta], [2, 1, 1, 1]),
      ],
    );
  }

  Widget _buildRow(List<String> labels, [List<ButtonType>? types, List<int>? flexes]) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(labels.length, (index) {
          return RetroButton(
            label: labels[index],
            type: types != null && index < types.length ? types[index] : ButtonType.standard,
            flex: flexes != null && index < flexes.length ? flexes[index] : 1,
            onTap: () => _onKeyPress(labels[index]),
          );
        }),
      ),
    );
  }
}
