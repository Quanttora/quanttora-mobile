class AcademyLesson {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<String> sections;

  const AcademyLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.sections,
  });
}

class AcademyCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final List<AcademyLesson> lessons;

  const AcademyCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lessons,
  });
}
