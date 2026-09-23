import '../../domain/models/daily_challenge_set.dart';

/// Stores a single day's performance so it can be surfaced in stats and
/// used for the streak calculation. Scores are normalized to 0-100.
class DayResult {
  const DayResult({
    required this.date,
    required this.score,       // 0-100 overall
    required this.correctCount,
    required this.maxScore,
    required this.earnedScore,
    required this.categoryScores, // category -> 0-100
  });

  final DateTime date;
  final int score;
  final int correctCount;
  final int maxScore;
  final int earnedScore;
  final Map<String, int> categoryScores;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'correctCount': correctCount,
        'maxScore': maxScore,
        'earnedScore': earnedScore,
        'categoryScores': categoryScores,
      };

  static DayResult fromJson(Map<String, dynamic> json) => DayResult(
        date: DateTime.parse(json['date'] as String),
        score: json['score'] as int,
        correctCount: json['correctCount'] as int,
        maxScore: json['maxScore'] as int,
        earnedScore: json['earnedScore'] as int,
        categoryScores: Map<String, int>.from(
            json['categoryScores'] as Map<String, dynamic>),
      );
}

/// Pure scoring logic shared by the session and the repository.
class ScoreCalculator {
  const ScoreCalculator();

  DayResult computeForSet(
      DailyChallengeSet set, List<int?> selections, DateTime completedAt) {
    var earned = 0;
    var maxPoints = 0;
    var correct = 0;

    final categoryEarned = <String, int>{};
    final categoryMax = <String, int>{};

    for (var i = 0; i < set.challenges.length; i++) {
      final challenge = set.challenges[i];
      final selection = i < selections.length ? selections[i] : null;
      maxPoints += challenge.difficulty.points;
      categoryMax[challenge.type.category] =
          (categoryMax[challenge.type.category] ?? 0) +
              challenge.difficulty.points;
      if (selection != null && challenge.isCorrect(selection)) {
        earned += challenge.difficulty.points;
        categoryEarned[challenge.type.category] =
            (categoryEarned[challenge.type.category] ?? 0) +
                challenge.difficulty.points;
        correct += 1;
      }
    }

    final categoryScores = <String, int>{};
    for (final category in categoryMax.keys) {
      final max = categoryMax[category]!;
      final got = categoryEarned[category] ?? 0;
      categoryScores[category] = max == 0 ? 0 : (got * 100 / max).round();
    }

    final score = maxPoints == 0 ? 0 : (earned * 100 / maxPoints).round();

    return DayResult(
      date: completedAt,
      score: score,
      correctCount: correct,
      maxScore: maxPoints,
      earnedScore: earned,
      categoryScores: categoryScores,
    );
  }
}