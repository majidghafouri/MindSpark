import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Card(
                  child: RadioGroup(
                    value: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) appState.setThemeMode(value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Daily reminder',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Remind me to play'),
                        subtitle: Text(
                          settings.notificationsEnabled
                              ? 'A daily notification keeps your streak alive.'
                              : 'Get a gentle nudge once a day.',
                        ),
                        value: settings.notificationsEnabled,
                        onChanged: appState.setNotificationsEnabled,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        enabled: settings.notificationsEnabled,
                        title: const Text('Reminder time'),
                        subtitle: Text(
                          '${settings.notificationHour.toString().padLeft(2, '0')}:'
                          '${settings.notificationMinute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: settings.notificationsEnabled
                            ? () => _pickTime(context, appState)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: scheme.primary),
                    title: const Text('About'),
                    subtitle: const Text('NeverMindSpark v1.0.0'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, AppState appState) async {
    final settings = appState.settings;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
    );
    if (time == null) return;
    appState.setDefaultNotificationTimeLocal(
      hour: time.hour,
      minute: time.minute,
    );
    // Re-schedule with the new time (permission already granted).
    await appState.enableNotifications();
  }
}

class RadioGroup extends StatelessWidget {
  const RadioGroup({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  static const _options = [
    ('system', 'System'),
    ('light', 'Light'),
    ('dark', 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (key, label) in _options)
          ListTile(
            title: Text(label),
            trailing: value == key
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                : const Icon(Icons.circle_outlined),
            onTap: () => onChanged(key),
          ),
      ],
    );
  }
}