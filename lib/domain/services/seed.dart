/// Deterministic seeding helpers so the same calendar day always yields the
/// same challenge set (important for shareability and fair comparison).
library;

/// Normalizes [date] to midnight before deriving the daily seed.
DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

/// A stable per-day seed derived from the calendar date.
int dateSeed(DateTime date) {
  final day = normalizeDate(date);
  return day.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

/// Mixes the daily seed with per-challenge position/type values so different
/// challenges in a day don't collide, while remaining fully deterministic.
int challengeSeed(int base, int partA, int partB, int partC) {
  return base * 7919 + partA * 17 + partB * 101 + partC * 7;
}