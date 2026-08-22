import 'package:flutter/material.dart';

import '../data/academy_practice_content.dart';
import '../models/academy_practice.dart';

class AcademyPracticeScreen extends StatefulWidget {
  final AcademyPractice practice;

  const AcademyPracticeScreen({super.key, required this.practice});

  @override
  State<AcademyPracticeScreen> createState() => _AcademyPracticeScreenState();
}

class _AcademyPracticeScreenState extends State<AcademyPracticeScreen> {
  int? _selectedIndex;
  bool _answered = false;

  bool get _isCorrect => _selectedIndex == widget.practice.correctIndex;

  void _selectAnswer(int index) {
    if (_answered) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
  }

  void _tryAgain() {
    setState(() {
      _selectedIndex = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        children: [
          _PracticeHeader(primary: primary, title: widget.practice.title),

          const SizedBox(height: 18),

          _ScenarioCard(scenario: widget.practice.scenario),

          const SizedBox(height: 22),

          const Text(
            'What would you do?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...widget.practice.options.asMap().entries.map(
            (entry) => _AnswerOption(
              index: entry.key,
              option: entry.value,
              selectedIndex: _selectedIndex,
              correctIndex: widget.practice.correctIndex,
              answered: _answered,
              onTap: () => _selectAnswer(entry.key),
            ),
          ),

          if (_answered) ...[
            const SizedBox(height: 20),
            _ResultCard(
              correct: _isCorrect,
              explanation: widget.practice.explanation,
              primary: primary,
              onTryAgain: _tryAgain,
            ),
          ],
        ],
      ),
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  final Color primary;
  final String title;

  const _PracticeHeader({required this.primary, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Colors.deepPurple],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRACTICE MODE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.candlestick_chart_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'MARKET SCENARIO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(scenario, style: const TextStyle(fontSize: 15, height: 1.55)),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final int index;
  final AcademyPracticeOption option;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.index,
    required this.option,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
  });

  Color _borderColor() {
    if (!answered) {
      return Colors.grey.withValues(alpha: 0.18);
    }

    if (index == correctIndex) {
      return Colors.green;
    }

    if (index == selectedIndex) {
      return Colors.red;
    }

    return Colors.grey.withValues(alpha: 0.12);
  }

  Color _backgroundColor() {
    if (!answered) {
      return Colors.white;
    }

    if (index == correctIndex) {
      return Colors.green.withValues(alpha: 0.07);
    }

    if (index == selectedIndex) {
      return Colors.red.withValues(alpha: 0.07);
    }

    return Colors.white;
  }

  IconData _icon() {
    if (!answered) {
      return Icons.radio_button_unchecked_rounded;
    }

    if (index == correctIndex) {
      return Icons.check_circle_rounded;
    }

    if (index == selectedIndex) {
      return Icons.cancel_rounded;
    }

    return Icons.radio_button_unchecked_rounded;
  }

  Color _iconColor() {
    if (!answered) {
      return Colors.grey;
    }

    if (index == correctIndex) {
      return Colors.green;
    }

    if (index == selectedIndex) {
      return Colors.red;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor(),
          width: answered && (index == correctIndex || index == selectedIndex)
              ? 1.5
              : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: answered ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _iconColor().withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon(), color: _iconColor(), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final bool correct;
  final String explanation;
  final Color primary;
  final VoidCallback onTryAgain;

  const _ResultCard({
    required this.correct,
    required this.explanation,
    required this.primary,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.info_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                correct ? 'Correct!' : 'Not quite.',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(explanation, style: const TextStyle(fontSize: 14, height: 1.5)),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  correct ? Icons.stars_rounded : Icons.school_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  correct
                      ? '+10 Practice Points'
                      : 'Keep learning and try again',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (!correct) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}
