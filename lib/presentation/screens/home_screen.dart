import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';

import '../../data/models/badge.dart';
import '../../domain/models/daily_challenge_set.dart';
import '../state/app_state.dart';
import '../state/game_session.dart';
import '../widgets/banner_ad_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.progress;
    final set = appState.todaySet;
    final streak = progress.streak.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeverMindSpark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Stats',
            onPressed: () => Navigator.pushNamed(context, Routes.stats),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StreakCard(streak: streak),
                      const SizedBox(height: 20),
                      _TodayCard(
                        set: set,
                        hasPlayed: appState.hasPlayedToday,
                        playedScore: progress.dayResults.isEmpty
                            ? null
                            : progress.dayResults.last.score,
                      ),
                      if (set != null) ...[
                        const SizedBox(height: 20),
                        _StartButton(
                          set: set,
                          hasPlayed: appState.hasPlayedToday,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _BadgesRow(unlocked: progress.unlockedBadgeIds),
                    ],
                  ),
                ),
              ),
              const BannerAdView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: streak > 0
                    ? Colors.orange.withValues(alpha: 0.15)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.local_fire_department,
                color: streak > 0 ? Colors.deepOrange : scheme.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak > 0 ? '$streak day streak' : 'No streak yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streak > 0
                        ? 'Keep it alive — play today!'
                        : 'Complete today\'s set to start one.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.set,
    required this.hasPlayed,
    required this.playedScore,
  });

  final DailyChallengeSet? set;
  final bool hasPlayed;
  final int? playedScore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final todaySet = set;
    final statusColor = hasPlayed ? Colors.green : scheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s challenges',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Chip(
                  avatar: Icon(
                    hasPlayed ? Icons.check_circle : Icons.schedule,
                    size: 16,
                    color: statusColor,
                  ),
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  label: Text(
                    hasPlayed ? 'Completed' : 'Ready',
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todaySet != null) ...[
              Text(
                todaySet.categoryBreakdown.entries
                    .map((e) => '${e.key} ×${e.value}')
                    .join('  •  '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (hasPlayed && playedScore != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Score: $playedScore / 100',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, color: statusColor),
                ),
              ],
            ] else
              const Text('Generating today\'s set…'),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.set, required this.hasPlayed});

  final DailyChallengeSet set;
  final bool hasPlayed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: Icon(hasPlayed ? Icons.replay : Icons.play_arrow),
      label: Text(hasPlayed ? 'Play again' : 'Start today\'s set'),
      onPressed: () {
        Navigator.pushNamed(
          context,
          Routes.challenge,
          arguments: GameSession(set),
        );
      },
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.unlocked});

  final Set<String> unlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final badge in Badge.all) ...[
              Expanded(
                child: Tooltip(
                  message: unlocked.contains(badge.id)
                      ? '${badge.title} — ${badge.description}'
                      : 'Locked — ${badge.description}',
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: unlocked.contains(badge.id)
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      unlocked.contains(badge.id)
                          ? Icons.workspace_premium
                          : Icons.lock_outline,
                      color: unlocked.contains(badge.id)
                          ? scheme.primary
                          : scheme.outline,
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (badge != Badge.all.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${unlocked.length} of ${Badge.all.length} unlocked — details in Stats',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Central route table (kept here to avoid a separate file in a small app).
abstract final class Routes {
  static const String home = '/';
  static const String challenge = '/challenge';
  static const String results = '/results';
  static const String stats = '/stats';
  static const String settings = '/settings';
}