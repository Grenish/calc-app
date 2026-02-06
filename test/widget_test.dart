
import 'package:flutter_test/flutter_test.dart';

import 'package:calc2/main.dart';
import 'package:calc2/widgets/retro_button.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RetroCalcApp());

    // Verify that the title corresponds to our app
    // Note: 'RETRO SINE' is in the screen
    expect(find.text('RETRO SINE'), findsOneWidget);
    
    // Default output might be empty or 0 depending on implementation.
    // In new implementation _output starts "" which renders as "0".
    
    // Verify we have buttons
    expect(find.byType(RetroButton), findsWidgets);
  });
}
