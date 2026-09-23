import 'package:flutter/material.dart';

import '../../domain/models/challenge.dart';
import 'answer_option.dart';

/// Renders a number-sequence challenge: prompt on top, big number pads below.
class SequenceQuestionView extends StatelessWidget {
  const SequenceQuestionView({
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
        const SizedBox(height: 28),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            for (var i = 0; i < challenge.options.length; i++)
              AnswerOption(
                label: challenge.options[i],
                index: i,
                answered: answered,
                isSelected: selectedIndex == i,
                isCorrect: challenge.isCorrect(i),
                prominent: true,
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ],
    );
  }
}