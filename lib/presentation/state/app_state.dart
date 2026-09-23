import 'package:flutter/foundation.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/day_result.dart';
import '../../data/models/progress.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/daily_challenge_set.dart';
import '../../domain/services/daily_challenge_service.dart';
import '../../services/notification_service.dart';

/// Central app controller: owns settings, progress and today's challenge set,
/// and exposes them to the UI via provider.
class AppState extends ChangeNotifier {
  AppState({
    required this.repository,
    DailyChallengeService? challengeService,
    NotificationService? notifications,
    DateTime Function()? now,
  })  : _challengeService = challengeService ?? DailyChallengeService(now: now),
        _notifications = notifications ?? NotificationService(),
        _now = now ?? DateTime.now {
    _init();
  }

  final ProgressRepositoryBase repository;
  final DailyChallengeService _challengeService;
  final NotificationService _notifications;
  final DateTime Function() _now;

  AppSettings _settings = const AppSettings();
  ProgressSnapshot _progress =
      const ProgressSnapshot(dayResults: [], streak: StreakInfo(current: 0, longest: 0), unlockedBadgeIds: {}, stats: StatsSummary(daysPlayed: 0, averageScore: 0, bestScore: 0));
  DailyChallengeSet? _todaySet;
  bool _ready = false;

  Future<void> _init() async {
    _settings = await repository.loadAppSettings();
    _progress = await repository.loadProgress();
    _todaySet = _challengeService.getTodaysSet();
    _ready = true;
    notifyListeners();
  }

  bool get isReady => _ready;
  AppSettings get settings => _settings;
  ProgressSnapshot get progress => _progress;
  DailyChallengeSet? get todaySet => _todaySet;

  /// Whether today's set has been completed yet.
  bool get hasPlayedToday => _progress.playedToday;

  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(onboardingCompleted: true);
    await repository.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await repository.saveAppSettings(_settings);
    notifyListeners();
  }

  void setDefaultNotificationTimeLocal({required int hour, required int minute}) {
    _settings =
        _settings.copyWith(notificationHour: hour, notificationMinute: minute);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await repository.saveAppSettings(_settings);
    notifyListeners();
    if (enabled) {
      await enableNotifications();
    } else {
      await _notifications.cancelDaily();
    }
  }

  /// Ensures permissions are granted and schedules the daily reminder.
  Future<void> enableNotifications() async {
    await _notifications.init();
    await _notifications.requestPermissions();
    final ok = await _notifications.scheduleDaily(
      hour: _settings.notificationHour,
      minute: _settings.notificationMinute,
      streak: _progress.streak.current,
    );
    if (!ok) {
      // Graceful: if scheduling failed (e.g. permissions denied), leave the
      // toggle off so the user isn't told a reminder exists when it doesn't.
      _settings = _settings.copyWith(notificationsEnabled: false);
      await repository.saveAppSettings(_settings);
      notifyListeners();
    }
  }

  /// Records today's completed run and refreshes progress/streaks/badges.
  Future<DayResult> recordResult(List<int?> selections) async {
    final set = _todaySet!;
    final result = await repository.recordCompletedDay(
      set: set,
      selections: selections,
      completedAt: _now(),
    );
    _progress = await repository.loadProgress();
    notifyListeners();
    return result;
  }
}