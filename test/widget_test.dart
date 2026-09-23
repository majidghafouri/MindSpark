import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nevermindspark/app.dart';
import 'package:nevermindspark/data/repositories/progress_repository.dart';
import 'package:nevermindspark/presentation/state/app_state.dart';

void main() {
  testWidgets('onboarding to full-run to results works end to end',
      (WidgetTester tester) async {
    final appState = AppState(
      repository: MemoryProgressStoreRepository(
        now: () => DateTime(2026, 9, 23, 10),
      ),
    );

    await tester.pumpWidget(App(appState: appState));
    await tester.pump();

    // Loading state resolves to onboarding on first launch.
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Home screen.
    expect(find.text('NeverMindSpark'), findsOneWidget);
    expect(find.text("Start today's set"), findsOneWidget);

    await tester.tap(find.text("Start today's set"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Play all five questions by always tapping the first option.
    for (var q = 0; q < 5; q++) {
      expect(find.byKey(const ValueKey('option-0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('option-0')));
      await tester.pump();

      final nextLabel = q < 4 ? 'Next question' : 'See results';
      final nextButton = find.text(nextLabel);
      expect(nextButton, findsOneWidget);
      await tester.ensureVisible(nextButton);
      await tester.pump();
      await tester.tap(nextButton);
      await tester.pump();
    }

    // Finish records the run and redirects to results.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(find.text('By category'), findsOneWidget);

    // Back to home; today shows as completed.
    await tester.tap(find.text('Back to home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Play again'), findsOneWidget);
    expect(find.textContaining('Score:'), findsOneWidget);

    // Cleanup so the app state notifier doesn't leak across tests.
    appState.dispose();
  });
}