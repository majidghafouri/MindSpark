import 'package:flutter_test/flutter_test.dart';
import 'package:nevermindspark/data/models/day_result.dart';
import 'package:nevermindspark/domain/models/challenge.dart';
import 'package:nevermindspark/domain/models/challenge_difficulty.dart';
import 'package:nevermindspark/domain/models/challenge_type.dart';
import 'package:nevermindspark/domain/models/daily_challenge_set.dart';

Challenge c(ChallengeType type, ChallengeDifficulty difficulty) => Challenge(
      id: '${type.name}-${difficulty.name}',
      type: type,
      difficulty: difficulty,
      prompt: 'P',
      options: const ['A', 'B', 'C', 'D'],
      answerIndex: 0,
      explanation: 'E',
    );

void main() {
  const calculator = ScoreCalculator();

  final set = DailyChallengeSet(
    date: DateTime(2026, 9, 23),
    challenges: [
      c(ChallengeType.sequence, ChallengeDifficulty.easy),    // 15
      c(ChallengeType.sequence, ChallengeDifficulty.medium), // 18
      c(ChallengeType.oddOneOut, ChallengeDifficulty.easy),  // 15
      c(ChallengeType.oddOneOut, ChallengeDifficulty.hard),  // 20
      c(ChallengeType.attention, ChallengeDifficulty.easy),  // 15
    ],
  );

  test('all correct -> perfect 100', () {
    final r = calculator.computeForSet(
        set, const [0, 0, 0, 0, 0], DateTime(2026, 9, 23, 10));
    expect(r.correctCount, 5);
    expect(r.score, 100);
    expect(r.categoryScores['numbers'], 100);
    expect(r.categoryScores['logic'], 100);
    expect(r.categoryScores['attention'], 100);
  });

  test('all wrong -> 0', () {
    final r = calculator.computeForSet(
        set, const [1, 1, 1, 1, 1], DateTime(2026, 9, 23, 10));
    expect(r.correctCount, 0);
    expect(r.score, 0);
  });

  test('partial credit respects difficulty weighting', () {
    // Only the first (easy, 15) correct:
    final r = calculator.computeForSet(
        set, const [0, 1, 1, 1, 1], DateTime(2026, 9, 23, 10));
    expect(r.correctCount, 1);
    expect(r.earnedScore, 15);
    expect(r.maxScore, 83);
    expect(r.score, (15 * 100 / 83).round());
  });

  test('category score is percentage within category', () {
    final r = calculator.computeForSet(
        set, const [0, 0, 0, 1, 1], DateTime(2026, 9, 23, 10));
    // numbers: 15+18 both correct -> 100
    // logic: easy correct (15), hard wrong (20) -> 15/35 = 42.9% -> 43
    expect(r.categoryScores['numbers'], 100);
    expect(r.categoryScores['logic'], (15 * 100 / 35).round());
    expect(r.categoryScores['attention'], 0);
  });

  test('missing selections count as wrong', () {
    final r = calculator.computeForSet(set, const [0], DateTime(2026, 9, 23, 10));
    expect(r.correctCount, 1);
    expect(r.earnedScore, 15);
  });

  test('DayResult survives JSON round trip', () {
    final original = calculator.computeForSet(
        set, const [0, 0, 1, 1, 1], DateTime(2026, 9, 23, 10));
    final restored = DayResult.fromJson(original.toJson());
    expect(restored.score, original.score);
    expect(restored.correctCount, original.correctCount);
    expect(restored.categoryScores, original.categoryScores);
    expect(restored.date, original.date);
  });
}