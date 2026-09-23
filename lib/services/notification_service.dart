import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules one gentle daily reminder. Fails soft: if notification setup or
/// scheduling goes wrong (unsupported platform, missing permissions, bad
/// timezone), the app keeps working normally.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int _reminderId = 3001;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      final ok = await _plugin.initialize(settings: settings);
      _initialized = ok ?? true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> requestPermissions() async {
    if (!_initialized) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  /// Schedules a repeating daily reminder at [hour]:[minute] in local time.
  Future<bool> scheduleDaily({
    required int hour,
    required int minute,
    int? streak,
  }) async {
    if (!_initialized) return false;
    try {
      final now = DateTime.now();
      final tzLocation = tz.local;
      var scheduled = tz.TZDateTime(
        tzLocation,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!scheduled.isAfter(tz.TZDateTime.from(now, tzLocation))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final message = streak != null && streak > 0
          ? "Your brain challenge is ready! Don't break your $streak-day streak 🔥"
          : 'Your brain challenge is ready! 🔥';

      await _plugin.zonedSchedule(
        id: _reminderId,
        title: 'NeverMindSpark',
        body: message,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_challenge',
            'Daily Challenge',
            channelDescription: 'Reminder to play today\'s challenges',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelDaily() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _reminderId);
    } catch (_) {}
  }
}