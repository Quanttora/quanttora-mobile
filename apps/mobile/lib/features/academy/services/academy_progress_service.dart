import 'package:shared_preferences/shared_preferences.dart';

class AcademyProgressService {
  static const String _completedLessonsKey = 'academy_completed_lessons';

  static const String _practiceSessionsKey = 'academy_practice_sessions';

  static const String _practicePointsKey = 'academy_practice_points';

  /// Returns all lesson IDs completed by the user.
  static Future<Set<String>> getCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();

    final lessons = prefs.getStringList(_completedLessonsKey) ?? <String>[];

    return lessons.toSet();
  }

  /// Marks a lesson as completed.
  ///
  /// If the lesson was already completed, nothing changes.
  static Future<bool> completeLesson(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();

    final lessons = prefs.getStringList(_completedLessonsKey) ?? <String>[];

    if (lessons.contains(lessonId)) {
      return false;
    }

    lessons.add(lessonId);

    await prefs.setStringList(_completedLessonsKey, lessons);

    return true;
  }

  /// Checks whether a specific lesson is completed.
  static Future<bool> isLessonCompleted(String lessonId) async {
    final completedLessons = await getCompletedLessons();

    return completedLessons.contains(lessonId);
  }

  /// Returns the number of completed lessons.
  static Future<int> getCompletedLessonCount() async {
    final completedLessons = await getCompletedLessons();

    return completedLessons.length;
  }

  /// Returns the number of practice sessions completed.
  static Future<int> getPracticeSessions() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_practiceSessionsKey) ?? 0;
  }

  /// Adds one completed practice session.
  static Future<void> addPracticeSession() async {
    final prefs = await SharedPreferences.getInstance();

    final current = prefs.getInt(_practiceSessionsKey) ?? 0;

    await prefs.setInt(_practiceSessionsKey, current + 1);
  }

  /// Returns the user's total practice points.
  static Future<int> getPracticePoints() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_practicePointsKey) ?? 0;
  }

  /// Adds practice points to the user's Academy score.
  static Future<void> addPracticePoints(int points) async {
    if (points <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final current = prefs.getInt(_practicePointsKey) ?? 0;

    await prefs.setInt(_practicePointsKey, current + points);
  }

  /// Clears Academy progress.
  ///
  /// Useful during development/testing.
  /// We will NOT expose this in the UI yet.
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_completedLessonsKey);
    await prefs.remove(_practiceSessionsKey);
    await prefs.remove(_practicePointsKey);
  }
}
