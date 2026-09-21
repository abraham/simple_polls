import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/locale/poll_locale.dart';
import 'package:simple_polls/widgets/poll_status_bar.dart';

void main() {
  testWidgets('shows undo button only when showUndo is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusBar(
            totalVotes: 3,
            locale: PollLocale.en,
            endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
            showUndo: true,
            onUndo: () {},
          ),
        ),
      ),
    );

    expect(find.text('3 votes'), findsOneWidget);
    expect(find.text('undo'), findsOneWidget);
  });

  testWidgets('calls onUndo when undo is tapped', (tester) async {
    var undone = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusBar(
            totalVotes: 1,
            locale: PollLocale.en,
            endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
            showUndo: true,
            onUndo: () => undone = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('undo'));
    expect(undone, isTrue);
  });

  testWidgets('hides the ends/ended text when endsAt is omitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PollStatusBar(totalVotes: 2, locale: PollLocale.en),
        ),
      ),
    );

    expect(find.text('2 votes'), findsOneWidget);
    expect(find.textContaining('Ends'), findsNothing);
    expect(find.text('Polling Ended'), findsNothing);
  });

  testWidgets('shows the ended label once hasEnded is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PollStatusBar(
            totalVotes: 2,
            locale: PollLocale.en,
            endsAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
            hasEnded: true,
          ),
        ),
      ),
    );

    expect(find.text('Polling Ended'), findsOneWidget);
  });
}
