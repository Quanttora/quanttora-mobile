import React, { useState, useEffect, useMemo } from 'react';
import {
  TradingConstitution,
  NavigationTab,
  StockDiscovery,
  JournalTrade,
  TraderKnowledgeScore,
  BehavioralLeak,
  PerformanceStats,
  MarketIndex,
  MarketBreadth,
  SectorMovement,
  MarketIntelligence,
} from './types';

import {
  initialMarketIntelligence,
  initialConstitution,
  initialDiscoveries,
  initialJournalTrades,
  initialPerformanceStats,
  initialBehavioralLeaks,
  initialAcademyLessons,
  initialKnowledgeScore,
  initialBrokers,
} from './data/initialData';

import { Header } from './components/Header';
import { BottomNav } from './components/BottomNav';
import { StandDownBanner } from './components/StandDownBanner';
import { ConstitutionModal } from './components/ConstitutionModal';
import { TraderProfileModal } from './components/TraderProfileModal';
import { HomeDashboard } from './components/HomeDashboard';
import { DiscoverView } from './components/DiscoverView';
import { DecisionEngineView } from './components/DecisionEngineView';
import { JournalView } from './components/JournalView';
import { AnalyticsView } from './components/AnalyticsView';
import { AcademyView } from './components/AcademyView';
import { PracticeSimulatorView } from './components/PracticeSimulatorView';
import { BrokersView } from './components/BrokersView';
import { initialPracticeScenarios } from './data/initialData';

import {
  getMarketDashboard,
  getMarketQuotes,
  getMarketStatus,
  toNumber,
  MarketDashboard,
} from './services/quanttoraApi';

import {
  connectBrokerFeed,
  getBrokerFeedStatus,
  startUpstoxOAuth,
} from './services/brokerService';

import {
  startZerodhaOAuth,
} from './services/zerodhaBrokerService';

const STORAGE_KEYS = {
  CONSTITUTION: 'quanttora_constitution_v1',
  TRADES: 'quanttora_trades_v1',
  KNOWLEDGE: 'quanttora_knowledge_v1',
  LESSONS: 'quanttora_lessons_v1',
};

const MARKET_INSTRUMENTS = [
  {
    key: 'NSE_INDEX|Nifty 50',
    symbol: 'NIFTY 50',
    name: 'Nifty 50',
  },
  {
    key: 'NSE_INDEX|Nifty Bank',
    symbol: 'BANK NIFTY',
    name: 'Nifty Bank',
  },
  {
    key: 'BSE_INDEX|SENSEX',
    symbol: 'SENSEX',
    name: 'Sensex',
  },
  {
    key: 'NSE_INDEX|India VIX',
    symbol: 'INDIA VIX',
    name: 'India VIX',
  },
] as const;

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object'
    ? (value as Record<string, unknown>)
    : {};
}

function findArray(
  source: Record<string, unknown>,
  ...keys: string[]
): unknown[] {
  for (const key of keys) {
    const value = source[key];

    if (Array.isArray(value)) {
      return value;
    }
  }

  return [];
}

function pickNumber(
  source: Record<string, unknown>,
  ...keys: string[]
): number {
  for (const key of keys) {
    const value = source[key];

    if (value !== undefined && value !== null) {
      return toNumber(value, 0);
    }
  }

  return 0;
}

function pickString(
  source: Record<string, unknown>,
  fallback: string,
  ...keys: string[]
): string {
  for (const key of keys) {
    const value = source[key];

    if (typeof value === 'string' && value.trim()) {
      return value;
    }
  }

  return fallback;
}

function normalizeIndex(
  raw: unknown,
  fallback: typeof MARKET_INSTRUMENTS[number]
): MarketIndex {
  const item = asRecord(raw);

  const value = pickNumber(
    item,
    'value',
    'ltp',
    'lastPrice',
    'price',
    'close'
  );

  const change = pickNumber(
    item,
    'change',
    'priceChange',
    'netChange'
  );

  const changePercent = pickNumber(
    item,
    'changePercent',
    'change_percentage',
    'percentChange',
    'percentageChange'
  );

  return {
    symbol: pickString(
      item,
      fallback.symbol,
      'symbol',
      'tradingSymbol',
      'shortName'
    ),
    name: pickString(
      item,
      fallback.name,
      'name',
      'displayName'
    ),
    value,
    change,
    changePercent,
    high: pickNumber(item, 'high', 'dayHigh'),
    low: pickNumber(item, 'low', 'dayLow'),
    isPositive: changePercent >= 0,
  };
}

function normalizeIndices(
  payload: MarketDashboard,
  quotes: Record<string, unknown>[]
): MarketIndex[] {
  const root = asRecord(payload);

  const rawIndices = findArray(
    root,
    'indices',
    'indexQuotes',
    'marketIndices'
  );

  const objectIndices = asRecord(
    root.indices
  );

  const indexedEntries = Object.values(
    objectIndices
  );

  const source = rawIndices.length
    ? rawIndices
    : indexedEntries.length
    ? indexedEntries
    : quotes;

  return MARKET_INSTRUMENTS.map((instrument) => {
    const match = source.find((raw) => {
      const item = asRecord(raw);

      const instrumentKey = pickString(
        item,
        '',
        'instrumentKey',
        'instrument_key',
        'key'
      ).toUpperCase();

      const symbol = pickString(
        item,
        '',
        'symbol',
        'tradingSymbol',
        'name'
      ).toUpperCase();

      // Zerodha returns dashboard quotes with NSE:/BSE: instrument keys,
      // while the legacy Upstox keys use NSE_INDEX|/BSE_INDEX|.
      // Accept both formats so the same dashboard works with either broker.
      const zerodhaKeyBySymbol: Record<string, string> = {
        'NIFTY 50': 'NSE:NIFTY 50',
        'BANK NIFTY': 'NSE:NIFTY BANK',
        SENSEX: 'BSE:SENSEX',
        'INDIA VIX': 'NSE:INDIA VIX',
      };

      const zerodhaKey =
        zerodhaKeyBySymbol[instrument.symbol] || '';

      return (
        instrumentKey === instrument.key.toUpperCase() ||
        instrumentKey === zerodhaKey ||
        symbol.includes(instrument.symbol)
      );
    });

    return normalizeIndex(
      match ?? {},
      instrument
    );
  });
}

function normalizeBreadth(
  payload: MarketDashboard
): MarketBreadth {
  const root = asRecord(payload);

  const raw = asRecord(
    root.breadth ??
      root.marketBreadth
  );

  return {
    advancing: pickNumber(
      raw,
      'advancing',
      'advances',
      'advancingStocks'
    ),

    declining: pickNumber(
      raw,
      'declining',
      'declines',
      'decliningStocks'
    ),

    unchanged: pickNumber(
      raw,
      'unchanged',
      'unchangedStocks'
    ),

    totalVolume: pickString(
      raw,
      '—',
      'totalVolume',
      'volume'
    ),

    fiiFlow: pickString(
      raw,
      '—',
      'fiiFlow',
      'fii',
      'fiiNetFlow'
    ),

    diiFlow: pickString(
      raw,
      '—',
      'diiFlow',
      'dii',
      'diiNetFlow'
    ),
  };
}

function normalizeSectors(
  payload: MarketDashboard
): SectorMovement[] {
  const root = asRecord(payload);

  return findArray(
    root,
    'sectors',
    'sectorMovements'
  ).map((raw) => {
    const item = asRecord(raw);

    const changePercent = pickNumber(
      item,
      'changePercent',
      'change_percentage',
      'percentChange',
      'percentageChange'
    );

    const statusValue = pickString(
      item,
      '',
      'status'
    ).toLowerCase();

    const status: SectorMovement['status'] =
      statusValue === 'bullish' ||
      statusValue === 'bearish'
        ? statusValue
        : changePercent > 0.5
        ? 'bullish'
        : changePercent < -0.5
        ? 'bearish'
        : 'neutral';

    return {
      name: pickString(
        item,
        'Unknown sector',
        'name',
        'symbol'
      ),

      changePercent,

      leader: pickString(
        item,
        '—',
        'leader',
        'topStock',
        'topConstituent'
      ),

      status,
    };
  });
}

function normalizeMarketIntel(
  payload: MarketDashboard,
  connected: boolean
): MarketIntelligence {
  const root = asRecord(payload);

  const raw = asRecord(
    root.marketIntelligence ??
      root.marketIntel ??
      root.intelligence
  );

  const keyLevels = asRecord(
    raw.keyLevels
  );

  const importantEvents: MarketIntelligence['importantEvents'] =
    Array.isArray(raw.importantEvents)
      ? raw.importantEvents.map((event) => {
          const item = asRecord(event);

          const impact = pickString(
            item,
            'low',
            'impact'
          ).toLowerCase();

          const impactValue:
            'high' | 'medium' | 'low' =
            impact === 'high'
              ? 'high'
              : impact === 'medium'
              ? 'medium'
              : 'low';

          return {
            time: pickString(
              item,
              '—',
              'time'
            ),

            title: pickString(
              item,
              'Market event',
              'title',
              'name'
            ),

            impact: impactValue,

            description: pickString(
              item,
              '',
              'description',
              'details'
            ),
          };
        })
      : [];

  const marketStatus = pickString(
    raw,
    connected ? 'open' : 'closed',
    'marketStatus',
    'status'
  ).toLowerCase();

  const recommendation =
    pickString(
      raw,
      connected
        ? 'selective'
        : 'no_trade',
      'recommendation'
    ).toLowerCase();

  const factors = asRecord(
    raw.readinessFactors
  );

  return {
    marketStatus:
      marketStatus === 'pre_open' ||
      marketStatus === 'open'
        ? marketStatus
        : 'closed',

    countdownText: pickString(
      raw,
      connected
        ? 'Live feed connected'
        : 'Feed offline',
      'countdownText',
      'countdown'
    ),

    readinessScore: connected
      ? pickNumber(
          raw,
          'readinessScore',
          'readiness'
        )
      : 0,

    readinessFactors: {
      marketEnvironment: connected
        ? Boolean(
            factors.marketEnvironment ??
              true
          )
        : false,

      volatility: connected
        ? Boolean(
            factors.volatility ??
              true
          )
        : false,

      strategyConditions: connected
        ? Boolean(
            factors.strategyConditions ??
              true
          )
        : false,

      riskCapacity: connected
        ? Boolean(
            factors.riskCapacity ??
              true
          )
        : false,

      constitutionCompliant: true,
    },

    recommendation:
      recommendation === 'favorable' ||
      recommendation === 'selective'
        ? recommendation
        : 'no_trade',

    recommendationSummary:
      pickString(
        raw,
        connected
          ? 'Live market data is available. Assess your setup before execution.'
          : 'Live market data is unavailable. Do not treat displayed market values as current.',
        'recommendationSummary',
        'summary'
      ),

    keyLevels: {
      niftySupport:
        Array.isArray(
          keyLevels.niftySupport
        )
          ? keyLevels.niftySupport
              .map((value) =>
                toNumber(value)
              )
              .filter(Boolean)
          : [],

      niftyResistance:
        Array.isArray(
          keyLevels.niftyResistance
        )
          ? keyLevels.niftyResistance
              .map((value) =>
                toNumber(value)
              )
              .filter(Boolean)
          : [],

      bankNiftySupport:
        Array.isArray(
          keyLevels.bankNiftySupport
        )
          ? keyLevels.bankNiftySupport
              .map((value) =>
                toNumber(value)
              )
              .filter(Boolean)
          : [],

      bankNiftyResistance:
        Array.isArray(
          keyLevels.bankNiftyResistance
        )
          ? keyLevels.bankNiftyResistance
              .map((value) =>
                toNumber(value)
              )
              .filter(Boolean)
          : [],
    },

    importantEvents,

    preMarketSummary:
      pickString(
        raw,
        connected
          ? 'Live market feed connected.'
          : 'Market feed is offline.',
        'preMarketSummary',
        'marketSummary'
      ),

    globalContext: pickString(
      raw,
      '',
      'globalContext'
    ),
  };
}

export default function App() {
  // Navigation State
  const [activeTab, setActiveTab] =
    useState<NavigationTab>('home');

  const [
    selectedStockForDecision,
    setSelectedStockForDecision,
  ] = useState<StockDiscovery | null>(null);

  // Modals
  const [
    isConstitutionModalOpen,
    setIsConstitutionModalOpen,
  ] = useState(false);

  const [
    isProfileModalOpen,
    setIsProfileModalOpen,
  ] = useState(false);

  // Persistent Constitution State
  const [constitution, setConstitution] =
    useState<TradingConstitution>(() => {
      const saved = localStorage.getItem(
        STORAGE_KEYS.CONSTITUTION
      );

      if (saved) {
        try {
          return JSON.parse(saved);
        } catch (error) {
          console.error(error);
        }
      }

      return initialConstitution;
    });

  // Persistent Journal Trades State
  const [trades, setTrades] =
    useState<JournalTrade[]>(() => {
      const saved = localStorage.getItem(
        STORAGE_KEYS.TRADES
      );

      if (saved) {
        try {
          return JSON.parse(saved);
        } catch (error) {
          console.error(error);
        }
      }

      return initialJournalTrades;
    });

  // Persistent Academy & Knowledge State
  const [lessons, setLessons] =
    useState(() => {
      const saved = localStorage.getItem(
        STORAGE_KEYS.LESSONS
      );

      if (saved) {
        try {
          return JSON.parse(saved);
        } catch (error) {
          console.error(error);
        }
      }

      return initialAcademyLessons;
    });

  const [
    knowledgeScore,
    setKnowledgeScore,
  ] = useState<TraderKnowledgeScore>(() => {
    const saved = localStorage.getItem(
      STORAGE_KEYS.KNOWLEDGE
    );

    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (error) {
        console.error(error);
      }
    }

    return initialKnowledgeScore;
  });

  // ============================================================
  // LIVE MARKET STATE
  // ============================================================

  const [indices, setIndices] =
    useState<MarketIndex[]>([]);

  const [breadth, setBreadth] =
    useState<MarketBreadth>({
      advancing: 0,
      declining: 0,
      unchanged: 0,
      totalVolume: '—',
      fiiFlow: '—',
      diiFlow: '—',
    });

  const [sectors, setSectors] =
    useState<SectorMovement[]>([]);

  const [marketIntel, setMarketIntel] =
    useState<MarketIntelligence>(() => ({
      ...initialMarketIntelligence,

      marketStatus: 'closed',

      countdownText:
        'Feed offline',

      readinessScore: 0,

      recommendation:
        'no_trade',

      recommendationSummary:
        'Live market data is unavailable. Do not treat displayed market values as current.',

      preMarketSummary:
        'Market feed is offline.',

      keyLevels: {
        niftySupport: [],
        niftyResistance: [],
        bankNiftySupport: [],
        bankNiftyResistance: [],
      },

      importantEvents: [],
    }));

  const [
    marketFeedConnected,
    setMarketFeedConnected,
  ] = useState(false);

  const [
    marketFeedLoading,
    setMarketFeedLoading,
  ] = useState(true);

  const [
    marketFeedError,
    setMarketFeedError,
  ] = useState<string | null>(null);

  const [
    marketLastUpdated,
    setMarketLastUpdated,
  ] = useState<Date | null>(null);

  // Non-market application state
  const [discoveries] =
    useState(initialDiscoveries);

  const [leaks, setLeaks] =
    useState<BehavioralLeak[]>(
      initialBehavioralLeaks
    );

  const [brokers, setBrokers] =
    useState(initialBrokers);

  // ============================================================
  // PERSISTENT STATE
  // ============================================================

  useEffect(() => {
    localStorage.setItem(
      STORAGE_KEYS.CONSTITUTION,
      JSON.stringify(constitution)
    );
  }, [constitution]);

  useEffect(() => {
    localStorage.setItem(
      STORAGE_KEYS.TRADES,
      JSON.stringify(trades)
    );
  }, [trades]);

  useEffect(() => {
    localStorage.setItem(
      STORAGE_KEYS.LESSONS,
      JSON.stringify(lessons)
    );
  }, [lessons]);

  useEffect(() => {
    localStorage.setItem(
      STORAGE_KEYS.KNOWLEDGE,
      JSON.stringify(knowledgeScore)
    );
  }, [knowledgeScore]);

  // ============================================================
  // REAL MARKET DATA POLLING
  // ============================================================

  useEffect(() => {
    let cancelled = false;

    let refreshTimer:
      | ReturnType<typeof setInterval>
      | undefined;

    const clearLiveMarket = () => {
      setMarketFeedConnected(false);

      setIndices([]);

      setBreadth({
        advancing: 0,
        declining: 0,
        unchanged: 0,
        totalVolume: '—',
        fiiFlow: '—',
        diiFlow: '—',
      });

      setSectors([]);

      setMarketIntel((previous) => ({
        ...previous,

        marketStatus: 'closed',

        countdownText:
          'Feed offline',

        readinessScore: 0,

        recommendation:
          'no_trade',

        recommendationSummary:
          'Live market data is unavailable. Connect a live feed before relying on market values.',

        preMarketSummary:
          'Market feed is offline.',

        keyLevels: {
          niftySupport: [],
          niftyResistance: [],
          bankNiftySupport: [],
          bankNiftyResistance: [],
        },

        importantEvents: [],
      }));

      setMarketLastUpdated(null);
    };

    const refreshMarket = async () => {
      try {
        setMarketFeedLoading(true);

        const status =
          await getMarketStatus();

        if (cancelled) {
          return;
        }

        if (!status.connected) {
          clearLiveMarket();

          setMarketFeedError(null);

          return;
        }

        const dashboard =
          await getMarketDashboard();

        if (cancelled) {
          return;
        }

        // The dashboard endpoint already returns the live index quotes.
        // Do not make an empty /broker/quotes request; Zerodha requires an
        // explicit instrument and that empty request would incorrectly mark
        // the entire market feed offline.
        const liveIndices =
          normalizeIndices(
            dashboard,
            []
          );

        const hasLiveIndex =
          liveIndices.some(
            (index) =>
              index.value > 0
          );

        if (!hasLiveIndex) {
          clearLiveMarket();

          setMarketFeedError(
            'Live feed is connected but no index quotes have arrived yet.'
          );

          return;
        }

        setIndices(liveIndices);

        setBreadth(
          normalizeBreadth(
            dashboard
          )
        );

        setSectors(
          normalizeSectors(
            dashboard
          )
        );

        setMarketIntel(
          normalizeMarketIntel(
            dashboard,
            true
          )
        );

        setMarketFeedConnected(
          true
        );

        setMarketFeedError(null);

        setMarketLastUpdated(
          new Date()
        );
      } catch (error) {
        if (cancelled) {
          return;
        }

        console.error(
          '[Quanttora] Market refresh failed:',
          error
        );

        clearLiveMarket();

        setMarketFeedError(
          error instanceof Error
            ? error.message
            : 'Unable to reach market backend.'
        );
      } finally {
        if (!cancelled) {
          setMarketFeedLoading(false);
        }
      }
    };

    void refreshMarket();

    refreshTimer =
      setInterval(
        () => {
          void refreshMarket();
        },
        5000
      );

    return () => {
      cancelled = true;

      if (refreshTimer) {
        clearInterval(
          refreshTimer
        );
      }
    };
  }, []);

  // ============================================================
  // PERFORMANCE STATS
  // ============================================================

  const computedStats:
    PerformanceStats = useMemo(() => {
    if (trades.length === 0) {
      return initialPerformanceStats;
    }

    const totalPnL =
      trades.reduce(
        (acc, trade) =>
          acc + trade.pnl,
        0
      );

    const winningTrades =
      trades.filter(
        (trade) =>
          trade.pnl > 0
      );

    const losingTrades =
      trades.filter(
        (trade) =>
          trade.pnl < 0
      );

    const winRate =
      Number(
        (
          (winningTrades.length /
            trades.length) *
          100
        ).toFixed(1)
      );

    const totalWins =
      winningTrades.reduce(
        (acc, trade) =>
          acc + trade.pnl,
        0
      );

    const totalLosses =
      Math.abs(
        losingTrades.reduce(
          (acc, trade) =>
            acc + trade.pnl,
          0
        )
      );

    const profitFactor =
      totalLosses > 0
        ? Number(
            (
              totalWins /
              totalLosses
            ).toFixed(2)
          )
        : 3.5;

    const avgWinR =
      winningTrades.length > 0
        ? Number(
            (
              winningTrades.reduce(
                (acc, trade) =>
                  acc +
                  trade.realizedR,
                0
              ) /
              winningTrades.length
            ).toFixed(2)
          )
        : 2.1;

    const avgLossR =
      losingTrades.length > 0
        ? Number(
            (
              Math.abs(
                losingTrades.reduce(
                  (acc, trade) =>
                    acc +
                    trade.realizedR,
                  0
                )
              ) /
              losingTrades.length
            ).toFixed(2)
          )
        : 1.0;

    const winProb =
      winRate / 100;

    const lossProb =
      (100 - winRate) /
      100;

    const expectancy =
      Number(
        (
          winProb * avgWinR -
          lossProb * avgLossR
        ).toFixed(2)
      );

    const compliantTrades =
      trades.filter(
        (trade) =>
          trade.ruleCompliance
      );

    const nonCompliantTrades =
      trades.filter(
        (trade) =>
          !trade.ruleCompliance
      );

    const disciplinedWinRate =
      compliantTrades.length > 0
        ? Number(
            (
              (compliantTrades.filter(
                (trade) =>
                  trade.pnl > 0
              ).length /
                compliantTrades.length) *
              100
            ).toFixed(1)
          )
        : 80;

    const undisciplinedWinRate =
      nonCompliantTrades.length > 0
        ? Number(
            (
              (nonCompliantTrades.filter(
                (trade) =>
                  trade.pnl > 0
              ).length /
                nonCompliantTrades.length) *
              100
            ).toFixed(1)
          )
        : 25;

    const ruleAdherenceRate =
      Number(
        (
          (compliantTrades.length /
            trades.length) *
          100
        ).toFixed(1)
      );

    return {
      totalPnL,
      winRate,
      totalTrades:
        trades.length,
      winningTrades:
        winningTrades.length,
      losingTrades:
        losingTrades.length,
      avgWinR,
      avgLossR,
      profitFactor,
      expectancy,
      maxDrawdown:
        initialPerformanceStats.maxDrawdown,
      ruleAdherenceRate,
      disciplinedTradesWinRate:
        disciplinedWinRate,
      undisciplinedTradesWinRate:
        undisciplinedWinRate,
    };
  }, [trades]);

  // ============================================================
  // HANDLERS
  // ============================================================

  const handleToggleStandDown =
    () => {
      setConstitution(
        (previous) => ({
          ...previous,

          standDownActive:
            !previous.standDownActive,

          standDownReason:
            !previous.standDownActive
              ? 'Voluntary capital preservation stand-down.'
              : undefined,
        })
      );
    };

  const handleDeactivateStandDown =
    () => {
      setConstitution(
        (previous) => ({
          ...previous,

          standDownActive:
            false,

          standDownReason:
            undefined,
        })
      );
    };

  const handleSaveConstitution =
    (
      updated: TradingConstitution
    ) => {
      setConstitution(updated);
    };

  const handleSelectDiscoveryForDecision =
    (
      stock: StockDiscovery
    ) => {
      setSelectedStockForDecision(
        stock
      );

      setActiveTab(
        'decision'
      );
    };

  const handleLogTrade = (
    newTradeData: Omit<
      JournalTrade,
      'id' | 'date' | 'time'
    >
  ) => {
    const newTrade:
      JournalTrade = {
      ...newTradeData,

      id: `tr-${Date.now()}`,

      date:
        new Date()
          .toISOString()
          .split('T')[0],

      time:
        new Date().toLocaleTimeString(
          [],
          {
            hour: '2-digit',
            minute: '2-digit',
          }
        ) + ' IST',
    };

    setTrades(
      (previous) => [
        newTrade,
        ...previous,
      ]
    );

    setConstitution(
      (previous) => ({
        ...previous,

        currentDailyTrades:
          previous.currentDailyTrades +
          1,

        currentDailyLoss:
          newTrade.pnl < 0
            ? previous.currentDailyLoss +
              Math.abs(
                newTrade.pnl
              )
            : previous.currentDailyLoss,
      })
    );
  };

  const handleCompleteLesson =
    (
      lessonId: string,
      earnedScore: number
    ) => {
      setLessons(
        (previous) =>
          previous.map(
            (lesson) =>
              lesson.id ===
              lessonId
                ? {
                    ...lesson,
                    isCompleted:
                      true,
                  }
                : lesson
          )
      );

      setKnowledgeScore(
        (previous) => ({
          ...previous,

          overallScore:
            Math.min(
              100,
              previous.overallScore +
                2
            ),

          lessonsCompleted:
            previous.lessonsCompleted +
            1,

          practicePoints:
            previous.practicePoints +
            earnedScore,

          categoryScores: {
            ...previous.categoryScores,

            discipline:
              Math.min(
                100,
                previous
                  .categoryScores
                  .discipline + 2
              ),

            riskManagement:
              Math.min(
                100,
                previous
                  .categoryScores
                  .riskManagement +
                  2
              ),
          },
        })
      );
    };

  const handleEarnPracticePoints =
    (points: number) => {
      setKnowledgeScore(
        (previous) => ({
          ...previous,

          overallScore:
            Math.min(
              100,
              previous.overallScore +
                1
            ),

          practicePoints:
            previous.practicePoints +
            points,
        })
      );
    };

  const handleApplyLeakFixToConstitution =
    (
      leak: BehavioralLeak
    ) => {
      if (
        leak.title.includes(
          'Overtrading'
        ) ||
        leak.title.includes(
          'Frequency'
        )
      ) {
        setConstitution(
          (previous) => ({
            ...previous,

            maxDailyTrades:
              Math.min(
                previous.maxDailyTrades,
                3
              ),
          })
        );
      } else if (
        leak.title.includes(
          'Midday'
        ) ||
        leak.title.includes(
          'Chop'
        )
      ) {
        setConstitution(
          (previous) => ({
            ...previous,

            tradingSessions: {
              ...previous.tradingSessions,

              middayAllowed:
                false,
            },
          })
        );
      } else if (
        leak.title.includes(
          'Moving'
        ) ||
        leak.title.includes(
          'Widening'
        )
      ) {
        setConstitution(
          (previous) => ({
            ...previous,

            minRiskReward:
              Math.max(
                previous.minRiskReward,
                2.0
              ),
          })
        );
      }

      setIsConstitutionModalOpen(
        true
      );
    };

  // ============================================================
  // BROKER CONNECTION
  // ============================================================

  const syncBrokerConnection = async () => {
    try {
      const response = await fetch(
        '/api/proxy/broker/status',
        {
          method: 'GET',
          headers: {
            Accept: 'application/json',
          },
          credentials: 'same-origin',
        },
      );

      const contentType =
        response.headers.get('content-type') || '';

      const payload: unknown =
        contentType.includes('application/json')
          ? await response.json()
          : null;

      if (!response.ok) {
        throw new Error(
          'Unable to read broker connection status.',
        );
      }

      const root = asRecord(payload);
      const brokerValue = root.broker;
      const brokerRecord = asRecord(brokerValue);

      const brokerName =
        typeof brokerValue === 'string'
          ? brokerValue.toLowerCase()
          : pickString(
              brokerRecord,
              '',
              'broker',
              'name',
              'id',
            ).toLowerCase();

      const connected = Boolean(root.connected);

      setBrokers(
        (previous) =>
          previous.map((broker) => {
            const isZerodha =
              broker.id === 'zerodha' &&
              (brokerName === 'zerodha' ||
                brokerName === 'zerodha kite' ||
                brokerName === 'kite');

            const isUpstox =
              broker.id === 'upstox' &&
              brokerName === 'upstox';

            if (!isZerodha && !isUpstox) {
              return {
                ...broker,
                status: 'disconnected',
                lastSync: undefined,
              };
            }

            return {
              ...broker,
              status: connected
                ? 'connected'
                : 'disconnected',
              lastSync: connected
                ? 'Just now'
                : undefined,
            };
          }),
      );

      return {
        connected,
        broker: brokerName,
      };
    } catch (error) {
      console.error(
        '[Quanttora] Broker status sync failed:',
        error,
      );

      setBrokers((previous) =>
        previous.map((broker) => ({
          ...broker,
          status: 'disconnected',
          lastSync: undefined,
        })),
      );

      return {
        connected: false,
        broker: '',
      };
    }
  };

  useEffect(() => {
    let cancelled = false;

    const initialiseBrokerConnection = async () => {
      const params = new URLSearchParams(
        window.location.search,
      );

      const brokerAuth = params.get('broker_auth');

      if (brokerAuth) {
        window.history.replaceState(
          {},
          document.title,
          window.location.pathname,
        );
      }

      try {
        const result = await syncBrokerConnection();

        if (cancelled || !result.connected) {
          return;
        }

        if (result.broker === 'upstox') {
          const feedStatus =
            await getBrokerFeedStatus();

          if (
            cancelled ||
            feedStatus.connected
          ) {
            return;
          }

          await connectBrokerFeed('upstox');
        }
      } catch (error) {
        if (!cancelled) {
          console.error(
            '[Quanttora] Broker initialisation failed:',
            error,
          );
        }
      }
    };

    void initialiseBrokerConnection();

    return () => {
      cancelled = true;
    };
  }, []);

  const handleToggleBroker = async (
    brokerId: string,
  ) => {
    const currentBroker = brokers.find(
      (broker) => broker.id === brokerId,
    );

    if (currentBroker?.status === 'connected') {
      try {
        const response = await fetch(
          '/api/proxy/broker/disconnect',
          {
            method: 'POST',
            headers: {
              Accept: 'application/json',
            },
            credentials: 'same-origin',
          },
        );

        const contentType =
          response.headers.get('content-type') || '';

        const payload: unknown =
          contentType.includes('application/json')
            ? await response.json()
            : null;

        if (!response.ok) {
          const root = asRecord(payload);
          const error = asRecord(root.error);

          throw new Error(
            pickString(
              error,
              pickString(
                root,
                'Unable to disconnect broker.',
                'message',
              ),
              'message',
            ),
          );
        }

        setBrokers((previous) =>
          previous.map((broker) => ({
            ...broker,
            status: 'disconnected',
            lastSync: undefined,
          })),
        );

        return;
      } catch (error) {
        console.error(
          '[Quanttora] Broker disconnect failed:',
          error,
        );

        alert(
          error instanceof Error
            ? error.message
            : 'Unable to disconnect broker.',
        );

        return;
      }
    }

    try {
      if (brokerId === 'zerodha') {
        await startZerodhaOAuth();
        return;
      }

      if (brokerId === 'upstox') {
        await startUpstoxOAuth();
        return;
      }

      return;
    } catch (error) {
      console.error(
        `[Quanttora] ${brokerId} OAuth initiation failed:`,
        error,
      );

      alert(
        error instanceof Error
          ? error.message
          : `Unable to start ${brokerId} connection.`,
      );
    }
  };

  // ============================================================
  // RESET
  // ============================================================

  const handleResetData =
    () => {
      localStorage.removeItem(
        STORAGE_KEYS.CONSTITUTION
      );

      localStorage.removeItem(
        STORAGE_KEYS.TRADES
      );

      localStorage.removeItem(
        STORAGE_KEYS.KNOWLEDGE
      );

      localStorage.removeItem(
        STORAGE_KEYS.LESSONS
      );

      setConstitution(
        initialConstitution
      );

      setTrades(
        initialJournalTrades
      );

      setLessons(
        initialAcademyLessons
      );

      setKnowledgeScore(
        initialKnowledgeScore
      );
    };

  // ============================================================
  // RENDER
  // ============================================================

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 flex flex-col antialiased selection:bg-indigo-100 selection:text-indigo-900">

      <Header
        constitution={
          constitution
        }

        marketIntel={
          marketIntel
        }

        knowledgeScore={
          knowledgeScore
        }

        onOpenConstitution={() =>
          setIsConstitutionModalOpen(
            true
          )
        }

        onOpenProfile={() =>
          setIsProfileModalOpen(
            true
          )
        }

        onOpenBrokers={() =>
          setActiveTab(
            'brokers'
          )
        }

        onToggleStandDown={
          handleToggleStandDown
        }
      />

      <StandDownBanner
        constitution={
          constitution
        }

        onDeactivate={
          handleDeactivateStandDown
        }

        onOpenConstitution={() =>
          setIsConstitutionModalOpen(
            true
          )
        }
      />

      <main className="flex-1 max-w-7xl w-full mx-auto px-2 sm:px-4 pt-3 sm:pt-4">

        {activeTab === 'home' && (
          <HomeDashboard
            indices={
              indices
            }

            breadth={
              breadth
            }

            sectors={
              sectors
            }

            marketIntel={
              marketIntel
            }

            constitution={
              constitution
            }

            discoveries={
              discoveries
            }

            stats={
              computedStats
            }

            knowledgeScore={
              knowledgeScore
            }

            marketFeedConnected={
              marketFeedConnected
            }

            marketFeedLoading={
              marketFeedLoading
            }

            marketFeedError={
              marketFeedError
            }

            marketLastUpdated={
              marketLastUpdated
            }

            onNavigate={(
              tab
            ) =>
              setActiveTab(
                tab
              )
            }

            onSelectDiscoveryForDecision={
              handleSelectDiscoveryForDecision
            }

            onOpenConstitution={() =>
              setIsConstitutionModalOpen(
                true
              )
            }

            onToggleStandDown={
              handleToggleStandDown
            }
          />
        )}

        {activeTab ===
          'discover' && (
          <DiscoverView
            discoveries={
              discoveries
            }

            onSelectForDecision={
              handleSelectDiscoveryForDecision
            }

            onNavigate={(
              tab
            ) =>
              setActiveTab(
                tab
              )
            }
          />
        )}

        {activeTab ===
          'decision' && (
          <DecisionEngineView
            constitution={
              constitution
            }

            initialStock={
              selectedStockForDecision
            }

            onLogTradeToJournal={
              handleLogTrade
            }

            onNavigate={(
              tab
            ) =>
              setActiveTab(
                tab
              )
            }

            onOpenConstitution={() =>
              setIsConstitutionModalOpen(
                true
              )
            }
          />
        )}

        {activeTab ===
          'journal' && (
          <JournalView
            trades={
              trades
            }

            stats={
              computedStats
            }

            constitution={
              constitution
            }

            onAddTrade={
              handleLogTrade
            }

            onNavigateToAnalytics={() =>
              setActiveTab(
                'analytics'
              )
            }
          />
        )}

        {activeTab ===
          'analytics' && (
          <AnalyticsView
            stats={
              computedStats
            }

            trades={
              trades
            }

            leaks={
              leaks
            }

            constitution={
              constitution
            }

            onApplyLeakFixToConstitution={
              handleApplyLeakFixToConstitution
            }

            onNavigate={(
              tab
            ) =>
              setActiveTab(
                tab
              )
            }
          />
        )}

        {activeTab ===
          'academy' && (
          <AcademyView
            lessons={
              lessons
            }

            knowledgeScore={
              knowledgeScore
            }

            onCompleteLesson={
              handleCompleteLesson
            }

            onOpenPractice={() =>
              setActiveTab(
                'practice'
              )
            }
          />
        )}

        {activeTab ===
          'practice' && (
          <PracticeSimulatorView
            scenarios={
              initialPracticeScenarios
            }

            onEarnPracticePoints={
              handleEarnPracticePoints
            }

            onNavigateBack={() =>
              setActiveTab(
                'academy'
              )
            }
          />
        )}

        {activeTab ===
          'brokers' && (
          <BrokersView
            brokers={
              brokers
            }

            onToggleConnect={
              handleToggleBroker
            }

            onClose={() =>
              setActiveTab(
                'home'
              )
            }
          />
        )}

      </main>

      <BottomNav
        activeTab={
          activeTab
        }

        onSelectTab={(
          tab
        ) =>
          setActiveTab(
            tab
          )
        }

        decisionBadgeCount={
          selectedStockForDecision
            ? 1
            : 0
        }
      />

      <ConstitutionModal
        isOpen={
          isConstitutionModalOpen
        }

        onClose={() =>
          setIsConstitutionModalOpen(
            false
          )
        }

        constitution={
          constitution
        }

        onSaveConstitution={
          handleSaveConstitution
        }
      />

      <TraderProfileModal
        isOpen={
          isProfileModalOpen
        }

        onClose={() =>
          setIsProfileModalOpen(
            false
          )
        }

        knowledgeScore={
          knowledgeScore
        }

        constitution={
          constitution
        }

        onResetData={
          handleResetData
        }
      />
    </div>
  );
}