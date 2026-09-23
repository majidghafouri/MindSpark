import 'dart:math';

import '../generators/attention_generator.dart';
import '../generators/challenge_generator.dart';
import '../generators/logic_generator.dart';
import '../generators/sequence_generator.dart';
import '../models/challenge_difficulty.dart';
import '../models/challenge_type.dart';
import '../models/daily_challenge_set.dart';
import 'seed.dart';

/// Produces the 5-challenge daily set for any date, deterministically.
class DailyChallengeService {
  DailyChallengeService({
    DateTime Function()? now,
    List<ChallengeGenerator>? generators,
  })  : _now = now ?? DateTime.now,
        generators = generators ??
            <ChallengeGenerator>[
              SequenceGenerator(),
              LogicGenerator(),
              AttentionGenerator(),
            ];

  final DateTime Function() _now;

  /// Generator per challenge type, in a stable order.
  final List<ChallengeGenerator> generators;

  /// Rotating category mix. Each entry maps a slot to a generator the service
  /// resolves by [ChallengeType].
  static const List<List<ChallengeType>> _patterns = [
    [ChallengeType.sequence, ChallengeType.oddOneOut, ChallengeType.attention, ChallengeType.oddOneOut, ChallengeType.sequence],
    [ChallengeType.attention, ChallengeType.sequence, ChallengeType.oddOneOut, ChallengeType.sequence, ChallengeType.attention],
    [ChallengeType.oddOneOut, ChallengeType.attention, ChallengeType.sequence, ChallengeType.attention, ChallengeType.oddOneOut],
    [ChallengeType.sequence, ChallengeType.attention, ChallengeType.oddOneOut, ChallengeType.sequence, ChallengeType.attention],
  ];

  static const List<ChallengeDifficulty> _difficulties = [
    ChallengeDifficulty.easy,
    ChallengeDifficulty.medium,
    ChallengeDifficulty.easy,
    ChallengeDifficulty.hard,
    ChallengeDifficulty.medium,
  ];

  DailyChallengeSet getTodaysSet() => getSetForDate(_now());

  DailyChallengeSet getSetForDate(DateTime date) {
    final day = normalizeDate(date);
    final base = dateSeed(day);
    final dayOfYear = day.difference(DateTime(day.year)).inDays;

    final pattern = _patterns[dayOfYear % _patterns.length];
    final generatorsByType = <ChallengeType, ChallengeGenerator>{
      for (final g in generators) g.type: g,
    };

    final challenges = List.generate(5, (index) {
      final type = pattern[index];
      final generator = generatorsByType[type]!;
      final difficulty =
          _difficulties[(index + dayOfYear) % _difficulties.length];
      final seed = challengeSeed(base, index, type.index, dayOfYear);
      final rng = Random(seed);
      return generator.generate(
        rng,
        difficulty,
        order: index + (dayOfYear % 5) * 5,
      );
    });

    return DailyChallengeSet(date: day, challenges: challenges);
  }
}