import 'package:flutter/material.dart';

import '../../domain/models/challenge.dart';
import 'answer_option.dart';

/// Renders logic and attention challenges as a selectable list of options.
class OptionListQuestionView extends StatelessWidget {
  const OptionListQuestionView({
    super.key,
    required this.challenge,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
  });

  final Challenge challenge;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          challenge.prompt,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4),
        ),
        // The attention prompt embeds the string on its own line already, so
        // relax spacing for long prompts.
        const SizedBox(height: 24),
        for (var i = 0; i < challenge.options.length; i++) ...[
          AnswerOption(
            label: challenge.options[i],
            index: i,
            answered: answered,
            isSelected: selectedIndex == i,
            isCorrect: challenge.isCorrect(i),
            onTap: () => onSelect(i),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}