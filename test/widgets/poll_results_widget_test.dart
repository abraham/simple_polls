import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/poll_results.dart';

void main() {
  testWidgets('renders label and computed percentage', (tester) async {
    final option = PollOptions(
      label: 'Option A',
      pollsCount: 5,
      id: 1,
      isSelected: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollResultsWidget(percentage: 0.5, optionModel: option),
        ),
      ),
    );

    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('hides check icon when option is not selected', (tester) async {
    final option = PollOptions(label: 'Option A', pollsCount: 0, id: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollResultsWidget(percentage: 0, optionModel: option),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });
}
