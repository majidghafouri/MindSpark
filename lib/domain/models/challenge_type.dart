/// The kind of challenge a player faces.
///
/// Each type maps to a distinct question-rendering widget and a category
/// used for score breakdowns.
enum ChallengeType {
  sequence('numbers', 'Number Sequence'),
  oddOneOut('logic', 'Logic'),
  attention('attention', 'Attention');

  const ChallengeType(this.category, this.label);

  /// Category used for score breakdowns (e.g. "Logic 90").
  final String category;

  /// Human readable label.
  final String label;
}