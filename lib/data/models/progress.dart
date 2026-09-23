import 'day_result.dart';

/// Day-key helper: `yyyy-MM-dd`, local calendar day.
class DayKey {
  static String of(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}

/// Current and best streak state.
class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.longest,
    this.lastPlayedDayKey,
  });

  final int current;
  final int longest;
  final String? lastPlayedDayKey;

  /// A streak is considered "live" (not yet broken) when the player played
  /// today or yesterday. A missed day resets [current] to 0 while [longest]
  /// and the full history are preserved.
  bool get isLive => current > 0;
}

/// Aggregate stats shown on the stats screen.
class StatsSummary {
  const StatsSummary({
    required this.daysPlayed,
    required this.averageScore,
    required this.bestScore,
  });

  final int daysPlayed;
  final int averageScore;
  final int bestScore;
}

/// The full persisted progress snapshot.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.dayResults,
    required this.streak,
    required this.unlockedBadgeIds,
    required this.stats,
    this.playedToday = false,
  });

  final List<DayResult> dayResults;

  /// Sorted oldest -> newest.
  final StreakInfo streak;
  final Set<String> unlockedBadgeIds;
  final StatsSummary stats;
  final bool playedToday;
}