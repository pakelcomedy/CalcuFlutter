import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcuflutter/main.dart'; // Ensure this path matches your project structure

void main() {
  testWidgets('Calculator app renders and responds to button taps',
      (WidgetTester tester) async {
    // Pump the CalculatorApp widget.
    await tester.pumpWidget(const CalculatorApp());

    // Verify that the AppBar title "Smart Calculator" is present.
    expect(find.text('Smart Calculator'), findsOneWidget);

    // Locate the "1" button by looking for an ElevatedButton with text "1".
    final oneButtonFinder = find.widgetWithText(ElevatedButton, '1');
    expect(oneButtonFinder, findsOneWidget);

    // Tap the "1" button.
    await tester.tap(oneButtonFinder);
    await tester.pump();

    // Tap the "=" button.
    final equalButtonFinder = find.widgetWithText(ElevatedButton, '=');
    expect(equalButtonFinder, findsOneWidget);
    await tester.tap(equalButtonFinder);
    await tester.pump();

    // Verify that the result display shows "1".
    final resultFinder = find.byKey(const Key('result'));
    expect(resultFinder, findsOneWidget);
    expect(find.descendant(of: resultFinder, matching: find.text('1')),
        findsOneWidget);
  });
}
