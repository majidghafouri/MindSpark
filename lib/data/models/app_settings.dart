/// Persisted user preferences.
class AppSettings {
  const AppSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = false,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.onboardingCompleted = false,
  });

  final String themeMode; // 'system' | 'light' | 'dark'
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;
  final bool onboardingCompleted;

  AppSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    bool? onboardingCompleted,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        notificationHour: notificationHour ?? this.notificationHour,
        notificationMinute: notificationMinute ?? this.notificationMinute,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'notificationsEnabled': notificationsEnabled,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'onboardingCompleted': onboardingCompleted,
      };

  static AppSettings fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: json['themeMode'] as String? ?? 'system',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
        notificationHour: json['notificationHour'] as int? ?? 9,
        notificationMinute: json['notificationMinute'] as int? ?? 0,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      );
}