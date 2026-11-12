import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_polls/simple_polls.dart';
import 'package:simple_polls/widgets/poll_expressive.dart';
import 'package:simple_polls/widgets/poll_option_button.dart';
import 'package:simple_polls/widgets/poll_option_result.dart';

/// A tiny host-app stand-in that owns [Poll]/[PollVote] state the way a real
/// app would, since [SimplePoll] is a fully controlled widget.
class _PollHarness extends StatefulWidget {
  const _PollHarness({
    super.key,
    required this.initialPoll,
    this.initialVote,
    this.style = const PollStyle(),
    this.onSubmit,
  });

  final Poll<int> initialPoll;
  final PollVote<int>? initialVote;
  final PollStyle style;

  /// Awaited before the vote is applied, like a network call.
  final Future<void> Function()? onSubmit;

  @override
  State<_PollHarness> createState() => _PollHarnessState();
}

class _PollHarnessState extends State<_PollHarness> {
  late Poll<int> poll = widget.initialPoll;
  late PollVote<int>? vote = widget.initialVote;
  List<int>? lastSubmittedIds;

  @override
  Widget build(BuildContext context) {
    return SimplePoll<int>(
      poll: poll,
      vote: vote,
      style: widget.style,
      onVoteChanged: (newVote) async {
        await widget.onSubmit?.call();
        setState(() {
          poll = poll.withVoteApplied(previousVote: vote, newVote: newVote);
          vote = newVote;
          lastSubmittedIds = newVote?.selectedOptionIds.toList();
        });
      },
    );
  }
}

Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: app!,
    ),
    home: Scaffold(body: child),
  );
}

final _optionButtons = find.byType(PollOptionButton);
final _voteButton = find.widgetWithText(ElevatedButton, 'Vote');

Finder _badges(RoundedPolygon shape) => find.byWidgetPredicate(
  (widget) => widget is PollShapeBadge && widget.shape == shape,
);

void main() {
  for (final variant in StyleVariant.values) {
    group(variant.name, () {
      final style = PollStyle(variant: variant);

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
          _app(_PollHarness(key: key, initialPoll: poll, style: style)),
        );

        expect(_optionButtons, findsNWidgets(2));

        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        expect(_optionButtons, findsNothing);
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
          _app(_PollHarness(key: key, initialPoll: poll, style: style)),
        );

        expect(_optionButtons, findsOneWidget);

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
          _app(_PollHarness(key: key, initialPoll: poll, style: style)),
        );

        // Vote button is disabled until an option is toggled.
        expect(tester.widget<ElevatedButton>(_voteButton).enabled, isFalse);

        await tester.tap(find.text('Option A'));
        await tester.tap(find.text('Option B'));
        await tester.pump();

        expect(key.currentState!.vote, isNull);
        expect(tester.widget<ElevatedButton>(_voteButton).enabled, isTrue);

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
            _app(_PollHarness(key: key, initialPoll: poll, style: style)),
          );

          await tester.tap(find.text('Option A'));
          await tester.tap(find.text('Option B'));
          await tester.pump();
          await tester.tap(find.text('Vote'));
          await tester.pumpAndSettle();

          expect(_optionButtons, findsNothing);

          await tester.tap(find.text('undo'));
          await tester.pumpAndSettle();

          expect(key.currentState!.vote, isNull);
          expect(key.currentState!.poll.totalVotes, 0);

          // Both options should still be pre-selected instead of resetting empty.
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is PollOptionButton && widget.isSelected == true,
            ),
            findsNWidgets(2),
          );
          expect(tester.widget<ElevatedButton>(_voteButton).enabled, isTrue);

          await tester.tap(find.text('Vote'));
          await tester.pumpAndSettle();

          expect(key.currentState!.vote, const PollVote({1, 2}));
        },
      );

      testWidgets('fits a narrow screen at 200% text size', (tester) async {
        final poll = Poll<int>(
          title: 'Which of these long option labels do you like best?',
          endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
          isEditable: true,
          options: const [
            PollOption(
              id: 1,
              label: 'A fairly long first option',
              voteCount: 3,
            ),
            PollOption(id: 2, label: 'Second', voteCount: 3),
          ],
        );

        for (final vote in [
          null,
          const PollVote<int>({1}),
        ]) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, app) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: app!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      child: _PollHarness(
                        key: UniqueKey(),
                        initialPoll: poll,
                        initialVote: vote,
                        style: style,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    });
  }

  group('material3Expressive', () {
    testWidgets('result rows are as tall as the option buttons', (
      tester,
    ) async {
      final poll = Poll<int>(
        title: 'Question?',
        endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
        options: const [
          PollOption(id: 1, label: 'Option A', voteCount: 1),
          PollOption(id: 2, label: 'Option B'),
        ],
      );

      await tester.pumpWidget(_app(_PollHarness(initialPoll: poll)));
      final buttonHeight = tester.getSize(_optionButtons.first).height;

      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      for (final row in tester.widgetList(find.byType(PollOptionResult))) {
        expect(
          tester.getSize(find.byWidget(row)).height,
          moreOrLessEquals(buttonHeight, epsilon: 0.5),
        );
      }
    });
    testWidgets('badges the user\'s pick and every leading option', (
      tester,
    ) async {
      final poll = Poll<int>(
        title: 'Question?',
        endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
        options: const [
          PollOption(id: 1, label: 'Option A', voteCount: 4),
          PollOption(id: 2, label: 'Option B', voteCount: 2),
          PollOption(id: 3, label: 'Option C', voteCount: 4),
        ],
      );

      await tester.pumpWidget(
        _app(_PollHarness(initialPoll: poll, initialVote: const PollVote({2}))),
      );
      await tester.pumpAndSettle();

      expect(_badges(PollOptionResult.leadingBadgeShape), findsNWidgets(2));
      expect(_badges(PollOptionResult.selectedBadgeShape), findsOneWidget);
    });

    testWidgets('shows no leading badge when nobody has voted', (tester) async {
      final poll = Poll<int>(
        title: 'Question?',
        endsAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        options: const [
          PollOption(id: 1, label: 'Option A'),
          PollOption(id: 2, label: 'Option B'),
        ],
      );

      await tester.pumpWidget(_app(_PollHarness(initialPoll: poll)));
      await tester.pumpAndSettle();

      expect(find.byType(PollOptionResult), findsNWidgets(2));
      expect(_badges(PollOptionResult.leadingBadgeShape), findsNothing);
    });

    for (final disableAnimations in [false, true]) {
      testWidgets('shows a shape loader while the vote submits '
          '(disableAnimations: $disableAnimations)', (tester) async {
        final submit = Completer<void>();
        final poll = Poll<int>(
          title: 'Question?',
          endsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
          options: const [
            PollOption(id: 1, label: 'Option A'),
            PollOption(id: 2, label: 'Option B'),
          ],
        );

        await tester.pumpWidget(
          _app(
            _PollHarness(initialPoll: poll, onSubmit: () => submit.future),
            disableAnimations: disableAnimations,
          ),
        );

        await tester.tap(find.text('Option A'));
        await tester.pump();

        expect(find.byType(PollShapeLoader), findsOneWidget);

        // The loader holds its first shape only when animations are off.
        await tester.pump(const Duration(seconds: 1));
        final loaderBox = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(PollShapeLoader),
            matching: find.byType(DecoratedBox),
          ),
        );
        final shape = (loaderBox.decoration as ShapeDecoration).shape;
        expect(
          shape is MaterialShapeBorder &&
              shape.shape == PollShapeLoader.shapes.first,
          disableAnimations,
        );
        submit.complete();
        await tester.pumpAndSettle();

        expect(find.byType(PollShapeLoader), findsNothing);
        expect(find.byType(PollOptionResult), findsNWidgets(2));
      });
    }
  });
}
