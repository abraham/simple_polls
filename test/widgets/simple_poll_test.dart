import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/simple_polls.dart';

/// A tiny host-app stand-in that owns [Poll]/[PollVote] state the way a real
/// app would, since [SimplePoll] is a fully controlled widget.
class _PollHarness extends StatefulWidget {
  const _PollHarness({super.key, required this.initialPoll});

  final Poll<int> initialPoll;

  @override
  State<_PollHarness> createState() => _PollHarnessState();
}

class _PollHarnessState extends State<_PollHarness> {
  late Poll<int> poll = widget.initialPoll;
  PollVote<int>? vote;
  List<int>? lastSubmittedIds;

  @override
  Widget build(BuildContext context) {
    return SimplePoll<int>(
      poll: poll,
      vote: vote,
      onVoteChanged: (newVote) {
        setState(() {
          poll = poll.withVoteApplied(previousVote: vote, newVote: newVote);
          vote = newVote;
          lastSubmittedIds = newVote?.selectedOptionIds.toList();
        });
      },
    );
  }
}

void main() {
  testWidgets('shows option buttons before voting, results after', (
    tester,
  ) async {
    final key = GlobalKey<_PollHarnessState>();
    final poll = Poll<int>(
      title: 'Question?',
      endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
      options: const [
        PollOption(id: 1, label: 'Option A'),
        PollOption(id: 2, label: 'Option B'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _PollHarness(key: key, initialPoll: poll),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsNWidgets(2));

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsNothing);
    expect(key.currentState!.vote, const PollVote({1}));
    expect(key.currentState!.poll.totalVotes, 1);
  });

  testWidgets('does not crash and stays votable when endsAt is omitted', (
    tester,
  ) async {
    final key = GlobalKey<_PollHarnessState>();
    const poll = Poll<int>(
      title: 'Question?',
      options: [PollOption(id: 1, label: 'Option A')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _PollHarness(key: key, initialPoll: poll),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(key.currentState!.vote, isNotNull);
  });

  testWidgets('multi-select poll toggles options and submits on Vote', (
    tester,
  ) async {
    final key = GlobalKey<_PollHarnessState>();
    final poll = Poll<int>(
      title: 'Question?',
      endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
      allowsMultipleAnswers: true,
      options: const [
        PollOption(id: 1, label: 'Option A'),
        PollOption(id: 2, label: 'Option B'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _PollHarness(key: key, initialPoll: poll),
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

    expect(key.currentState!.vote, isNull);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
      isTrue,
    );

    await tester.tap(find.text('Vote'));
    await tester.pumpAndSettle();

    expect(key.currentState!.vote, const PollVote({1, 2}));
    expect(key.currentState!.poll.totalVotes, 2);
    expect(key.currentState!.lastSubmittedIds, containsAll([1, 2]));
  });

  testWidgets(
    'undoing a multi-select vote keeps the previous choices toggled',
    (tester) async {
      final key = GlobalKey<_PollHarnessState>();
      final poll = Poll<int>(
        title: 'Question?',
        endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
        allowsMultipleAnswers: true,
        isEditable: true,
        options: const [
          PollOption(id: 1, label: 'Option A'),
          PollOption(id: 2, label: 'Option B'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _PollHarness(key: key, initialPoll: poll),
          ),
        ),
      );

      await tester.tap(find.text('Option A'));
      await tester.tap(find.text('Option B'));
      await tester.pump();
      await tester.tap(find.text('Vote'));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsNothing);

      await tester.tap(find.text('undo'));
      await tester.pumpAndSettle();

      expect(key.currentState!.vote, isNull);
      expect(key.currentState!.poll.totalVotes, 0);

      // Both options should still be pre-selected instead of resetting empty.
      expect(find.byType(OutlinedButton), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );

      await tester.tap(find.text('Vote'));
      await tester.pumpAndSettle();

      expect(key.currentState!.vote, const PollVote({1, 2}));
    },
  );
}
