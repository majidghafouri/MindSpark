import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/day_result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/daily_challenge_set.dart';

/// Drives a single run through today's 5 challenges.
///
/// The timer is deliberately non-punitive: it depletes visually and just
/// sticks at zero. It never blocks answering or fails the player.
class GameSession extends ChangeNotifier {
  GameSession(this._set) {
    _selections = List<int?>.filled(_set.challenges.length, null);
    _startTimerForCurrent();
  }

  final DailyChallengeSet _set;
  final ScoreCalculator _score = const ScoreCalculator();

  int _index = 0;
  int? _selected;
  bool _answered = false;
  List<int?> _selections = const [];
  int _timeLeft = 0;
  Timer? _timer;

  List<Challenge> get challenges => _set.challenges;
  Challenge get current => _set.challenges[_index];
  int get index => _index;
  int get total => _set.challenges.length;
  bool get isAnswered => _answered;
  int? get selectedIndex => _selected;
  int get timeLeft => _timeLeft;
  bool get isDone => _index >= total;
  DailyChallengeSet get set => _set;

  void selectOption(int optionIndex) {
    if (_answered) return;
    _selected = optionIndex;
    _answered = true;
    _timer?.cancel();
    notifyListeners();
  }

  void next() {
    if (!_answered) return;
    _selections[_index] = _selected;
    _index += 1;
    _selected = null;
    _answered = false;
    if (!isDone) {
      _startTimerForCurrent();
    }
    notifyListeners();
  }

  List<int?> get selections => List.unmodifiable(_selections);

  DayResult resultAt(DateTime completedAt) =>
      _score.computeForSet(_set, _selections, completedAt);

  void _startTimerForCurrent() {
    _timer?.cancel();
    _timeLeft = current.difficulty.timeLimitSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_answered) {
        _timeLeft = _timeLeft > 0 ? _timeLeft - 1 : 0;
        if (_timeLeft == 0) {
          _timer?.cancel();
        }
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}