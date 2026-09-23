import 'dart:math';

import '../models/challenge.dart';
import '../models/challenge_difficulty.dart';
import '../models/challenge_type.dart';
import 'challenge_generator.dart';

/// Generates logic challenges: odd-one-out for easier tiers and simple
/// deduction puzzles for the hard tier.
class LogicGenerator extends ChallengeGenerator {
  @override
  ChallengeType get type => ChallengeType.oddOneOut;

  static const List<_OddOneOutGroup> _groups = [
    _OddOneOutGroup(['Apple', 'Banana', 'Carrot', 'Grape'], 'Carrot',
        'A carrot is a vegetable; the others are fruits.'),
    _OddOneOutGroup(['Monday', 'Tuesday', 'Sunday', 'Wednesday'], 'Sunday',
        'Sunday is a weekend day; the others are weekdays.'),
    _OddOneOutGroup(['Elephant', 'Giraffe', 'Shark', 'Kangaroo'], 'Shark',
        'A shark lives in the sea; the others live on land.'),
    _OddOneOutGroup(['Rose', 'Tulip', 'Lily', 'Pine'], 'Pine',
        'A pine is a tree; the others are flowers.'),
    _OddOneOutGroup(
        ['Car', 'Bus', 'Boat', 'Train'],
        'Boat',
        'A boat travels on water; the others travel on land.'),
    _OddOneOutGroup(
        ['Piano', 'Guitar', 'Violin', 'Drums'],
        'Drums',
        'Drums are a percussion instrument; the others are string instruments.'),
    _OddOneOutGroup(['Dog', 'Horse', 'Eagle', 'Cow'], 'Eagle',
        'An eagle is a bird; the others are mammals.'),
    _OddOneOutGroup(['4', '9', '12', '18'], '9',
        '9 is odd; the others are all even numbers.'),
    _OddOneOutGroup(['Red', 'Blue', 'Yellow', 'Circle'], 'Circle',
        'A circle is a shape; the others are colors.'),
    _OddOneOutGroup(['Soccer', 'Tennis', 'Swimming', 'Chess'], 'Chess',
        'Chess is a board game; the others are physical sports.'),
  ];

  static const List<String> _names = [
    'Alice', 'Bob', 'Carol', 'Dan', 'Eve', 'Frank', 'Grace',
  ];

  @override
  Challenge generate(
    Random rng,
    ChallengeDifficulty difficulty, {
    int order = 0,
  }) {
    if (difficulty == ChallengeDifficulty.hard) {
      return _deduction(rng, order);
    }
    final tier = difficulty == ChallengeDifficulty.easy ? 0 : 1;
    final pool =
        _groups.where((g) => _tier(g) <= tier).toList()..shuffle(rng);
    final group = pool[rng.nextInt(pool.length)];
    return buildChallenge(
      type: ChallengeType.oddOneOut,
      difficulty: difficulty,
      prompt: 'Which one does not belong?',
      correctAnswer: group.oddItem,
      distractors: group.items.where((o) => o != group.oddItem).toList(),
      explanation: group.explanation,
      rng: rng,
      idSalt: 'logic-oddoneout-$difficulty.level-$order',
    );
  }

  Challenge _deduction(Random rng, int order) {
    final names = [..._names]..shuffle(rng);
    final a = names[0];
    final b = names[1];
    final c = names[2];
    final template = rng.nextInt(3);
    switch (template) {
      case 0:
        final prompt = '$a is taller than $b. $b is taller than $c. '
            'Who is the tallest?';
        return buildChallenge(
          type: ChallengeType.oddOneOut,
          difficulty: ChallengeDifficulty.hard,
          prompt: prompt,
          correctAnswer: a,
          distractors: [b, c],
          explanation: '$a is taller than $b, and $b is taller than $c, '
              'so $a is the tallest.',
          rng: rng,
          idSalt: 'logic-deduction-a-$order',
        );
      case 1:
        final prompt = '$a is faster than $b. $c is slower than $b. '
            'Who is the slowest?';
        return buildChallenge(
          type: ChallengeType.oddOneOut,
          difficulty: ChallengeDifficulty.hard,
          prompt: prompt,
          correctAnswer: c,
          distractors: [a, b],
          explanation: 'Since $c is slower than $b and $b is slower than $a, '
              '$c is the slowest.',
          rng: rng,
          idSalt: 'logic-deduction-b-$order',
        );
      default:
        const prompt = 'The day before yesterday was Tuesday. '
            'What day is it today?';
        return buildChallenge(
          type: ChallengeType.oddOneOut,
          difficulty: ChallengeDifficulty.hard,
          prompt: prompt,
          correctAnswer: 'Thursday',
          distractors: [
            'Monday', 'Tuesday', 'Wednesday', 'Friday', 'Saturday', 'Sunday',
          ],
          explanation: 'The day before yesterday was Tuesday, so yesterday was '
              'Wednesday and today is Thursday.',
          rng: rng,
          idSalt: 'logic-deduction-c-$order',
        );
    }
  }

  static int _tier(_OddOneOutGroup group) {
    // Obvious/very common groups first, trickier ones later in the list.
    final index = _groups.indexOf(group);
    return index < 5 ? 0 : 1;
  }
}

class _OddOneOutGroup {
  const _OddOneOutGroup(this.items, this.oddItem, this.explanation);

  final List<String> items;
  final String oddItem;
  final String explanation;
}