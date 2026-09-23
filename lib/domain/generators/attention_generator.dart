import 'dart:math';

import '../models/challenge.dart';
import '../models/challenge_difficulty.dart';
import '../models/challenge_type.dart';
import 'challenge_generator.dart';

/// Generates "attention" challenges: count the occurrences of a digit inside
/// a longer string, with length scaling by difficulty.
class AttentionGenerator extends ChallengeGenerator {
  @override
  ChallengeType get type => ChallengeType.attention;

  @override
  Challenge generate(
    Random rng,
    ChallengeDifficulty difficulty, {
    int order = 0,
  }) {
    final length = switch (difficulty) {
      ChallengeDifficulty.easy => 10,
      ChallengeDifficulty.medium => 18,
      ChallengeDifficulty.hard => 28,
    };
    final target = rng.nextInt(10);

    final buffer = StringBuffer();
    var count = 0;
    for (var i = 0; i < length; i++) {
      // Bias the harder tiers toward more occurrences so counting is the
      // challenge, not just hunting a rare digit.
      final roll = rng.nextInt(10);
      final useTarget = roll < (difficulty == ChallengeDifficulty.hard ? 4 : 3);
      final digit = useTarget ? target : rng.nextInt(10);
      buffer.write(digit);
      if (digit == target) count += 1;
    }
    final text = buffer.toString();
    // Three distinct, non-negative distractors around the true count.
    final distractorSet = <int>{
      count + 1,
      count + 2,
      count + 3,
      if (count - 1 >= 0) count - 1,
    }..remove(count);
    return buildChallenge(
      type: ChallengeType.attention,
      difficulty: difficulty,
      prompt: 'How many times does the digit $target appear?\n\n$text',
      correctAnswer: '$count',
      distractors: distractorSet.take(3).map((e) => '$e').toList(),
      explanation: 'The digit $target appears $count times in the string.',
      rng: rng,
      idSalt: 'attention-count-$difficulty.level-$order',
    );
  }
}