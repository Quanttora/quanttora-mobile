export type NavigationTab = 'home' | 'discover' | 'decision' | 'academy' | 'journal' | 'analytics' | 'practice' | 'constitution' | 'brokers' | 'profile';

export type MarketSession = 'pre_market' | 'morning_trend' | 'midday_chop' | 'afternoon_close' | 'post_market';

export interface MarketIndex {
  symbol: string;
  name: string;
  value: number;
  change: number;
  changePercent: number;
  high: number;
  low: number;
  isPositive: boolean;
}

export interface MarketBreadth {
  advancing: number;
  declining: number;
  unchanged: number;
  totalVolume: string;
  fiiFlow: string;
  diiFlow: string;
}

export interface SectorMovement {
  name: string;
  changePercent: number;
  leader: string;
  status: 'bullish' | 'neutral' | 'bearish';
}

export interface MarketIntelligence {
  marketStatus: 'open' | 'closed' | 'pre_open';
  countdownText: string;
  readinessScore: number;
  readinessFactors: {
    marketEnvironment: boolean;
    volatility: boolean;
    strategyConditions: boolean;
    riskCapacity: boolean;
    constitutionCompliant: boolean;
  };
  recommendation: 'favorable' | 'selective' | 'no_trade';
  recommendationSummary: string;
  keyLevels: {
    niftySupport: number[];
    niftyResistance: number[];
    bankNiftySupport: number[];
    bankNiftyResistance: number[];
  };
  importantEvents: {
    time: string;
    title: string;
    impact: 'high' | 'medium' | 'low';
    description: string;
  }[];
  preMarketSummary: string;
  globalContext: string;
}

export interface StockDiscovery {
  id: string;
  symbol: string;
  companyName: string;
  sector: string;
  price: number;
  changePercent: number;
  relativeVolume: number;
  volumeExpansion: boolean;
  momentumScore: number;
  marketStructure: 'Breakout' | 'Pullback to VWAP' | 'Range Bound' | 'Mean Reversion' | 'Breakdown';
  technicalCondition: string;
  liquidity: 'High' | 'Very High' | 'Moderate';
  isFnO: boolean;
  oiData?: {
    buildup: 'Long Buildup' | 'Short Buildup' | 'Short Covering' | 'Long Unwinding';
    oiChangePercent: number;
    pcr: number;
    impliedVolatility: number;
    maxPain: number;
    callResistance: number;
    putSupport: number;
  };
  reasonForAnalysis: string;
  suggestedDirection: 'BUY' | 'SELL' | 'WAIT';
}

export interface TradingConstitution {
  maxDailyTrades: number;
  currentDailyTrades: number;
  maxDailyLoss: number;
  currentDailyLoss: number;
  maxRiskPerTrade: number;
  minRiskReward: number;
  maxConsecutiveLosses: number;
  currentConsecutiveLosses: number;
  tradingSessions: {
    morningWindow: boolean;
    middayAllowed: boolean;
    afternoonWindow: boolean;
  };
  approvedStrategies: string[];
  instrumentsAllowed: ('NIFTY' | 'BANKNIFTY' | 'FINNIFTY' | 'EQUITY_CASH' | 'STOCK_FUTURES' | 'OPTIONS_BUYING' | 'OPTIONS_SELLING')[];
  dailyProfitLockThreshold?: number;
  cooldownMinutesAfterLoss: number;
  standDownActive: boolean;
  standDownReason?: string;
  standDownActivatedAt?: string;
}

export interface SetupInput {
  instrument: string;
  segment: 'Index Options' | 'Equity Cash' | 'Stock Futures' | 'Option Selling';
  direction: 'BUY' | 'SELL';
  strategy: string;
  entry: number;
  stopLoss: number;
  target: number;
  quantity: number;
  marketCondition: string;
  sessionTime: string;
  notes?: string;
}

export interface SetupEvaluation {
  score: number;
  status: 'HIGH_QUALITY' | 'MODERATE_SELECTIVE' | 'UNFAVORABLE_STAND_DOWN';
  factors: {
    technicalSetup: { passed: boolean; score: number; detail: string };
    marketDirection: { passed: boolean; score: number; detail: string };
    volumeConfirmation: { passed: boolean; score: number; detail: string };
    riskReward: { passed: boolean; score: number; detail: string };
    strategyMatch: { passed: boolean; score: number; detail: string };
    constitutionCompliance: { passed: boolean; score: number; detail: string };
    marketEnvironment: { passed: boolean; score: number; detail: string };
  };
  calculatedRisk: number;
  calculatedReward: number;
  riskRewardRatio: number;
  constitutionChecks: {
    tradesRemainingOk: boolean;
    dailyLossLimitOk: boolean;
    riskPerTradeOk: boolean;
    minRROk: boolean;
    strategyApprovedOk: boolean;
    windowActiveOk: boolean;
    violations: string[];
  };
  recommendationText: string;
  whyExplanation: string[];
  aiAnalysis?: string;
}

export interface JournalTrade {
  id: string;
  date: string;
  time: string;

  instrument: string;
  segment: string;
  direction: 'BUY' | 'SELL';
  strategy: string;

  entryPrice: number;
  exitPrice: number;
  stopLoss: number;
  target: number;
  quantity: number;

  pnl: number;
  realizedR: number;
  potentialReward?: number;
  riskAmount?: number;

  setupQuality: number;
  session: string;
  marketCondition: string;

  ruleCompliance: boolean;
  ruleViolations: string[];

  executionRating:
    | 'Flawless'
    | 'Good'
    | 'Hesitated'
    | 'Moved SL'
    | 'Early Exit'
    | 'FOMO Entry';

  notes: string;
  postTradeReview?: string;

  // Execution metadata
  instrumentToken?: string;
  broker?: string;
  orderId?: string;
  executionTime?: string;
  orderType?: string;
  product?: string;
  validity?: string;

  tradeSource?: 'manual' | 'paper' | 'live';
  positionStatus?: 'OPEN' | 'CLOSED';

  constitutionPassed?: boolean;
  strategyPolicyPassed?: boolean;
  aiConfidence?: number;

  exitReason?: string;
}

export interface PerformanceStats {
  totalTrades: number;
  winningTrades: number;
  losingTrades: number;
  breakEvenTrades: number;
  winRate: number;
  profitFactor: number;
  totalPnL: number;
  expectancyR: number;
  avgWinR: number;
  avgLossR: number;
  maxDrawdown: number;
  consecutiveWins: number;
  consecutiveLosses: number;
  ruleViolationsCount: number;
  disciplinedTradesWinRate: number;
  undisciplinedTradesWinRate: number;
  strategyBreakdown: { strategy: string; trades: number; winRate: number; netR: number }[];
  sessionBreakdown: { session: string; winRate: number; netR: number; tradesCount: number }[];
  qualityVsResult: { qualityTier: string; winRate: number; avgR: number; count: number }[];
}

export interface BehavioralLeak {
  id: string;
  title: string;
  frequency: string;
  severity: 'High' | 'Medium' | 'Low';
  description: string;
  evidence: string;
  actionableFix: string;
  ruleEnforcement: string;
}

export interface AcademyLesson {
  id: string;
  pathId: string;
  title: string;
  durationMinutes: number;
  level: 'Foundations' | 'Intermediate' | 'Advanced';
  summary: string;
  keyConcepts: string[];
  explanation: string;
  diagramType?: 'candlestick' | 'risk_reward' | 'oi_buildup' | 'volume_profile' | 'support_resistance';
  diagramTitle?: string;
  diagramData?: any;
  quanttoraTakeaway: string;
  practiceQuestion: {
    question: string;
    options: string[];
    correctIndex: number;
    explanation: string;
  };
  completed: boolean;
}

export interface LearningPath {
  id: string;
  title: string;
  description: string;
  iconName: string;
  level: 'Foundations' | 'Core Discipline' | 'Advanced Execution';
  lessonsCount: number;
  completedCount: number;
  lessons: AcademyLesson[];
}

export interface PracticeScenario {
  id: string;
  title: string;
  instrument: string;
  timeContext: string;
  setupDescription: string;
  chartDetails: {
    trend: string;
    volumeCondition: string;
    indicatorCondition: string;
    priceAction: string;
    levels: string;
  };
  question: string;
  options: {
    id: string;
    text: string;
    isOptimal: boolean;
    rating: 'Optimal Decision' | 'Sub-optimal' | 'High Risk Violation' | 'Over-cautious';
    scoreEarned: number;
    explanation: string;
    factorsConsidered: string[];
  }[];
  completed?: boolean;
  selectedOptionId?: string;
}

export interface TraderKnowledgeScore {
  overallScore: number;
  categories: {
    marketKnowledge: number;
    technicalKnowledge: number;
    riskManagement: number;
    strategyKnowledge: number;
    optionsKnowledge: number;
    tradingDiscipline: number;
  };
  lessonsCompleted: number;
  practiceScenariosPassed: number;
  practicePoints: number;
}

export interface TraderProfile {
  name: string;
  experienceYears: string;
  tradingStyle: 'Disciplined Price Action' | 'Systematic Breakouts' | 'Options Flow Trader' | 'Conservative Intraday';
  primaryInstruments: string[];
  preferredStrategies: string[];
  riskProfile: 'Strict Capital Preservation (Max 1% per trade)' | 'Moderate Growth (Max 1.5%)';
  strengths: string[];
  areasToImprove: string[];
}

export interface BrokerIntegration {
  id: string;
  name: string;
  tagline: string;
  status: 'connected' | 'disconnected';
  iconColor: string;
  supportedCapabilities: string[];
  connectionNotice: string;
  clientId?: string;
  lastSynced?: string;
}
