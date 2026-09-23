import 'package:flutter_test/flutter_test.dart';
import 'package:nevermindspark/data/models/streak_calculator.dart';

void main() {
  const calculator = StreakCalculator();
  final today = DateTime(2026, 9, 23);

  String key(int month, int day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '2026-${two(month)}-${two(day)}';
  }

  test('empty history -> zero streaks', () {
    final info = calculator.compute(completedDayKeys: [], today: today);
    expect(info.current, 0);
    expect(info.longest, 0);
    expect(info.lastPlayedDayKey, isNull);
  });

  test('played today only -> streak of 1', () {
    final info =
        calculator.compute(completedDayKeys: [key(9, 23)], today: today);
    expect(info.current, 1);
    expect(info.longest, 1);
  });

  test('played yesterday only -> streak still live at 1', () {
    final info =
        calculator.compute(completedDayKeys: [key(9, 22)], today: today);
    expect(info.current, 1);
    expect(info.longest, 1);
  });

  test('three consecutive days ending today -> streak of 3', () {
    final info = calculator.compute(
      completedDayKeys: [key(9, 21), key(9, 22), key(9, 23)],
      today: today,
    );
    expect(info.current, 3);
    expect(info.longest, 3);
  });

  test('missed day breaks current streak but keeps longest', () {
    final info = calculator.compute(
      completedDayKeys: [key(9, 20), key(9, 21), key(9, 23)],
      today: today,
    );
    // 9/23 is today: single day (the 9/20-21 run was broken by 9/22).
    expect(info.current, 1);
    expect(info.longest, 2);
  });

  test('last played several days ago -> current resets to 0, longest kept', () {
    final info = calculator.compute(
      completedDayKeys: [key(9, 1), key(9, 2), key(9, 20), key(9, 21)],
      today: today,
    );
    expect(info.current, 0);
    expect(info.longest, 2);
  });

  test('only counts consecutive non-repeat keys', () {
    final info = calculator.compute(
      completedDayKeys: [key(9, 23), key(9, 23), key(9, 22), key(9, 21)],
      today: today,
    );
    expect(info.current, 3);
  });
}