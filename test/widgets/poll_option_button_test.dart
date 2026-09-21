import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/widgets/poll_option_button.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollOptionButton(
            label: 'Option A',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Option A'), findsOneWidget);

    await tester.tap(find.byType(PollOptionButton));
    expect(pressed, isTrue);
  });

  testWidgets('shows a check icon only when selected and indicator is on', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollOptionButton(
            label: 'Option A',
            onPressed: () {},
            showSelectionIndicator: true,
            isSelected: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
