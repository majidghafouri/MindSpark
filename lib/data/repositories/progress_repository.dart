import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/models/daily_challenge_set.dart';
import '../models/app_settings.dart';
import '../models/badge.dart';
import '../models/day_result.dart';
import '../models/progress.dart';
import '../models/streak_calculator.dart';

/// Minimal key/value abstraction so the repository can be tested with an
/// in-memory implementation and run with a real storage backend.
abstract class ProgressStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Hive-backed store. Values are kept as JSON strings in a single box.
class HiveProgressStore implements ProgressStore {
  HiveProgressStore(this._box);

  final Box<String> _box;

  @override
  Future<String?> read(String key) async => _box.get(key);

  @override
  Future<void> write(String key, String value) async {
    await _box.put(key, value);
  }
}

/// In-memory store, useful for tests.
class MemoryProgressStore implements ProgressStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }
}

/// Combines [ProgressStore] with the pure scoring and streak logic to bring
/// everything together: history, streaks, badges and stats.
abstract class ProgressRepositoryBase {
  Future<AppSettings> loadAppSettings();
  Future<void> saveAppSettings(AppSettings settings);
  Future<ProgressSnapshot> loadProgress();
  Future<DayResult> recordCompletedDay({
    required DailyChallengeSet set,
    required List<int?> selections,
    required DateTime completedAt,
  });
}

class ProgressRepository extends ProgressRepositoryBase {
  ProgressRepository(this._store, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final ProgressStore _store;
  final DateTime Function() _now;

  static const _settingsKey = 'settings';
  static const _historyKey = 'history';
  static const _badgesKey = 'badges';

  @override
  Future<AppSettings> loadAppSettings() async {
    final raw = await _store.read(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    await _store.write(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<ProgressSnapshot> loadProgress() async {
    final results = await _loadDayResults();
    final keys = results.map((r) => DayKey.of(r.date)).toList();
    final today = DateTime(_now().year, _now().month, _now().day);
    final streak = const StreakCalculator().compute(
      completedDayKeys: keys,
      today: today,
    );

    final unlocked = await _loadBadgeIds();
    final stats = _computeStats(results);

    return ProgressSnapshot(
      dayResults: results,
      streak: streak,
      unlockedBadgeIds: unlocked,
      stats: stats,
      playedToday: keys.contains(DayKey.of(today)),
    );
  }

  @override
  Future<DayResult> recordCompletedDay({
    required DailyChallengeSet set,
    required List<int?> selections,
    required DateTime completedAt,
  }) async {
    final result =
        const ScoreCalculator().computeForSet(set, selections, completedAt);
    final results = await _loadDayResults();
    final key = DayKey.of(result.date);

    final updated = <DayResult>[
      ...results.where((r) => DayKey.of(r.date) != key),
      result,
    ]..sort((a, b) => a.date.compareTo(b.date));

    await _store.write(
      _historyKey,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );

    final today = DateTime(_now().year, _now().month, _now().day);
    final streak = const StreakCalculator().compute(
      completedDayKeys: updated.map((r) => DayKey.of(r.date)).toList(),
      today: today,
    );
    await _unlockBadges(streak.current);

    return result;
  }

  Future<List<DayResult>> _loadDayResults() async {
    final raw = await _store.read(_historyKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final results = [
        for (final item in list) DayResult.fromJson(item as Map<String, dynamic>),
      ]..sort((a, b) => a.date.compareTo(b.date));
      return results;
    } catch (_) {
      return const [];
    }
  }

  Future<Set<String>> _loadBadgeIds() async {
    final raw = await _store.read(_badgesKey);
    if (raw == null) return <String>{};
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _unlockBadges(int currentStreak) async {
    final unlocked = await _loadBadgeIds();
    var changed = false;
    for (final badge in Badge.all) {
      if (badge.requiredStreakDays <= currentStreak) {
        changed = unlocked.add(badge.id) || changed;
      }
    }
    if (changed) {
      await _store.write(_badgesKey, jsonEncode(unlocked.toList()));
    }
  }

  StatsSummary _computeStats(List<DayResult> results) {
    if (results.isEmpty) {
      return const StatsSummary(daysPlayed: 0, averageScore: 0, bestScore: 0);
    }
    var sum = 0;
    var best = 0;
    for (final r in results) {
      sum += r.score;
      if (r.score > best) best = r.score;
    }
    return StatsSummary(
      daysPlayed: results.length,
      averageScore: (sum / results.length).round(),
      bestScore: best,
    );
  }
}

class MemoryProgressStoreRepository extends ProgressRepository {
  MemoryProgressStoreRepository({super.now}) : super(MemoryProgressStore());
}