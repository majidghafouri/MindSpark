import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';

import '../../data/models/badge.dart';
import '../../data/models/day_result.dart';
import '../state/app_state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AppState>().progress;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    _StatCard(
                      label: 'Current streak',
                      value: '${progress.streak.current}',
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Best streak',
                      value: '${progress.streak.longest}',
                      icon: Icons.trending_up,
                      color: scheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      label: 'Days played',
                      value: '${progress.stats.daysPlayed}',
                      icon: Icons.calendar_month,
                      color: scheme.tertiary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Avg score',
                      value: '${progress.stats.averageScore}',
                      icon: Icons.insights,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _RecentResults(results: progress.dayResults),
                const SizedBox(height: 8),
                _BadgeGrid(unlocked: progress.unlockedBadgeIds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentResults extends StatelessWidget {
  const _RecentResults({required this.results});

  final List<DayResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.sports_score_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No games yet.\nComplete today\'s set to see your history.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    final recent = results.reversed.take(7).toList();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Recent days',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final result in recent)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(result.date.day.toString().padLeft(2, '0')),
              subtitle: Text('${result.correctCount}/5 correct'),
              trailing: Text(
                '${result.score}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.unlocked});

  final Set<String> unlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badges',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final badge in Badge.all)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: unlocked.contains(badge.id)
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  child: Icon(
                    unlocked.contains(badge.id)
                        ? Icons.workspace_premium
                        : Icons.lock_outline,
                    color: unlocked.contains(badge.id)
                        ? scheme.primary
                        : scheme.outline,
                  ),
                ),
                title: Text(
                  badge.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: unlocked.contains(badge.id)
                        ? null
                        : scheme.outline,
                  ),
                ),
                subtitle: Text(
                  badge.description,
                  style: TextStyle(
                    color: unlocked.contains(badge.id)
                        ? null
                        : scheme.outline,
                  ),
                ),
                trailing: unlocked.contains(badge.id)
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Text('${badge.requiredStreakDays}d'),
              ),
          ],
        ),
      ),
    );
  }
}