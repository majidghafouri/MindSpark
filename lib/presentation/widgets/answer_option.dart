import 'package:flutter/material.dart';

/// A tappable answer option. Once answered, it highlights green if it was the
/// correct answer, red if the player picked a wrong one, and dims the rest.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.answered,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    this.prominent = false,
  });

  final String label;
  final int index;
  final bool answered;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color? background;
    Color? border;
    IconData? icon;
    if (answered) {
      if (isCorrect) {
        background = Colors.green.withValues(alpha: 0.18);
        border = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected) {
        background = scheme.errorContainer;
        border = scheme.error;
        icon = Icons.cancel;
      } else {
        background = scheme.surfaceContainerHighest.withValues(alpha: 0.5);
      }
    } else if (isSelected) {
      background = scheme.primaryContainer;
      border = scheme.primary;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!prominent) ...[
          CircleAvatar(
            radius: 15,
            backgroundColor:
                answered ? (isCorrect ? Colors.green : scheme.errorContainer) : scheme.primary,
            child: Text(
              String.fromCharCode(65 + index),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: answered && !isCorrect ? scheme.onErrorContainer : scheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: prominent ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: prominent || isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: isCorrect ? Colors.green : scheme.error),
        ],
      ],
    );

    return Material(
      color: background ?? scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('option-$index'),
        borderRadius: BorderRadius.circular(14),
        onTap: answered ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: border != null
                ? Border.all(color: border, width: 1.8)
                : Border.all(color: Colors.transparent),
          ),
          child: prominent
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            )),
                  ],
                )
              : content,
        ),
      ),
    );
  }
}