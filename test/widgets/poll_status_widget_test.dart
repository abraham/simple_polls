import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/poll_status.dart';

void main() {
  testWidgets('shows undo button only when poll is voted and editable', (
    tester,
  ) async {
    final model = PollFrameModel(
      totalPolls: 3,
      options: [PollOptions(label: 'A', pollsCount: 3, id: 1)],
      title: const Text('Q'),
      endTime: DateTime.now().toUtc().add(const Duration(days: 1)),
      hasVoted: true,
      editablePoll: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusWidget(
            model: model,
            languageCode: 'en',
            onUndo: () {},
          ),
        ),
      ),
    );

    expect(find.text('3 polls'), findsOneWidget);
    expect(find.text('undo'), findsOneWidget);
  });

  testWidgets('calls onUndo when undo is tapped', (tester) async {
    var undone = false;
    final model = PollFrameModel(
      totalPolls: 1,
      options: [PollOptions(label: 'A', pollsCount: 1, id: 1)],
      title: const Text('Q'),
      endTime: DateTime.now().toUtc().add(const Duration(days: 1)),
      hasVoted: true,
      editablePoll: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusWidget(
            model: model,
            languageCode: 'en',
            onUndo: () => undone = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('undo'));
    expect(undone, isTrue);
  });

  testWidgets('hides the ends/ended text when endTime is omitted', (
    tester,
  ) async {
    final model = PollFrameModel(
      totalPolls: 2,
      options: [PollOptions(label: 'A', pollsCount: 2, id: 1)],
      title: const Text('Q'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusWidget(
            model: model,
            languageCode: 'en',
            onUndo: () {},
          ),
        ),
      ),
    );

    expect(find.text('2 polls'), findsOneWidget);
    expect(find.textContaining('Ends'), findsNothing);
    expect(find.text('Polling Ended'), findsNothing);
  });
}
