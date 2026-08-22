class AcademyProgress {
  final int completedLessons;
  final int totalLessons;
  final int practiceSessions;
  final int practicePoints;

  const AcademyProgress({
    required this.completedLessons,
    required this.totalLessons,
    required this.practiceSessions,
    required this.practicePoints,
  });

  double get completionPercentage {
    if (totalLessons == 0) {
      return 0;
    }

    return completedLessons / totalLessons;
  }
}
