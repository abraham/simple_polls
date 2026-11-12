import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_polls/widgets/poll_progress_bar.dart';

void main() {
  Widget bar({required double value, bool disableAnimations = false}) {
    return MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: Center(
            child: SizedBox(width: 200, child: PollProgressBar(value: value)),
          ),
        ),
      ),
    );
  }

  double activeWidth(WidgetTester tester) =>
      tester.getSize(find.byKey(PollProgressBar.activeKey)).width;

  testWidgets('expressive bar springs from empty to its value', (tester) async {
    await tester.pumpWidget(bar(value: 0.5));
    expect(activeWidth(tester), 0);

    await tester.pump(const Duration(milliseconds: 50));
    expect(activeWidth(tester), inExclusiveRange(0, 100));

    await tester.pumpAndSettle();
    expect(activeWidth(tester), moreOrLessEquals(100));
  });

  testWidgets('expressive bar skips the animation when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(bar(value: 0.5, disableAnimations: true));
    expect(activeWidth(tester), moreOrLessEquals(100));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
