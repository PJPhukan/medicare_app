import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_medicare/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MediForzeApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
