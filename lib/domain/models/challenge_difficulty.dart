/// Difficulty tiers. Higher tiers are worth more points.
enum ChallengeDifficulty {
  easy(1, 'Easy', 15),
  medium(2, 'Medium', 18),
  hard(3, 'Hard', 20);

  const ChallengeDifficulty(this.level, this.label, this.points);

  /// Sorting order, easy < medium < hard.
  final int level;

  /// Human readable label.
  final String label;

  /// Points awarded for a correct answer.
  final int points;

  /// Seconds available per question at this tier.
  int get timeLimitSeconds {
    switch (this) {
      case easy:
        return 20;
      case medium:
        return 30;
      case hard:
        return 45;
    }
  }
}