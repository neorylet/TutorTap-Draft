import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutortap_1/widgets/pill_button.dart';

void main() {
  testWidgets('PillButton renders its label and responds to taps', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PillButton(
              label: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
