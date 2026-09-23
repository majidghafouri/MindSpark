import 'challenge_difficulty.dart';
import 'challenge_type.dart';

/// A single brain challenge: a prompt, a fixed set of options and the
/// index of the correct answer.
class Challenge {
  const Challenge({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  })  : assert(options.length >= 2, 'A challenge needs at least 2 options.'),
        assert(answerIndex >= 0 && answerIndex < options.length,
            'answerIndex must point into options.');

  final String id;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  String get correctOption {
    assert(options.length > answerIndex);
    return options[answerIndex];
  }

  bool isCorrect(int selectedIndex) => selectedIndex == answerIndex;
}