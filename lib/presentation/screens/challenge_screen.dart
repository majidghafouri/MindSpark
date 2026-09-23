import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/game_session.dart';
import '../widgets/challenge_question_view.dart';
import '../widgets/question_timer.dart';
import 'home_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _recording = false;

  @override
  void dispose() {
    widget.session.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final session = widget.session;
    if (!session.isDone) return;
    if (_recording) return;
    _recording = true;
    final appState = context.read<AppState>();
    final result = await appState.recordResult(session.selections);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      Routes.results,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        final session = widget.session;
        if (session.isDone) {
          // Final question answered: record + redirect happens in _finish().
          // Until then, render nothing rather than reading past the list.
          return const Scaffold(body: SizedBox.shrink());
        }
        final challenge = session.current;

        return Scaffold(
          appBar: AppBar(
            title: _ProgressDots(
              index: session.index,
              total: session.total,
            ),
            leading: BackButton(onPressed: () => _confirmQuit(context)),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            avatar: Icon(
                              _categoryIcon(challenge.type.name),
                              size: 16,
                            ),
                            label: Text(challenge.type.label),
                          ),
                          Text(
                            '${challenge.difficulty.label} • '
                            '${challenge.difficulty.points} pts',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      QuestionTimer(
                        secondsLeft: session.timeLeft,
                        maxSeconds: challenge.difficulty.timeLimitSeconds,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ChallengeQuestionView(
                            challenge: challenge,
                            selectedIndex: session.selectedIndex,
                            answered: session.isAnswered,
                            onSelect: session.selectOption,
                          ),
                        ),
                      ),
                      if (session.isAnswered) ...[
                        const SizedBox(height: 12),
                        _FeedbackCard(
                          correct: session.selectedIndex == challenge.answerIndex,
                          explanation: challenge.explanation,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            session.next();
                            if (session.isDone) {
                              _finish();
                            }
                          },
                          child: Text(session.index >= session.total - 1
                              ? 'See results'
                              : 'Next question'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit the challenge?'),
        content: const Text('Your progress on today\'s set will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 22,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i < index
                  ? scheme.primary
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.correct, required this.explanation});

  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        correct ? Colors.green.withValues(alpha: 0.16) : scheme.errorContainer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Correct!' : 'Not quite',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(explanation, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String typeName) {
  switch (typeName) {
    case 'sequence':
      return Icons.numbers;
    case 'oddOneOut':
      return Icons.psychology_outlined;
    default:
      return Icons.visibility_outlined;
  }
}