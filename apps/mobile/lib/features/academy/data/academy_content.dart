import '../models/academy_lesson.dart';

const academyCategories = <AcademyCategory>[
  AcademyCategory(
    id: 'candlesticks',
    title: 'Candlesticks',
    subtitle: 'Understand price action and candle behaviour.',
    icon: '🕯️',
    lessons: [
      AcademyLesson(
        id: 'candle-basics',
        title: 'Candlestick Basics',
        description: 'Learn what open, high, low and close mean.',
        icon: '🕯️',
        sections: [
          'A candlestick represents price movement during a specific period.',
          'Open is the first traded price of the period.',
          'High is the highest traded price.',
          'Low is the lowest traded price.',
          'Close is the final traded price.',
          'The body shows the distance between open and close.',
          'The wick shows prices reached outside the body.',
        ],
      ),
      AcademyLesson(
        id: 'bullish-bearish',
        title: 'Bullish & Bearish Candles',
        description: 'Understand buying and selling pressure.',
        icon: '📈',
        sections: [
          'A bullish candle closes above its open.',
          'A bearish candle closes below its open.',
          'Large bodies generally represent stronger directional movement.',
          'Small bodies can indicate hesitation or balance.',
          'Always consider the candle in its market context.',
        ],
      ),
      AcademyLesson(
        id: 'candle-patterns',
        title: 'Important Candle Patterns',
        description: 'Learn common reversal and continuation patterns.',
        icon: '🔥',
        sections: [
          'Doji can indicate indecision.',
          'Hammer can indicate rejection of lower prices.',
          'Shooting star can indicate rejection of higher prices.',
          'Engulfing patterns can indicate a change in short-term pressure.',
          'Patterns should be confirmed by price structure and volume.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'volume',
    title: 'Volume',
    subtitle: 'Understand participation behind price movement.',
    icon: '📊',
    lessons: [
      AcademyLesson(
        id: 'volume-basics',
        title: 'Volume Basics',
        description: 'Understand what trading volume represents.',
        icon: '📊',
        sections: [
          'Volume represents the amount of trading activity during a period.',
          'Price movement with strong volume can indicate stronger participation.',
          'Low volume can indicate limited participation.',
          'Compare volume with recent periods instead of looking at one bar alone.',
        ],
      ),
      AcademyLesson(
        id: 'volume-price',
        title: 'Price + Volume',
        description: 'Use volume together with price action.',
        icon: '📈',
        sections: [
          'A breakout supported by higher-than-usual volume is generally more meaningful.',
          'A price move on weak volume deserves additional confirmation.',
          'Volume should support the direction of the price move.',
          'Never use volume as an isolated buy or sell signal.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'indicators',
    title: 'Indicators',
    subtitle: 'Learn how technical indicators support decisions.',
    icon: '📈',
    lessons: [
      AcademyLesson(
        id: 'ema',
        title: 'EMA',
        description: 'Understand Exponential Moving Averages.',
        icon: '〽️',
        sections: [
          'EMA gives greater weight to recent prices.',
          'A rising EMA can help identify upward momentum.',
          'A falling EMA can help identify downward momentum.',
          'Quanttora uses EMA 22 and EMA 33 as part of its technical framework.',
          'An EMA should be used with price action and other confirmations.',
        ],
      ),
      AcademyLesson(
        id: 'vwap',
        title: 'VWAP',
        description: 'Understand Volume Weighted Average Price.',
        icon: '⚖️',
        sections: [
          'VWAP represents the average traded price weighted by volume.',
          'Price above VWAP can indicate stronger intraday positioning.',
          'Price below VWAP can indicate weaker intraday positioning.',
          'VWAP is especially useful for intraday analysis.',
        ],
      ),
      AcademyLesson(
        id: 'rsi',
        title: 'RSI',
        description: 'Understand momentum using Relative Strength Index.',
        icon: '📉',
        sections: [
          'RSI measures the speed and magnitude of recent price changes.',
          'RSI is commonly displayed on a 0–100 scale.',
          'High RSI can indicate strong upward momentum.',
          'Low RSI can indicate strong downward momentum.',
          'Do not automatically treat high RSI as a sell signal or low RSI as a buy signal.',
        ],
      ),
      AcademyLesson(
        id: 'macd',
        title: 'MACD',
        description: 'Understand trend and momentum together.',
        icon: '📚',
        sections: [
          'MACD compares moving averages to help study momentum and trend.',
          'The MACD line and signal line can help identify changes in momentum.',
          'A crossover can provide information about changing momentum.',
          'The histogram helps visualize the difference between the MACD line and signal line.',
          'MACD should be combined with price structure and market context.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'market-basics',
    title: 'Market Basics',
    subtitle: 'Build a strong foundation before trading.',
    icon: '🌐',
    lessons: [
      AcademyLesson(
        id: 'stocks-options',
        title: 'Stocks & Options',
        description:
            'Understand the difference between equity and derivatives.',
        icon: '💹',
        sections: [
          'A stock represents ownership in a company.',
          'An option is a derivative contract whose value is linked to an underlying asset.',
          'Options can provide leverage but also introduce additional risks.',
          'Understand the underlying asset before trading its options.',
          'Option prices can be affected by factors beyond the underlying price.',
        ],
      ),
      AcademyLesson(
        id: 'orders',
        title: 'Order Types',
        description: 'Understand common ways to enter and exit trades.',
        icon: '📝',
        sections: [
          'A market order is designed to execute at the best available price.',
          'A limit order specifies the maximum price for a buy or minimum price for a sell.',
          'A stop order can be used as part of a predefined trading plan.',
          'Order execution depends on available liquidity and market conditions.',
          'Always understand the order type before submitting it.',
        ],
      ),
      AcademyLesson(
        id: 'market-structure',
        title: 'Market Structure',
        description: 'Understand trends, ranges and changing price structure.',
        icon: '🏗️',
        sections: [
          'Markets generally move through trends, ranges and transitions.',
          'An uptrend contains higher highs and higher lows.',
          'A downtrend contains lower highs and lower lows.',
          'A range is a period where price moves between relatively defined boundaries.',
          'A structural break can indicate that the previous market condition may be changing.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'risk-management',
    title: 'Risk Management',
    subtitle: 'Protect capital before thinking about profit.',
    icon: '🛡️',
    lessons: [
      AcademyLesson(
        id: 'risk-reward',
        title: 'Risk-to-Reward',
        description: 'Understand how potential reward compares with risk.',
        icon: '⚖️',
        sections: [
          'Risk-to-reward compares potential loss with potential profit.',
          'A 1:2 setup means risking one unit for a potential two units of reward.',
          'A 1:3 setup means risking one unit for a potential three units of reward.',
          'A good risk-to-reward ratio does not guarantee a winning trade.',
          'Consistency matters more than trying to win every trade.',
        ],
      ),
      AcademyLesson(
        id: 'trading-discipline',
        title: 'Trading Limits',
        description: 'Create rules that protect you from overtrading.',
        icon: '🚦',
        sections: [
          'Define a maximum daily loss before trading.',
          'Define a maximum number of trades.',
          'Stop trading when your predefined daily limit is reached.',
          'Do not increase position size to recover a previous loss.',
          'Protecting capital is more important than forcing another trade.',
        ],
      ),
      AcademyLesson(
        id: 'position-sizing',
        title: 'Position Sizing',
        description: 'Understand how much capital to allocate to a trade.',
        icon: '📐',
        sections: [
          'Position size should be determined by acceptable risk.',
          'A wider stop-loss generally requires a smaller position size for the same risk.',
          'Never increase size simply because you want a larger profit.',
          'Your maximum acceptable loss should be known before entering.',
          'Consistent position sizing helps make results more measurable.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'psychology',
    title: 'Trading Psychology',
    subtitle: 'Build discipline and consistency.',
    icon: '🧠',
    lessons: [
      AcademyLesson(
        id: 'emotions',
        title: 'Control Emotions',
        description: 'Understand fear, greed and impulsive decisions.',
        icon: '🧠',
        sections: [
          'Fear can cause premature exits or missed opportunities.',
          'Greed can cause excessive position sizing or late entries.',
          'Losses can create revenge-trading behaviour.',
          'A predefined trading plan reduces emotional decision-making.',
          'Accepting a planned loss is part of disciplined trading.',
        ],
      ),
      AcademyLesson(
        id: 'discipline',
        title: 'Trading Discipline',
        description: 'Follow your system consistently.',
        icon: '🎯',
        sections: [
          'A trading rule is useful only when it is followed.',
          'Do not change rules because of one winning or losing trade.',
          'Judge a strategy over a meaningful sample of trades.',
          'The goal is process consistency, not constant action.',
          'Sometimes the best trade is no trade.',
        ],
      ),
    ],
  ),

  AcademyCategory(
    id: 'strategy',
    title: 'Strategy Education',
    subtitle: 'Learn how rules become a repeatable trading system.',
    icon: '🎯',
    lessons: [
      AcademyLesson(
        id: 'strategy-building',
        title: 'Build a Trading Strategy',
        description: 'Turn an idea into measurable rules.',
        icon: '🧩',
        sections: [
          'Define the market and timeframe.',
          'Define entry conditions.',
          'Define confirmation conditions.',
          'Define stop-loss conditions.',
          'Define target conditions.',
          'Define position sizing.',
          'Define when not to trade.',
        ],
      ),
      AcademyLesson(
        id: 'strategy-confirmation',
        title: 'Confirmation',
        description: 'Avoid taking trades from a single signal.',
        icon: '✅',
        sections: [
          'A strong setup can combine price action, trend, volume and momentum.',
          'Confirmation should improve selectivity rather than create unnecessary complexity.',
          'Avoid adding indicators simply because a trade failed.',
          'Every filter should have a clear purpose.',
          'More indicators do not automatically mean a better strategy.',
        ],
      ),
      AcademyLesson(
        id: 'no-trade',
        title: 'When Not To Trade',
        description: 'Learn why staying out is also a decision.',
        icon: '⛔',
        sections: [
          'Sideways or unclear markets can produce poor risk-to-reward setups.',
          'Avoid trades when your predefined conditions are not present.',
          'Low liquidity and abnormal spreads can increase execution risk.',
          'Protecting capital on a poor setup is a successful decision.',
          'A disciplined trader does not need to trade every market move.',
        ],
      ),
    ],
  ),
];
