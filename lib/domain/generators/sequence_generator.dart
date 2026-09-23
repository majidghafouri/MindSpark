import 'dart:math';

import '../models/challenge.dart';
import '../models/challenge_difficulty.dart';
import '../models/challenge_type.dart';
import 'challenge_generator.dart';

/// Generates "what comes next?" number-sequence challenges.
class SequenceGenerator extends ChallengeGenerator {
  @override
  ChallengeType get type => ChallengeType.sequence;

  @override
  Challenge generate(
    Random rng,
    ChallengeDifficulty difficulty, {
    int order = 0,
  }) {
    final (terms, next, explanation) = _pattern(rng, difficulty);
    final prompt =
        '${terms.map((t) => '$t').join(', ')}, ? — what comes next?';
    return buildChallenge(
      type: ChallengeType.sequence,
      difficulty: difficulty,
      prompt: prompt,
      correctAnswer: '$next',
      distractors: numericDistractors(next, rng, allowZero: next > 15),
      explanation: explanation,
      rng: rng,
      idSalt: 'seq-$difficulty.level-$order',
    );
  }

  (List<int>, int, String) _pattern(Random rng, ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        final start = 2 + rng.nextInt(8);
        final step = 2 + rng.nextInt(4) * 2;
        final terms = [for (var i = 0; i < 5; i++) start + i * step];
        final next = start + 5 * step;
        return (terms, next, 'Each number is the previous one plus $step.');
      case ChallengeDifficulty.medium:
        if (rng.nextBool()) {
          // The gap between terms grows by 1 every step.
          final start = 1 + rng.nextInt(5);
          final firstGap = 2 + rng.nextInt(3);
          final terms = <int>[start];
          var value = start;
          var gap = firstGap;
          for (var i = 1; i < 5; i++) {
            value += gap;
            terms.add(value);
            gap += 1;
          }
          return (terms, value + gap, 'The gap between numbers grows by 1 each step.');
        } else {
          // Geometric: each term is the previous times a fixed ratio.
          final start = 2 + rng.nextInt(3);
          final ratio = 2 + rng.nextInt(3);
          final terms = [for (var i = 0; i < 5; i++) start * pow(ratio, i).toInt()];
          final next = start * pow(ratio, 5).toInt();
          return (terms, next, 'Each number is the previous one multiplied by $ratio.');
        }
      case ChallengeDifficulty.hard:
        if (rng.nextBool()) {
          // Fibonacci-style: each term is the sum of the two before it.
          final a = 1 + rng.nextInt(3);
          final b = 2 + rng.nextInt(3);
          final terms = <int>[a, b];
          for (var i = 2; i < 5; i++) {
            terms.add(terms[i - 1] + terms[i - 2]);
          }
          final next = terms[4] + terms[3];
          return (terms, next, 'Each number is the sum of the two numbers before it.');
        } else {
          // Two interleaved arithmetic sequences (odd and even positions).
          final startOdd = 1 + rng.nextInt(6);
          final startEven = 2 + rng.nextInt(6);
          final stepOdd = 2 + rng.nextInt(4);
          final stepEven = 3 + rng.nextInt(4);
          final terms = <int>[];
          for (var i = 0; i < 5; i++) {
            if (i.isEven) {
              terms.add(startOdd + (i ~/ 2) * stepOdd);
            } else {
              terms.add(startEven + ((i - 1) ~/ 2) * stepEven);
            }
          }
          final next = startEven + 2 * stepEven;
          return (
            terms,
            next,
            'Odd and even positions follow their own patterns '
                '($stepOdd and $stepEven).',
          );
        }
    }
  }
}