import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/simple_polls.dart';

void main() {
  testWidgets('shows option buttons before voting, results after', (
    tester,
  ) async {
    final model = PollFrameModel(
      totalPolls: 0,
      options: [
        PollOptions(label: 'Option A', pollsCount: 0, id: 1),
        PollOptions(label: 'Option B', pollsCount: 0, id: 2),
      ],
      title: const Text('Question?'),
      endTime: DateTime.now().toUtc().add(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SimplePollsWidget(model: model)),
      ),
    );

    expect(find.byType(OutlinedButton), findsNWidgets(2));

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsNothing);
    expect(model.hasVoted, isTrue);
    expect(model.totalPolls, 1);
  });
}
