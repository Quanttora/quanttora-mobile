import '../models/academy_practice.dart';

const academyPractices = <AcademyPractice>[
  AcademyPractice(
    id: 'practice-bullish-breakout',
    lessonId: 'bullish-bearish',
    title: 'Identify the Candle',
    scenario:
        'A candle opens at 22,450 and closes at 22,485. '
        'During the same period, price reaches a high of 22,500 '
        'and a low of 22,430.',
    options: [
      AcademyPracticeOption(
        title: 'Bullish candle',
        description: 'Close is above the open.',
      ),
      AcademyPracticeOption(
        title: 'Bearish candle',
        description: 'Close is below the open.',
      ),
      AcademyPracticeOption(
        title: 'Doji',
        description: 'Open and close are almost the same.',
      ),
    ],
    correctIndex: 0,
    explanation:
        'Correct. The candle opened at 22,450 and closed at 22,485, '
        'so the close is above the open. This makes it a bullish candle.',
  ),

  AcademyPractice(
    id: 'practice-volume-breakout',
    lessonId: 'volume-price',
    title: 'Breakout + Volume',
    scenario:
        'A stock breaks above a recent resistance level. '
        'At the same time, trading volume is significantly higher '
        'than the recent average.',
    options: [
      AcademyPracticeOption(
        title: 'Ignore volume',
        description: 'Only price matters.',
      ),
      AcademyPracticeOption(
        title: 'Treat it as useful confirmation',
        description: 'Higher participation can support the breakout.',
      ),
      AcademyPracticeOption(
        title: 'Enter without a stop-loss',
        description: 'High volume guarantees the trade.',
      ),
    ],
    correctIndex: 1,
    explanation:
        'Correct. A breakout accompanied by stronger participation '
        'can provide useful confirmation. However, volume does not '
        'guarantee that the breakout will succeed, so risk management '
        'is still required.',
  ),

  AcademyPractice(
    id: 'practice-vwap',
    lessonId: 'vwap',
    title: 'Price vs VWAP',
    scenario:
        'NIFTY is trading above VWAP and has started making higher '
        'highs and higher lows. However, the latest breakout candle '
        'has weak volume.',
    options: [
      AcademyPracticeOption(
        title: 'Buy immediately',
        description: 'Price is above VWAP, so entry is guaranteed.',
      ),
      AcademyPracticeOption(
        title: 'Wait for additional confirmation',
        description:
            'The trend is supportive, but weak volume requires caution.',
      ),
      AcademyPracticeOption(
        title: 'Immediately buy PE',
        description: 'Weak volume automatically means the trend is bearish.',
      ),
    ],
    correctIndex: 1,
    explanation:
        'Correct. Price above VWAP and bullish structure provide '
        'supportive context, but weak breakout volume means waiting '
        'for additional confirmation can be more disciplined.',
  ),

  AcademyPractice(
    id: 'practice-ema',
    lessonId: 'ema',
    title: 'EMA Direction',
    scenario:
        'Price is trading above both EMAs. The faster EMA is above '
        'the slower EMA and both are pointing upward.',
    options: [
      AcademyPracticeOption(
        title: 'Bullish momentum context',
        description: 'Price and EMA direction support the bullish bias.',
      ),
      AcademyPracticeOption(
        title: 'Guaranteed buy signal',
        description: 'EMA alignment guarantees a winning trade.',
      ),
      AcademyPracticeOption(
        title: 'Guaranteed reversal',
        description: 'The market must reverse immediately.',
      ),
    ],
    correctIndex: 0,
    explanation:
        'Correct. Price above the EMAs with upward EMA direction '
        'provides bullish momentum context. It is not, by itself, '
        'a guaranteed entry signal.',
  ),

  AcademyPractice(
    id: 'practice-risk-reward',
    lessonId: 'risk-reward',
    title: 'Risk-to-Reward',
    scenario:
        'You plan a trade with a maximum loss of ₹1,000 and a '
        'potential profit of ₹3,000.',
    options: [
      AcademyPracticeOption(
        title: '1:1',
        description: 'Risk and reward are equal.',
      ),
      AcademyPracticeOption(
        title: '1:2',
        description: 'Reward is twice the risk.',
      ),
      AcademyPracticeOption(
        title: '1:3',
        description: 'Potential reward is three times the risk.',
      ),
    ],
    correctIndex: 2,
    explanation:
        'Correct. The trade risks ₹1,000 for a potential ₹3,000 '
        'reward, which represents a 1:3 risk-to-reward ratio.',
  ),

  AcademyPractice(
    id: 'practice-no-trade',
    lessonId: 'no-trade',
    title: 'The Best Trade Can Be No Trade',
    scenario:
        'The market is moving sideways. Your strategy requires a '
        'clear trend, strong confirmation and a defined risk-to-reward '
        'setup. None of these conditions are currently present.',
    options: [
      AcademyPracticeOption(
        title: 'Force a trade',
        description: 'There must always be a trade during market hours.',
      ),
      AcademyPracticeOption(
        title: 'Increase position size',
        description: 'Use more capital to compensate for the weak setup.',
      ),
      AcademyPracticeOption(
        title: 'Stay out',
        description: 'Wait until the predefined conditions appear.',
      ),
    ],
    correctIndex: 2,
    explanation:
        'Correct. If your predefined conditions are not present, '
        'staying out protects capital and maintains discipline. '
        'A trader does not need to participate in every market move.',
  ),
];
