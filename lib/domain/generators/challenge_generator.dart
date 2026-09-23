import 'dart:math';

import '../models/challenge.dart';
import '../models/challenge_difficulty.dart';
import '../models/challenge_type.dart';

/// Base class for all challenge generators.
///
/// Generators must be pure with respect to the injected [Random]: the same
/// seed always produces the same, valid, solvable challenge.
abstract class ChallengeGenerator {
  /// The challenge type this generator produces.
  ChallengeType get type;

  Challenge generate(
    Random rng,
    ChallengeDifficulty difficulty, {
    int order = 0,
  });

  /// Convenience builder that shuffles a correct option among distractors
  /// and records the resulting answer index.
  Challenge buildChallenge({
    required ChallengeType type,
    required ChallengeDifficulty difficulty,
    required String prompt,
    required String correctAnswer,
    required List<String> distractors,
    required String explanation,
    required Random rng,
    required String idSalt,
  }) {
    assert(!distractors.contains(correctAnswer),
        'Distractors must not contain the correct answer.');
    final options = <String>[correctAnswer, ...distractors];
    final answerIndex = rng.nextInt(options.length);
    final tmp = options[0];
    options[0] = options[answerIndex];
    options[answerIndex] = tmp;

    return Challenge(
      id: '${type.name}-${difficulty.name}-$idSalt',
      type: type,
      difficulty: difficulty,
      prompt: prompt,
      options: List.unmodifiable(options),
      answerIndex: answerIndex,
      explanation: explanation,
    );
  }

  /// Produces [count] distinct numeric distractors around [correct].
  List<String> numericDistractors(
    int correct,
    Random rng, {
    int count = 3,
    bool allowZero = true,
  }) {
    if (count <= 0) return const [];
    final candidates = <int>[
      correct + 1, correct - 1, correct + 2, correct - 2,
      correct + 5, correct - 5, correct + 10, correct - 10,
      correct + 3, correct - 3,
    ];
    candidates.shuffle(rng);
    final result = <int>{};
    for (final candidate in candidates) {
      if (result.length >= count) break;
      if (!allowZero && candidate <= 0) continue;
      result.add(candidate);
    }
    var filler = 7;
    while (result.length < count) {
      result.add(correct + filler);
      filler += 2;
    }
    return result.take(count).map((e) => '$e').toList();
  }
}