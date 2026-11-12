import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_polls/widgets/poll_expressive.dart';
import 'package:simple_polls/widgets/poll_option_button.dart';

Widget _button({
  required StyleVariant variant,
  bool isSelected = false,
  VoidCallback? onPressed,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PollOptionButton(
        label: 'Option A',
        onPressed: onPressed ?? () {},
        variant: variant,
        showSelectionIndicator: true,
        isSelected: isSelected,
      ),
    ),
  );
}

void main() {
  for (final variant in StyleVariant.values) {
    testWidgets('renders label and calls onPressed when tapped '
        '(${variant.name})', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _button(variant: variant, onPressed: () => pressed = true),
      );

      expect(find.text('Option A'), findsOneWidget);

      await tester.tap(find.byType(PollOptionButton));
      expect(pressed, isTrue);
    });
  }

  testWidgets('material3 shows a check icon only when selected', (
    tester,
  ) async {
    await tester.pumpWidget(_button(variant: StyleVariant.material3));
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.pumpWidget(
      _button(variant: StyleVariant.material3, isSelected: true),
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('expressive indicator morphs from circle to cookie', (
    tester,
  ) async {
    OutlinedBorder indicatorShape() {
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PollSelectionIndicator),
          matching: find.byType(DecoratedBox),
        ),
      );
      return (box.decoration as ShapeDecoration).shape as OutlinedBorder;
    }

    RoundedPolygon? polygon(OutlinedBorder border) =>
        border is MaterialShapeBorder ? border.shape : null;

    await tester.pumpWidget(_button(variant: StyleVariant.material3Expressive));
    expect(polygon(indicatorShape()), PollSelectionIndicator.unselectedShape);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).isSelected,
      isFalse,
    );

    await tester.pumpWidget(
      _button(variant: StyleVariant.material3Expressive, isSelected: true),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(polygon(indicatorShape()), isNull, reason: 'mid-morph');

    await tester.pumpAndSettle();
    expect(polygon(indicatorShape()), PollSelectionIndicator.selectedShape);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).isSelected,
      isTrue,
    );
  });
}
