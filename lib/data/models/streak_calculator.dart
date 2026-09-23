import 'progress.dart';

/// Pure streak math over a set of completed day keys.
///
/// Rules (design decision): a streak grows when consecutive calendar days are
/// completed. Missing a day (>= 2 days gap) breaks the current streak back to
/// 0, but the longest streak and full history are always preserved.
class StreakCalculator {
  const StreakCalculator();

  StreakInfo compute({
    required List<String> completedDayKeys,
    required DateTime today,
  }) {
    final keys = completedDayKeys.toSet();
    final longest = _longestRun(keys);

    var current = 0;
    var cursor = today;
    while (
        cursor.difference(DateTime(2020)).inDays >= 0 &&
            keys.contains(DayKey.of(cursor))) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (current == 0) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (keys.contains(DayKey.of(yesterday))) {
        current = 1;
        cursor = yesterday.subtract(const Duration(days: 1));
        while (keys.contains(DayKey.of(cursor))) {
          current += 1;
          cursor = cursor.subtract(const Duration(days: 1));
        }
      }
    }

    return StreakInfo(
      current: current,
      longest: longest,
      lastPlayedDayKey: keys.isEmpty ? null : _lastKey(keys),
    );
  }

  int _longestRun(Set<String> keys) {
    if (keys.isEmpty) return 0;
    final list = keys.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < list.length; i++) {
      final prev = DateTime.parse(list[i - 1]);
      final cur = DateTime.parse(list[i]);
      if (cur.difference(prev).inDays == 1) {
        run += 1;
      } else {
        run = 1;
      }
      if (run > best) best = run;
    }
    return best;
  }

  String _lastKey(Set<String> keys) {
    final list = keys.toList()..sort();
    return list.last;
  }
}