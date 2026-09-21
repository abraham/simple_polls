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

  testWidgets('does not crash and stays votable when endTime is omitted', (
    tester,
  ) async {
    final model = PollFrameModel(
      totalPolls: 0,
      options: [PollOptions(label: 'Option A', pollsCount: 0, id: 1)],
      title: const Text('Question?'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SimplePollsWidget(model: model)),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(model.hasVoted, isTrue);
  });

  testWidgets('multi-select poll toggles options and submits on Vote', (
    tester,
  ) async {
    List<PollOptions>? submitted;
    final model = PollFrameModel(
      totalPolls: 0,
      options: [
        PollOptions(label: 'Option A', pollsCount: 0, id: 1),
        PollOptions(label: 'Option B', pollsCount: 0, id: 2),
      ],
      title: const Text('Question?'),
      endTime: DateTime.now().toUtc().add(const Duration(days: 1)),
      allowMultipleSelection: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimplePollsWidget(
            model: model,
            onMultiSelection: (_, selectedOptions) =>
                submitted = selectedOptions,
          ),
        ),
      ),
    );

    // Vote button is disabled until an option is toggled.
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
      isFalse,
    );

    await tester.tap(find.text('Option A'));
    await tester.tap(find.text('Option B'));
    await tester.pump();

    expect(model.hasVoted, isFalse);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
      isTrue,
    );

    await tester.tap(find.text('Vote'));
    await tester.pumpAndSettle();

    expect(model.hasVoted, isTrue);
    expect(model.totalPolls, 1);
    expect(
      submitted?.map((o) => o.label),
      containsAll(['Option A', 'Option B']),
    );
  });
}
