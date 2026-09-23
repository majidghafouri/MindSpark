import 'package:flutter/material.dart';

import '../../data/models/day_result.dart';
import '../../services/ads_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.result});

  final DayResult result;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _score = 0;
  bool _bonusApplied = false;
  bool _wasAdSeen = false;

  @override
  void initState() {
    super.initState();
    _score = widget.result.score;
    AdsService.instance.preloadRewarded();
  }

  Future<void> _watchAd() async {
    if (_bonusApplied) return;
    await AdsService.instance.showRewarded(
      onReward: () {
        if (!mounted) return;
        setState(() {
          _bonusApplied = true;
          // Flat bonus XP, capped at 100 — never forced, pure upside.
          _score = (_score + 10).clamp(0, 100);
        });
      },
      onDismissed: () {},
    );
    if (mounted) setState(() => _wasAdSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _ScoreCircle(score: _score, scheme: scheme),
                  const SizedBox(height: 16),
                  Text(
                    _bonusApplied ? 'XP boosted!' : 'Nice work today',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${result.correctCount} of 5 correct',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'By category',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in result.categoryScores.entries) ...[
                    _CategoryBar(
                      category: entry.key,
                      score: entry.value,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (!_bonusApplied &&
                      AdsService.instance.isRewardedReady) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Watch an ad for bonus XP'),
                      onPressed: _watchAd,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optional. Skip it — your score is already saved.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ] else if (_wasAdSeen && !_bonusApplied) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ad unavailable — no worries, your score already counts.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score, required this.scheme});

  final int score;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = score >= 90
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : scheme.error;
    return Container(
      width: 160,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          Text(
            '/ 100',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.score,
    required this.scheme,
  });

  final String category;
  final int score;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(category, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}