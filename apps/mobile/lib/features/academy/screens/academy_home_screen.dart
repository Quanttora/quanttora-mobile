import 'package:flutter/material.dart';

import '../data/academy_content.dart';
import '../models/academy_lesson.dart';
import '../models/academy_progress.dart';
import '../widgets/academy_progress_card.dart';
import 'academy_lesson_screen.dart';

class AcademyHomeScreen extends StatelessWidget {
  const AcademyHomeScreen({super.key});

  void _openCategory(BuildContext context, AcademyCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademyLessonScreen(category: category),
      ),
    );
  }

  int _totalLessons() {
    return academyCategories.fold(
      0,
      (total, category) => total + category.lessons.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final totalLessons = _totalLessons();

    const progress = AcademyProgress(
      completedLessons: 0,
      totalLessons: 0,
      practiceSessions: 0,
      practicePoints: 0,
    );

    final academyProgress = AcademyProgress(
      completedLessons: progress.completedLessons,
      totalLessons: totalLessons,
      practiceSessions: progress.practiceSessions,
      practicePoints: progress.practicePoints,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trading Academy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        children: [
          _AcademyHero(
            primary: primary,
            totalLessons: totalLessons,
            totalPaths: academyCategories.length,
          ),

          const SizedBox(height: 20),

          const _SectionTitle(
            title: 'Your Learning',
            subtitle: 'Build knowledge before putting capital at risk.',
          ),

          const SizedBox(height: 12),

          AcademyProgressCard(progress: academyProgress),

          const SizedBox(height: 24),

          const _SectionTitle(
            title: 'Learning Paths',
            subtitle: 'Choose a path and learn step by step.',
          ),

          const SizedBox(height: 14),

          ...academyCategories.asMap().entries.map(
            (entry) => _CategoryCard(
              category: entry.value,
              index: entry.key,
              onTap: () => _openCategory(context, entry.value),
            ),
          ),

          const SizedBox(height: 14),

          _AcademyPrincipleCard(primary: primary),
        ],
      ),
    );
  }
}

class _AcademyHero extends StatelessWidget {
  final Color primary;
  final int totalLessons;
  final int totalPaths;

  const _AcademyHero({
    required this.primary,
    required this.totalLessons,
    required this.totalPaths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.72), Colors.deepPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Learn. Practice.\nTrade with discipline.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Build your trading knowledge one concept at a time.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _HeroStat(value: '$totalLessons', label: 'Lessons'),
              const SizedBox(width: 26),
              _HeroStat(value: '$totalPaths', label: 'Paths'),
              const SizedBox(width: 26),
              const _HeroStat(value: '∞', label: 'Practice'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AcademyCategory category;
  final VoidCallback onTap;
  final int index;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.index,
  });

  IconData _icon(String id) {
    switch (id) {
      case 'candlesticks':
        return Icons.candlestick_chart_rounded;
      case 'volume':
        return Icons.bar_chart_rounded;
      case 'indicators':
        return Icons.analytics_rounded;
      case 'market-basics':
        return Icons.public_rounded;
      case 'risk-management':
        return Icons.shield_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'strategy':
        return Icons.track_changes_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _color(BuildContext context) {
    switch (category.id) {
      case 'candlesticks':
        return Colors.orange;
      case 'volume':
        return Colors.blue;
      case 'indicators':
        return Colors.deepPurple;
      case 'market-basics':
        return Colors.teal;
      case 'risk-management':
        return Colors.red;
      case 'psychology':
        return Colors.pink;
      case 'strategy':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _level() {
    if (index <= 1) {
      return 'BEGINNER';
    }

    if (index <= 3) {
      return 'INTERMEDIATE';
    }

    return 'ADVANCED';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_icon(category.id), color: color, size: 28),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  category.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _level(),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Text(
                            category.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const LinearProgressIndicator(
                          value: 0,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '${category.lessons.length} lessons',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcademyPrincipleCard extends StatelessWidget {
  final Color primary;

  const _AcademyPrincipleCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: primary, size: 27),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quanttora Principle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Knowledge is only the first step. Learn the concept, understand the risk, practice the setup, and then decide whether a trade deserves your capital.',
                  style: TextStyle(fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
