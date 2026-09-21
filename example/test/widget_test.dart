// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('shows the poll options before voting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('opzione 1'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(3));

    await tester.tap(find.text('opzione 1'));
    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsNothing);
  });
}
