import 'package:flutter_test/flutter_test.dart';
import 'package:nevermindspark/data/models/app_settings.dart';
import 'package:nevermindspark/data/repositories/progress_repository.dart';
import 'package:nevermindspark/domain/services/daily_challenge_service.dart';

void main() {
  test('records days, unlocks badges across simulated consecutive days', () async {
    var day = DateTime(2026, 9, 20);
    final store = MemoryProgressStore();
    final repo = ProgressRepository(store, now: () => day);
    final service = DailyChallengeService(now: () => day);

    // Seven consecutive days, all perfect.
    for (var i = 0; i < 7; i++) {
      final set = service.getTodaysSet();
      await repo.recordCompletedDay(
        set: set,
        selections: set.challenges.map<int?>((c) => c.answerIndex).toList(),
        completedAt: day,
      );
      day = day.add(const Duration(days: 1));
    }

    var snapshot = await repo.loadProgress();
    expect(snapshot.streak.current, 7);
    expect(snapshot.streak.longest, 7);
    expect(snapshot.stats.daysPlayed, 7);
    expect(snapshot.stats.averageScore, 100);
    expect(snapshot.stats.bestScore, 100);
    expect(snapshot.unlockedBadgeIds,
        containsAll({'beginner', 'trainee'}));
    expect(snapshot.unlockedBadgeIds, isNot(contains('master')));
  });

  test('missed days break the current streak but keep longest and stats', () async {
    var day = DateTime(2026, 9, 20);
    final store = MemoryProgressStore();
    final repo = ProgressRepository(store, now: () => day);
    final service = DailyChallengeService(now: () => day);

    for (var i = 0; i < 7; i++) {
      final set = service.getTodaysSet();
      await repo.recordCompletedDay(
        set: set,
        selections: set.challenges.map<int?>((c) => c.answerIndex).toList(),
        completedAt: day,
      );
      day = day.add(const Duration(days: 1));
    }

    // Skip three days (a break), then play again answering everything wrong.
    day = day.add(const Duration(days: 2));
    final set = service.getTodaysSet();
    await repo.recordCompletedDay(
      set: set,
      selections: [
        for (final c in set.challenges) (c.answerIndex + 1) % c.options.length,
      ],
      completedAt: day,
    );

    final snapshot = await repo.loadProgress();
    expect(snapshot.streak.current, 1);
    expect(snapshot.streak.longest, 7);
    expect(snapshot.stats.daysPlayed, 8);
    expect(snapshot.stats.averageScore, (7 * 100 / 8).round());
    expect(snapshot.unlockedBadgeIds,
        containsAll({'beginner', 'trainee'}));
  });

  test('progress survives a restart (same store, fresh repository)', () async {
    var day = DateTime(2026, 9, 20);
    final store = MemoryProgressStore();
    final service = DailyChallengeService(now: () => day);

    final firstRepo = ProgressRepository(store, now: () => day);
    final set = service.getTodaysSet();
    await firstRepo.recordCompletedDay(
      set: set,
      selections: const [0, 0, 0, 0, 0],
      completedAt: day,
    );

    // "Restart": a brand-new repository backed by the same store.
    final reopenedRepo = ProgressRepository(store, now: () => day);
    final snapshot = await reopenedRepo.loadProgress();
    expect(snapshot.streak.current, 1);
    expect(snapshot.stats.daysPlayed, 1);
    expect(snapshot.unlockedBadgeIds, contains('beginner'));
  });

  test('settings round trip', () async {
    final store = MemoryProgressStore();
    final repo = ProgressRepository(store);

    const settings = AppSettings(
      themeMode: 'dark',
      notificationsEnabled: true,
      notificationHour: 8,
      notificationMinute: 30,
      onboardingCompleted: true,
    );
    await repo.saveAppSettings(settings);
    final loaded = await repo.loadAppSettings();
    expect(loaded.themeMode, 'dark');
    expect(loaded.notificationsEnabled, true);
    expect(loaded.notificationHour, 8);
    expect(loaded.notificationMinute, 30);
    expect(loaded.onboardingCompleted, true);
  });

  test('loadProgress returns empty snapshot for fresh install', () async {
    final repo = ProgressRepository(MemoryProgressStore());
    final snapshot = await repo.loadProgress();
    expect(snapshot.dayResults, isEmpty);
    expect(snapshot.streak.current, 0);
    expect(snapshot.stats.daysPlayed, 0);
    expect(snapshot.playedToday, false);
    expect(snapshot.unlockedBadgeIds, isEmpty);
  });
}