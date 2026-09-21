import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/poll_buttons.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var pressed = false;
    final option = PollOptions(label: 'Option A', pollsCount: 0, id: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollButtonsWidget(
            optionModel: option,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Option A'), findsOneWidget);

    await tester.tap(find.byType(PollButtonsWidget));
    expect(pressed, isTrue);
  });
}
