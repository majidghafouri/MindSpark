import 'package:flutter/material.dart';

import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_type.dart';
import 'sequence_question_view.dart';
import 'option_list_question_view.dart';

/// Chooses the right renderer for a challenge based on its type.
class ChallengeQuestionView extends StatelessWidget {
  const ChallengeQuestionView({
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
    switch (challenge.type) {
      case ChallengeType.sequence:
        return SequenceQuestionView(
          challenge: challenge,
          selectedIndex: selectedIndex,
          answered: answered,
          onSelect: onSelect,
        );
      case ChallengeType.oddOneOut:
      case ChallengeType.attention:
        return OptionListQuestionView(
          challenge: challenge,
          selectedIndex: selectedIndex,
          answered: answered,
          onSelect: onSelect,
        );
    }
  }
}