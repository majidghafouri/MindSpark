import 'challenge.dart';

/// A full day's worth of challenges: always exactly 5, covering a mix of
/// categories, generated deterministically from the date.
class DailyChallengeSet {
  DailyChallengeSet({required this.date, required List<Challenge> challenges})
      : assert(challenges.length == 5, 'A daily set must contain 5 challenges.'),
        challenges = List.unmodifiable(challenges);

  /// The calendar day this set is for (normalized to midnight).
  final DateTime date;

  /// The five challenges, in play order.
  final List<Challenge> challenges;

  /// Total points available if every challenge is answered correctly.
  int get maxScore =>
      challenges.fold(0, (sum, c) => sum + c.difficulty.points);

  /// Category breakdown (category name -> number of challenges).
  Map<String, int> get categoryBreakdown {
    final breakdown = <String, int>{};
    for (final c in challenges) {
      breakdown[c.type.category] = (breakdown[c.type.category] ?? 0) + 1;
    }
    return breakdown;
  }
}