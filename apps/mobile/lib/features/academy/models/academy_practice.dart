class AcademyPractice {
  final String id;
  final String lessonId;
  final String title;
  final String scenario;
  final List<AcademyPracticeOption> options;
  final int correctIndex;
  final String explanation;

  const AcademyPractice({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.scenario,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class AcademyPracticeOption {
  final String title;
  final String description;

  const AcademyPracticeOption({required this.title, required this.description});
}
