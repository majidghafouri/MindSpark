import 'package:flutter_test/flutter_test.dart';
import 'package:nevermindspark/domain/models/challenge_type.dart';
import 'package:nevermindspark/domain/services/daily_challenge_service.dart';

void main() {
  final service = DailyChallengeService(now: () => DateTime(2026, 1, 5));

  test('produces exactly five challenges for a date', () {
    final set = service.getSetForDate(DateTime(2026, 1, 5));
    expect(set.challenges, hasLength(5));
  });

  test('covers every challenge category in every set', () {
    for (var day = 1; day <= 20; day++) {
      final set = service.getSetForDate(DateTime(2026, 1, day));
      final types = set.challenges.map((c) => c.type).toSet();
      expect(types, containsAll(ChallengeType.values),
          reason: 'all categories must appear in set for day $day');
    }
  });

  test('same date always produces the same set', () {
    final a = service.getSetForDate(DateTime(2026, 3, 14));
    final b = service.getSetForDate(DateTime(2026, 3, 14));
    expect(a.date, b.date);
    for (var i = 0; i < a.challenges.length; i++) {
      expect(a.challenges[i].prompt, b.challenges[i].prompt);
      expect(a.challenges[i].correctOption, b.challenges[i].correctOption);
      expect(a.challenges[i].answerIndex, b.challenges[i].answerIndex);
      expect(a.challenges[i].options, b.challenges[i].options);
    }
  });

  test('different dates produce different sets (fun for fairness)', () {
    final a = service.getSetForDate(DateTime(2026, 3, 14));
    final b = service.getSetForDate(DateTime(2026, 3, 15));
    final aPrompts = a.challenges.map((c) => c.prompt).join('|');
    final bPrompts = b.challenges.map((c) => c.prompt).join('|');
    expect(aPrompts, isNot(bPrompts));
  });

  test('every challenge is answerable (no impossible answers)', () {
    for (var month = 1; month <= 12; month++) {
      final set = service.getSetForDate(DateTime(2026, month, 15));
      for (final c in set.challenges) {
        expect(c.answerIndex, inInclusiveRange(0, c.options.length - 1));
        expect(c.options.toSet().length, c.options.length);
      }
    }
  });

  test('todays set reflects the injected clock', () {
    final fixed = DailyChallengeService(now: () => DateTime(2099, 12, 31));
    expect(fixed.getTodaysSet().date, DateTime(2099, 12, 31));

    final other = DailyChallengeService(now: () => DateTime(2099, 12, 31));
    final todayA = fixed.getTodaysSet();
    final todayB = other.getTodaysSet();
    for (var i = 0; i < todayA.challenges.length; i++) {
      expect(todayA.challenges[i].prompt, todayB.challenges[i].prompt);
    }
  });
}