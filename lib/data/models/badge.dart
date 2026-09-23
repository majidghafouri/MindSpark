/// A milestone badge earned for reaching a consecutive-day streak.
class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredStreakDays,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredStreakDays;

  static const List<Badge> all = [
    Badge(
      id: 'beginner',
      title: 'Beginner',
      description: 'Complete your first daily challenge set.',
      icon: 'spark',
      requiredStreakDays: 1,
    ),
    Badge(
      id: 'trainee',
      title: 'Trainee',
      description: 'Score a 7-day streak.',
      icon: 'streak',
      requiredStreakDays: 7,
    ),
    Badge(
      id: 'master',
      title: 'Master',
      description: 'Score a 30-day streak.',
      icon: 'crown',
      requiredStreakDays: 30,
    ),
    Badge(
      id: 'elite',
      title: 'Elite',
      description: 'Score a 100-day streak.',
      icon: 'diamond',
      requiredStreakDays: 100,
    ),
  ];

  static Badge byId(String id) => all.firstWhere((b) => b.id == id);
}