import 'package:flutter/material.dart';

import '../data/academy_practice_content.dart';
import '../models/academy_lesson.dart';
import '../models/academy_practice.dart';
import '../services/academy_progress_service.dart';
import '../widgets/academy_lesson_card.dart';
import 'academy_practice_screen.dart';

class AcademyLessonScreen extends StatelessWidget {
  final AcademyCategory category;

  const AcademyLessonScreen({super.key, required this.category});

  void _openLesson(BuildContext context, AcademyLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LessonDetailScreen(category: category, lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Text(
            category.subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
          const SizedBox(height: 20),
          ...category.lessons.map(
            (lesson) => AcademyLessonCard(
              lesson: lesson,
              onTap: () => _openLesson(context, lesson),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonDetailScreen extends StatefulWidget {
  final AcademyCategory category;
  final AcademyLesson lesson;

  const _LessonDetailScreen({required this.category, required this.lesson});

  @override
  State<_LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<_LessonDetailScreen> {
  bool _isCompleted = false;
  bool _isLoadingProgress = true;

  AcademyPractice? _practiceForLesson() {
    for (final practice in academyPractices) {
      if (practice.lessonId == widget.lesson.id) {
        return practice;
      }
    }

    return null;
  }

  Future<void> _loadProgress() async {
    final completed = await AcademyProgressService.isLessonCompleted(
      widget.lesson.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isCompleted = completed;
      _isLoadingProgress = false;
    });
  }

  Future<void> _completeLesson() async {
    if (_isCompleted) {
      return;
    }

    final saved = await AcademyProgressService.completeLesson(widget.lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Lesson completed! Your Academy progress has been updated.'
              : 'This lesson is already completed.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPractice(BuildContext context, AcademyPractice practice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademyPracticeScreen(practice: practice),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final practice = _practiceForLesson();

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        children: [
          _LessonHeader(lesson: widget.lesson),

          const SizedBox(height: 20),

          _LessonVisual(lessonId: widget.lesson.id),

          const SizedBox(height: 26),

          const Text(
            'What you should know',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          ...widget.lesson.sections.asMap().entries.map(
            (entry) =>
                _KnowledgePoint(number: entry.key + 1, text: entry.value),
          ),

          const SizedBox(height: 18),

          if (practice != null) ...[
            _PracticeButton(
              practice: practice,
              onTap: () => _openPractice(context, practice),
            ),
            const SizedBox(height: 18),
          ],

          _CompletionButton(
            isCompleted: _isCompleted,
            isLoading: _isLoadingProgress,
            onTap: _completeLesson,
          ),

          const SizedBox(height: 20),

          _QuanttoraTakeaway(lessonId: widget.lesson.id),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final AcademyLesson lesson;

  const _LessonHeader({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.icon, style: const TextStyle(fontSize: 38)),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeButton extends StatelessWidget {
  final AcademyPractice practice;
  final VoidCallback onTap;

  const _PracticeButton({required this.practice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Practice This Lesson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        practice.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final bool isLoading;
  final VoidCallback onTap;

  const _CompletionButton({
    required this.isCompleted,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (isLoading) {
      return Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return Material(
      color: isCompleted
          ? Colors.green.withValues(alpha: 0.10)
          : primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.flag_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Lesson Completed' : 'Mark Lesson Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Great work! Your progress has been saved.'
                          : 'Finished learning this lesson? Save your progress.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isCompleted
                    ? Icons.verified_rounded
                    : Icons.arrow_forward_rounded,
                color: isCompleted ? Colors.green : primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnowledgePoint extends StatelessWidget {
  final int number;
  final String text;

  const _KnowledgePoint({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuanttoraTakeaway extends StatelessWidget {
  final String lessonId;

  const _QuanttoraTakeaway({required this.lessonId});

  String get _message {
    switch (lessonId) {
      case 'candle-basics':
        return 'Read the candle from left to right: open, high, low and close. The candle gives you a compact view of the battle between buyers and sellers.';

      case 'bullish-bearish':
        return 'A single bullish or bearish candle is not enough. Always consider where the candle appears and what the surrounding price action is doing.';

      case 'candle-patterns':
        return 'Patterns are signals of behaviour, not guaranteed outcomes. Confirm them with market structure, price action and volume.';

      case 'volume-basics':
        return 'Volume tells you how much participation is behind a move. Compare the current bar with recent volume rather than judging it alone.';

      case 'volume-price':
        return 'Price tells you where the market moved. Volume helps you understand how much participation supported that move.';

      case 'ema':
        return 'EMA can help identify directional momentum, but it should work together with price action and other confirmations.';

      case 'vwap':
        return 'VWAP provides an intraday reference for average traded price. Use it as context rather than as an automatic buy or sell signal.';

      case 'rsi':
        return 'RSI measures momentum. A high or low reading does not automatically mean price must reverse.';

      default:
        return 'Learn the concept first, understand the context, and only then apply it as part of a complete trading plan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quanttora Takeaway',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _message,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonVisual extends StatelessWidget {
  final String lessonId;

  const _LessonVisual({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    switch (lessonId) {
      case 'candle-basics':
        return const _CandlestickBasicsVisual();

      case 'bullish-bearish':
        return const _BullishBearishVisual();

      case 'candle-patterns':
        return const _CandlePatternsVisual();

      case 'volume-basics':
      case 'volume-price':
        return const _VolumeVisual();

      case 'ema':
        return const _EmaVisual();

      case 'vwap':
        return const _VwapVisual();

      case 'rsi':
        return const _RsiVisual();

      default:
        return const _ConceptVisual();
    }
  }
}

class _VisualCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _VisualCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _CandlestickBasicsVisual extends StatelessWidget {
  const _CandlestickBasicsVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'Anatomy of a Candlestick',
      subtitle: 'A candle shows open, high, low and close.',
      child: SizedBox(
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 5, child: _ChartLabel(text: 'HIGH')),
            Positioned(top: 42, child: _Candle(bullish: true, height: 130)),
            Positioned(top: 48, left: 20, child: _SideLabel(text: 'Open')),
            Positioned(top: 122, left: 20, child: _SideLabel(text: 'Body')),
            Positioned(top: 177, left: 20, child: _SideLabel(text: 'Close')),
            Positioned(bottom: 5, child: _ChartLabel(text: 'LOW')),
          ],
        ),
      ),
    );
  }
}

class _BullishBearishVisual extends StatelessWidget {
  const _BullishBearishVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'Bullish vs Bearish',
      subtitle:
          'The candle colour represents the relationship between open and close.',
      child: Row(
        children: [
          Expanded(
            child: _CandleExplanation(
              title: 'BULLISH',
              bullish: true,
              description: 'Close is above Open',
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: _CandleExplanation(
              title: 'BEARISH',
              bullish: false,
              description: 'Close is below Open',
            ),
          ),
        ],
      ),
    );
  }
}

class _CandleExplanation extends StatelessWidget {
  final String title;
  final bool bullish;
  final String description;

  const _CandleExplanation({
    required this.title,
    required this.bullish,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = bullish ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 12),
          _Candle(bullish: bullish, height: 110),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CandlePatternsVisual extends StatelessWidget {
  const _CandlePatternsVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'Important Candle Patterns',
      subtitle: 'Common patterns include Doji, Hammer and Shooting Star.',
      child: Row(
        children: [
          Expanded(
            child: _PatternCard(
              title: 'DOJI',
              subtitle: 'Indecision',
              type: 'doji',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _PatternCard(
              title: 'HAMMER',
              subtitle: 'Lower rejection',
              type: 'hammer',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _PatternCard(
              title: 'SHOOTING STAR',
              subtitle: 'Upper rejection',
              type: 'shooting',
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;

  const _PatternCard({
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _PatternPainter(type: type),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _VolumeVisual extends StatelessWidget {
  const _VolumeVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'Price + Volume',
      subtitle: 'Volume helps show participation behind price movement.',
      child: SizedBox(height: 220, child: _VolumeChart()),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  const _VolumeChart();

  @override
  Widget build(BuildContext context) {
    final bars = <double>[55, 80, 45, 110, 72, 145, 95, 165];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: bars
          .map(
            (height) => Container(
              width: 22,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.65),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmaVisual extends StatelessWidget {
  const _EmaVisual();

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      title: 'EMA and Price',
      subtitle: 'EMA follows price and helps identify directional momentum.',
      child: SizedBox(
        height: 220,
        child: CustomPaint(
          painter: _EmaPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _VwapVisual extends StatelessWidget {
  const _VwapVisual();

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      title: 'Price vs VWAP',
      subtitle: 'VWAP acts as an intraday reference price.',
      child: SizedBox(
        height: 220,
        child: CustomPaint(
          painter: _VwapPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RsiVisual extends StatelessWidget {
  const _RsiVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'RSI Momentum',
      subtitle: 'RSI is commonly displayed on a 0-100 scale.',
      child: SizedBox(height: 180, child: _RsiGauge()),
    );
  }
}

class _ConceptVisual extends StatelessWidget {
  const _ConceptVisual();

  @override
  Widget build(BuildContext context) {
    return const _VisualCard(
      title: 'Trading Concept',
      subtitle: 'Understand the idea before applying it.',
      child: SizedBox(
        height: 150,
        child: Center(
          child: Icon(
            Icons.auto_graph_rounded,
            size: 80,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}

class _Candle extends StatelessWidget {
  final bool bullish;
  final double height;

  const _Candle({required this.bullish, required this.height});

  @override
  Widget build(BuildContext context) {
    final color = bullish ? Colors.green : Colors.red;

    return SizedBox(
      width: 70,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 3, height: height, color: color),
          Container(
            width: 34,
            height: height * 0.48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;

  const _ChartLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _SideLabel extends StatelessWidget {
  final String text;

  const _SideLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final String type;

  _PatternPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final wickPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final bodyPaint = Paint()..style = PaintingStyle.fill;

    if (type == 'doji') {
      wickPaint.color = Colors.grey.shade700;
      bodyPaint.color = Colors.grey.shade700;

      canvas.drawLine(Offset(centerX, 10), Offset(centerX, 110), wickPaint);

      canvas.drawRect(
        Rect.fromCenter(center: Offset(centerX, 60), width: 34, height: 4),
        bodyPaint,
      );
    } else if (type == 'hammer') {
      wickPaint.color = Colors.green;
      bodyPaint.color = Colors.green;

      canvas.drawLine(Offset(centerX, 15), Offset(centerX, 110), wickPaint);

      canvas.drawRect(
        Rect.fromCenter(center: Offset(centerX, 45), width: 30, height: 34),
        bodyPaint,
      );
    } else {
      wickPaint.color = Colors.red;
      bodyPaint.color = Colors.red;

      canvas.drawLine(Offset(centerX, 10), Offset(centerX, 110), wickPaint);

      canvas.drawRect(
        Rect.fromCenter(center: Offset(centerX, 78), width: 30, height: 34),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

class _EmaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pricePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final emaPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final price = Path();

    price.moveTo(0, size.height * 0.75);

    price.cubicTo(
      size.width * 0.18,
      size.height * 0.60,
      size.width * 0.32,
      size.height * 0.72,
      size.width * 0.48,
      size.height * 0.45,
    );

    price.cubicTo(
      size.width * 0.65,
      size.height * 0.18,
      size.width * 0.82,
      size.height * 0.48,
      size.width,
      size.height * 0.18,
    );

    final ema = Path();

    ema.moveTo(0, size.height * 0.68);

    ema.cubicTo(
      size.width * 0.20,
      size.height * 0.64,
      size.width * 0.35,
      size.height * 0.58,
      size.width * 0.50,
      size.height * 0.48,
    );

    ema.cubicTo(
      size.width * 0.68,
      size.height * 0.40,
      size.width * 0.84,
      size.height * 0.30,
      size.width,
      size.height * 0.25,
    );

    canvas.drawPath(price, pricePaint);

    canvas.drawPath(ema, emaPaint);

    _drawLegend(canvas, size, Colors.blue, 'Price', 0);

    _drawLegend(canvas, size, Colors.deepPurple, 'EMA', 1);
  }

  void _drawLegend(
    Canvas canvas,
    Size size,
    Color color,
    String label,
    int index,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;

    final x = 10.0;
    final y = 12.0 + (index * 22.0);

    canvas.drawLine(Offset(x, y), Offset(x + 20, y), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(x + 28, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _EmaPainter oldDelegate) {
    return false;
  }
}

class _VwapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pricePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final vwapPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final price = Path();

    price.moveTo(0, size.height * 0.65);

    price.cubicTo(
      size.width * 0.17,
      size.height * 0.53,
      size.width * 0.30,
      size.height * 0.72,
      size.width * 0.42,
      size.height * 0.38,
    );

    price.cubicTo(
      size.width * 0.56,
      size.height * 0.10,
      size.width * 0.76,
      size.height * 0.56,
      size.width,
      size.height * 0.20,
    );

    final vwap = Path();

    vwap.moveTo(0, size.height * 0.58);

    vwap.cubicTo(
      size.width * 0.20,
      size.height * 0.56,
      size.width * 0.35,
      size.height * 0.51,
      size.width * 0.50,
      size.height * 0.45,
    );

    vwap.cubicTo(
      size.width * 0.67,
      size.height * 0.40,
      size.width * 0.83,
      size.height * 0.34,
      size.width,
      size.height * 0.28,
    );

    canvas.drawPath(price, pricePaint);

    canvas.drawPath(vwap, vwapPaint);

    _drawLegend(canvas, size, Colors.blue, 'Price', 0);

    _drawLegend(canvas, size, Colors.orange, 'VWAP', 1);
  }

  void _drawLegend(
    Canvas canvas,
    Size size,
    Color color,
    String label,
    int index,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;

    final x = 10.0;
    final y = 12.0 + (index * 22.0);

    canvas.drawLine(Offset(x, y), Offset(x + 20, y), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(x + 28, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _VwapPainter oldDelegate) {
    return false;
  }
}

class _RsiGauge extends StatelessWidget {
  const _RsiGauge();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '30',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('50', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '70',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('100', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),
        Stack(
          children: [
            Container(
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 58,
              top: -3,
              child: Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Example RSI: 58',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
