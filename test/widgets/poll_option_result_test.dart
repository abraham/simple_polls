import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_polls/simple_polls.dart';
import 'package:simple_polls/widgets/poll_expressive.dart';
import 'package:simple_polls/widgets/poll_option_result.dart';

Widget _result({
  required StyleVariant variant,
  double percentage = 0.5,
  bool isSelected = false,
  bool isLeading = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PollOptionResult(
        label: 'Option A',
        percentage: percentage,
        isSelected: isSelected,
        isLeading: isLeading,
        style: PollStyle(variant: variant),
      ),
    ),
  );
}

Finder _badge(RoundedPolygon shape) => find.byWidgetPredicate(
  (widget) => widget is PollShapeBadge && widget.shape == shape,
);

void main() {
  for (final variant in StyleVariant.values) {
    testWidgets('renders label and computed percentage (${variant.name})', (
      tester,
    ) async {
      await tester.pumpWidget(_result(variant: variant, isSelected: true));
      await tester.pumpAndSettle();

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget);
    });

    testWidgets('labels the selected option for screen readers '
        '(${variant.name})', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_result(variant: variant, isSelected: true));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp('Selected')), findsOneWidget);
      semantics.dispose();
    });
  }

  testWidgets('material3 shows a check icon only when selected', (
    tester,
  ) async {
    await tester.pumpWidget(_result(variant: StyleVariant.material3));
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.pumpWidget(
      _result(variant: StyleVariant.material3, isSelected: true),
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('expressive shows shape badges for selected and leading', (
    tester,
  ) async {
    await tester.pumpWidget(_result(variant: StyleVariant.material3Expressive));
    expect(_badge(PollOptionResult.selectedBadgeShape), findsNothing);
    expect(_badge(PollOptionResult.leadingBadgeShape), findsNothing);

    await tester.pumpWidget(
      _result(
        variant: StyleVariant.material3Expressive,
        isSelected: true,
        isLeading: true,
      ),
    );
    expect(_badge(PollOptionResult.selectedBadgeShape), findsOneWidget);
    expect(_badge(PollOptionResult.leadingBadgeShape), findsOneWidget);
  });
}
