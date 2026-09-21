import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/widgets/poll_option_result.dart';

void main() {
  testWidgets('renders label and computed percentage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PollOptionResult(
            label: 'Option A',
            percentage: 0.5,
            isSelected: true,
          ),
        ),
      ),
    );

    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('hides check icon when option is not selected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PollOptionResult(label: 'Option A', percentage: 0),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });
}
