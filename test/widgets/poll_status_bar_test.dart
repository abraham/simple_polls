import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_polls/simple_polls.dart';
import 'package:simple_polls/widgets/poll_status_bar.dart';

Widget _bar({
  int votes = 1,
  DateTime? endsAt,
  bool showUndo = false,
  VoidCallback? onUndo,
  StyleVariant variant = StyleVariant.material3Expressive,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PollStatusBar(
        poll: Poll<int>(
          title: 'Question?',
          endsAt: endsAt,
          options: [PollOption(id: 1, label: 'A', voteCount: votes)],
        ),
        locale: PollLocale.en,
        showUndo: showUndo,
        onUndo: onUndo ?? () {},
        style: PollStyle(variant: variant),
      ),
    ),
  );
}

void main() {
  final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));

  testWidgets('shows undo button only when showUndo is true', (tester) async {
    await tester.pumpWidget(_bar(votes: 3, endsAt: tomorrow, showUndo: true));

    expect(find.text('3 votes'), findsOneWidget);
    expect(find.text('undo'), findsOneWidget);

    await tester.pumpWidget(_bar(votes: 3, endsAt: tomorrow));
    expect(find.text('undo'), findsNothing);
  });

  testWidgets('calls onUndo when undo is tapped', (tester) async {
    var undone = false;

    await tester.pumpWidget(
      _bar(endsAt: tomorrow, showUndo: true, onUndo: () => undone = true),
    );

    await tester.tap(find.text('undo'));
    expect(undone, isTrue);
  });

  for (final variant in StyleVariant.values) {
    testWidgets('undo is a button for screen readers (${variant.name})', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_bar(showUndo: true, variant: variant));

      expect(
        tester.getSemantics(find.text('undo')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      semantics.dispose();
    });
  }

  testWidgets('hides the ends/ended text when endsAt is omitted', (
    tester,
  ) async {
    await tester.pumpWidget(_bar(votes: 2));

    expect(find.text('2 votes'), findsOneWidget);
    expect(find.textContaining('Ends'), findsNothing);
    expect(find.text('Polling Ended'), findsNothing);
  });

  testWidgets('shows the ended label once the poll has ended', (tester) async {
    await tester.pumpWidget(
      _bar(endsAt: DateTime.now().toUtc().subtract(const Duration(days: 1))),
    );

    expect(find.text('Polling Ended'), findsOneWidget);
  });
}
