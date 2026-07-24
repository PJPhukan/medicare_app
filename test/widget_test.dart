import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_medicare/core/local_db/local_cache.dart';
import 'package:app_medicare/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Mirror main(): the app requires sharedPreferencesProvider to be
    // overridden with a real instance before the first frame.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MediForzeApp(),
      ),
    );
    // pump instead of pumpAndSettle: the splash screen runs looping
    // animations that never settle. Advance far enough for the splash's
    // navigation timer to fire so no timers are pending at teardown.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
