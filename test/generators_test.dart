import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nevermindspark/domain/generators/attention_generator.dart';
import 'package:nevermindspark/domain/generators/challenge_generator.dart';
import 'package:nevermindspark/domain/generators/logic_generator.dart';
import 'package:nevermindspark/domain/generators/sequence_generator.dart';
import 'package:nevermindspark/domain/models/challenge.dart';
import 'package:nevermindspark/domain/models/challenge_difficulty.dart';

void main() {
  final generators = <ChallengeGenerator>[
    SequenceGenerator(),
    LogicGenerator(),
    AttentionGenerator(),
  ];

  for (final generator in generators) {
    group(generator.type.name, () {
      for (final difficulty in ChallengeDifficulty.values) {
        test('produces a valid solvable challenge at ${difficulty.name}', () {
          for (var i = 0; i < 50; i++) {
            final challenge =
                generator.generate(Random(42), difficulty, order: i);
            expect(challenge.type, generator.type,
                reason: 'challenge type matches generator');
            expect(challenge.difficulty, difficulty);
            expect(challenge.prompt, isNotEmpty);
            expect(challenge.options.length, greaterThanOrEqualTo(2));
            expect(challenge.options.toSet().length, challenge.options.length,
                reason: 'options must be unique');
            expect(challenge.answerIndex,
                inInclusiveRange(0, challenge.options.length - 1));
            expect(challenge.explanation, isNotEmpty);
            expect(challenge.correctOption,
                challenge.options[challenge.answerIndex]);

            // The correct option must be a real string, not an accidental
            // duplicate of another option.
            final correct = challenge.correctOption;
            final others =
                challenge.options.where((o) => o != correct).toList();
            expect(others, isNot(contains(correct)),
                reason: 'correct answer must not collide with distractors');

            // Generate again with the same seed: fully deterministic.
            final again =
                generator.generate(Random(42), difficulty, order: i);
            expect(again.prompt, challenge.prompt);
            expect(again.correctOption, correct);
          }
        });
      }
    });
  }

  group('SequenceGenerator', () {
    test('easy challenges are arithmetic and next term is correct', () {
      final gen = SequenceGenerator();
      for (var i = 0; i < 200; i++) {
        final rng = Random(i);
        final c = gen.generate(rng, ChallengeDifficulty.easy, order: i);
        final numbers = _sequenceNumbers(c);
        expect(numbers, hasLength(5));
        final steps = {
          for (var k = 1; k < numbers.length; k++) numbers[k] - numbers[k - 1],
        };
        expect(steps, hasLength(1),
            reason: 'easy sequences must have a constant step');
        final expected = numbers.last + steps.first;
        expect(int.parse(c.correctOption), expected);
      }
    });

    test('hard fibonacci challenges are correct', () {
      final gen = SequenceGenerator();
      var fibVerified = 0;
      for (var i = 0; i < 400; i++) {
        final rng = Random(i);
        final c = gen.generate(rng, ChallengeDifficulty.hard, order: i % 5);
        if (c.explanation.contains('sum of the two numbers before it')) {
          fibVerified++;
          final numbers = _sequenceNumbers(c);
          final next = numbers[numbers.length - 2] + numbers.last;
          expect(int.parse(c.correctOption), next);
        }
      }
      expect(fibVerified, greaterThan(0), reason: 'fib variants should occur');
    });
  });

  group('AttentionGenerator', () {
    test('answer matches an actual count of the target digit', () {
      final gen = AttentionGenerator();
      for (var i = 0; i < 200; i++) {
        final c =
            gen.generate(Random(i), ChallengeDifficulty.medium, order: i);
        final match = RegExp(r'How many times does the digit (\d) appear')
            .firstMatch(c.prompt)!;
        final target = match.group(1)!;
        final text = c.prompt.split('\n\n').last;
        final count = target.allMatches(text).length;
        expect(c.correctOption, '$count');
      }
    });
  });
}

/// Extracts just the numeric terms from a sequence prompt, ignoring the
/// question sentence and the em-dash it contains.
List<int> _sequenceNumbers(Challenge challenge) {
  final digitsOnly = challenge.prompt.replaceAll(RegExp(r'[^\d,\s]'), '');
  return digitsOnly
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map(int.parse)
      .toList();
}