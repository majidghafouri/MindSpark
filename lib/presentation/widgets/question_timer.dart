import 'package:flutter/material.dart';

/// Non-punitive visual countdown. Depletes to zero and stops; it never
/// blocks interaction or fails the player.
class QuestionTimer extends StatelessWidget {
  const QuestionTimer({
    super.key,
    required this.secondsLeft,
    required this.maxSeconds,
  });

  final int secondsLeft;
  final int maxSeconds;

  @override
  Widget build(BuildContext context) {
    final fraction = maxSeconds <= 0 ? 0.0 : (secondsLeft / maxSeconds).clamp(0.0, 1.0);
    final urgent = fraction < 0.25;
    final color = urgent ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              color: color,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$secondsLeft',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ),
      ],
    );
  }
}