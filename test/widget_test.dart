import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stateful_lab_tengson/main.dart';

void main() {
  testWidgets('shows sample items and their total', (tester) async {
    await tester.pumpWidget(const CartApp());

    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('\$13.80'), findsOneWidget);
  });

  testWidgets('adds an item and clears checked items', (tester) async {
    await tester.pumpWidget(const CartApp());

    await tester.enterText(find.widgetWithText(TextField, 'Item name'), 'Tea');
    await tester.enterText(find.widgetWithText(TextField, 'Price'), '4.50');
    await tester.tap(find.byTooltip('Add item'));
    await tester.pumpAndSettle();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('\$18.30'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear checked items'));
    await tester.pumpAndSettle();

    expect(find.text('Bread'), findsNothing);
    expect(find.text('\$15.80'), findsOneWidget);
  });
}
