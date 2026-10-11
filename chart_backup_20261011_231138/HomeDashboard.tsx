import React, { useEffect, useState } from 'react';
import {
  TrendingUp,
  TrendingDown,
  ShieldCheck,
  AlertOctagon,
  Sparkles,
  ChevronRight,
  Clock,
  Activity,
  BarChart2,
  CheckCircle2,
  AlertTriangle,
  ArrowRight,
  Flame,
  PauseCircle,
  HelpCircle,
  RefreshCw,
  Lightbulb,
  Layers,
  Compass,
  Cpu,
  BookOpen,
} from 'lucide-react';
import {
  MarketIndex,
  MarketBreadth,
  SectorMovement,
  MarketIntelligence,
  TradingConstitution,
  StockDiscovery,
  PerformanceStats,
  TraderKnowledgeScore,
  NavigationTab,
} from '../types';
import { fetchMarketBriefWithAI } from '../services/geminiService';
import { TradingChart } from './TradingChart';

interface HomeDashboardProps {
  indices: MarketIndex[];
  breadth: MarketBreadth;
  sectors: SectorMovement[];
  marketIntel: MarketIntelligence;
  constitution: TradingConstitution;
  discoveries: StockDiscovery[];
  stats: PerformanceStats;
  knowledgeScore: TraderKnowledgeScore;
  onNavigate: (tab: NavigationTab) => void;
  onSelectDiscoveryForDecision: (stock: StockDiscovery) => void;
  onOpenConstitution: () => void;
  onToggleStandDown: () => void;
  marketFeedConnected: boolean;
  marketFeedLoading: boolean;
  marketFeedError: string | null;
  marketLastUpdated: Date | null;
}

const getLocalDateString = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
};

export const HomeDashboard: React.FC<HomeDashboardProps> = ({
  indices,
  breadth,
  sectors,
  marketIntel,
  constitution,
  discoveries,
  stats,
  knowledgeScore,
  onNavigate,
  onSelectDiscoveryForDecision,
  onOpenConstitution,
  onToggleStandDown,
  marketFeedConnected,
  marketFeedLoading,
  marketFeedError,
  marketLastUpdated,
}) => {
  const [aiBrief, setAiBrief] = useState<string>(marketIntel.preMarketSummary);
  const [isAiLoading, setIsAiLoading] = useState(false);
  const [expandedSection, setExpandedSection] = useState<'levels' | 'events' | null>('levels');

  const hasLiveMarketData = marketFeedConnected && indices.length > 0;

  const todayDate = getLocalDateString(new Date());

  useEffect(() => {
    setAiBrief(
      hasLiveMarketData
        ? marketIntel.preMarketSummary
        : 'Live market data is unavailable. Connect the market feed before relying on current market values.'
    );
  }, [hasLiveMarketData, marketIntel.preMarketSummary]);

  const isNoTradeDay =
    constitution.standDownActive ||
    !marketIntel.marketStatus ||
    marketIntel.marketStatus === 'closed' ||
    constitution.currentDailyLoss >= constitution.maxDailyLoss ||
    constitution.currentDailyTrades >= constitution.maxDailyTrades ||
    !hasLiveMarketData ||
    marketIntel.readinessScore < 50;

  const handleRefreshAiBrief = async () => {
    if (!hasLiveMarketData) return;

    setIsAiLoading(true);

    const res = await fetchMarketBriefWithAI(
      {
        breadth: `Adv ${breadth.advancing} / Dec ${breadth.declining}`,
        topSectors: 'IT & Auto Leading',
      },
      {
        nifty: indices[0],
        sensex: indices[1],
        vix: indices[3],
      }
    );

    if (res.success && res.brief) {
      setAiBrief(res.brief);
    }

    setIsAiLoading(false);
  };

  return (
    <div className="space-y-4 sm:space-y-5 pb-24 max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 animate-fadeIn">

      {/* 1. TOP MARKET STATUS & COUNTDOWN BAR */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 p-3 sm:p-3.5 bg-white border border-slate-200/90 rounded-2xl shadow-2xs">
        <div className="flex items-center gap-2">
          <span className="relative flex h-2.5 w-2.5">
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${
                hasLiveMarketData && marketIntel.marketStatus === 'open'
                  ? 'bg-emerald-400'
                  : 'bg-slate-300'
              }`}
            />
            <span
              className={`relative inline-flex rounded-full h-2.5 w-2.5 ${
                hasLiveMarketData && marketIntel.marketStatus === 'open'
                  ? 'bg-emerald-500'
                  : 'bg-slate-400'
              }`}
            />
          </span>

          <span className="text-xs font-bold text-slate-900 uppercase tracking-wider">
            {hasLiveMarketData ? 'NSE / BSE Live Session' : 'NSE / BSE Feed Offline'}
          </span>

          <span className="text-slate-300">•</span>

          <span className="text-xs text-slate-500 font-medium">
            {hasLiveMarketData
              ? marketIntel.countdownText
              : marketFeedLoading
              ? 'Connecting to live feed…'
              : 'Feed offline'}
          </span>
        </div>

        <div className="flex items-center gap-2 text-xs font-medium text-slate-600">
          <span className="hidden sm:inline">FII/DII Net Flow:</span>
          <span className="px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-800 font-mono text-[11px] font-bold border border-emerald-200">
            {breadth.fiiFlow}
          </span>
        </div>
      </div>

      {!hasLiveMarketData && (
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 p-3.5 rounded-2xl border border-amber-200 bg-amber-50/70">
          <div className="flex items-start gap-2.5">
            <AlertTriangle className="w-4 h-4 text-amber-700 mt-0.5 shrink-0" />

            <div>
              <p className="text-xs font-bold text-amber-950">
                Live market feed is offline
              </p>

              <p className="text-[11px] text-amber-900/80 mt-0.5">
                Quanttora is not displaying cached or fabricated market values.
                Connect the backend market feed to continue.
              </p>

              {marketFeedError && (
                <p className="text-[10px] text-amber-800/80 mt-1 font-mono">
                  {marketFeedError}
                </p>
              )}
            </div>
          </div>

          {marketLastUpdated && (
            <span className="text-[10px] text-slate-500 font-mono shrink-0">
              Last live update: {marketLastUpdated.toLocaleTimeString()}
            </span>
          )}
        </div>
      )}

      {/* 2. THE SIGNATURE: TRADING READINESS SCORE CARD */}
      <div
        className={`p-4 sm:p-5 rounded-2xl border transition-all ${
          isNoTradeDay
            ? 'bg-gradient-to-br from-rose-50/80 via-white to-amber-50/50 border-rose-200 shadow-xs'
            : marketIntel.readinessScore >= 80
            ? 'bg-gradient-to-br from-emerald-50/60 via-white to-indigo-50/40 border-emerald-200/80 shadow-xs'
            : 'bg-gradient-to-br from-amber-50/60 via-white to-slate-50 border-amber-200 shadow-xs'
        }`}
      >
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">

          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-xs uppercase font-extrabold tracking-wider text-slate-500">
                Today's Trading Readiness
              </span>

              <span
                className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-full border ${
                  isNoTradeDay
                    ? 'bg-rose-100 text-rose-800 border-rose-300'
                    : marketIntel.readinessScore >= 80
                    ? 'bg-emerald-100 text-emerald-800 border-emerald-300'
                    : 'bg-amber-100 text-amber-800 border-amber-300'
                }`}
              >
                {isNoTradeDay
                  ? 'NO-TRADE DAY RECOMMENDED'
                  : marketIntel.readinessScore >= 80
                  ? 'FAVORABLE CONDITIONS'
                  : 'SELECTIVE DISCIPLINE'}
              </span>
            </div>

            <div className="flex items-baseline gap-3">
              <span className="text-3xl sm:text-4xl font-extrabold tracking-tight font-mono text-slate-900">
                {constitution.standDownActive ? '00' : marketIntel.readinessScore}
                <span className="text-lg sm:text-xl font-medium text-slate-400">
                  /100
                </span>
              </span>

              <p className="text-xs sm:text-sm text-slate-600 max-w-lg">
                {isNoTradeDay
                  ? 'Conditions are not favorable for active execution. Consider declaring a No-Trade Stand Down to protect capital.'
                  : marketIntel.recommendationSummary}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 w-full md:w-auto shrink-0">
            <button
              onClick={onToggleStandDown}
              className={`flex-1 md:flex-initial px-4 py-2.5 rounded-xl text-xs font-bold transition-all shadow-xs flex items-center justify-center gap-1.5 ${
                constitution.standDownActive
                  ? 'bg-emerald-600 text-white hover:bg-emerald-700'
                  : 'bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100'
              }`}
            >
              <PauseCircle className="w-4 h-4" />
              <span>
                {constitution.standDownActive
                  ? 'Lift Stand-Down'
                  : 'Declare Stand Down'}
              </span>
            </button>

            <button
              onClick={() => onNavigate('decision')}
              className="flex-1 md:flex-initial px-4 py-2.5 rounded-xl text-xs font-bold bg-indigo-600 text-white hover:bg-indigo-700 transition-all shadow-xs flex items-center justify-center gap-1.5"
            >
              <Cpu className="w-4 h-4" />
              <span>Test Setup</span>
            </button>
          </div>
        </div>

        <div className="mt-4 pt-3.5 border-t border-slate-200/80 grid grid-cols-2 sm:grid-cols-5 gap-2 text-xs">
          <div className="flex items-center justify-between p-2 rounded-lg bg-white/80 border border-slate-200/60">
            <span className="text-slate-600">Market Environment</span>
            {marketIntel.readinessFactors.marketEnvironment ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            ) : (
              <AlertTriangle className="w-4 h-4 text-amber-600" />
            )}
          </div>

          <div className="flex items-center justify-between p-2 rounded-lg bg-white/80 border border-slate-200/60">
            <span className="text-slate-600">Volatility (VIX)</span>
            {marketIntel.readinessFactors.volatility ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            ) : (
              <AlertTriangle className="w-4 h-4 text-amber-600" />
            )}
          </div>

          <div className="flex items-center justify-between p-2 rounded-lg bg-white/80 border border-slate-200/60">
            <span className="text-slate-600">Strategy Match</span>
            {marketIntel.readinessFactors.strategyConditions ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            ) : (
              <AlertTriangle className="w-4 h-4 text-amber-600" />
            )}
          </div>

          <div className="flex items-center justify-between p-2 rounded-lg bg-white/80 border border-slate-200/60">
            <span className="text-slate-600">Risk Capacity</span>
            {marketIntel.readinessFactors.riskCapacity ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            ) : (
              <AlertTriangle className="w-4 h-4 text-amber-600" />
            )}
          </div>

          <div className="col-span-2 sm:col-span-1 flex items-center justify-between p-2 rounded-lg bg-white/80 border border-slate-200/60">
            <span className="text-slate-600">Constitution</span>
            {constitution.standDownActive ? (
              <AlertOctagon className="w-4 h-4 text-rose-600" />
            ) : (
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            )}
          </div>
        </div>
      </div>

      {/* 3. INDIAN INDICES CARDS & VOLATILITY */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-2.5 sm:gap-3">
        {!hasLiveMarketData ? (
          <div className="col-span-2 lg:col-span-4 p-6 bg-white rounded-2xl border border-slate-200 shadow-2xs text-center">
            <Activity className="w-5 h-5 mx-auto text-slate-400" />
            <p className="mt-2 text-xs font-bold text-slate-700">
              Waiting for live index quotes
            </p>
            <p className="mt-1 text-[11px] text-slate-500">
              No market values are shown until the backend feed provides current quotes.
            </p>
          </div>
        ) : (
          indices.map((idx) => {
            const isVix = idx.symbol === 'INDIA VIX';

            return (
              <div
                key={idx.symbol}
                className="p-3.5 bg-white rounded-2xl border border-slate-200/90 shadow-2xs hover:border-slate-300 transition-all flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-800">
                      {idx.symbol}
                    </span>

                    <span
                      className={`text-[11px] font-bold font-mono px-1.5 py-0.5 rounded flex items-center gap-0.5 ${
                        idx.isPositive
                          ? 'bg-emerald-50 text-emerald-700'
                          : isVix
                          ? 'bg-emerald-50 text-emerald-700'
                          : 'bg-rose-50 text-rose-700'
                      }`}
                    >
                      {idx.isPositive ? (
                        <TrendingUp className="w-3 h-3" />
                      ) : (
                        <TrendingDown className="w-3 h-3" />
                      )}
                      {idx.changePercent > 0 ? '+' : ''}
                      {idx.changePercent}%
                    </span>
                  </div>

                  <div className="mt-1">
                    <span className="text-lg sm:text-xl font-bold font-mono text-slate-900">
                      {(idx.value ?? 0).toLocaleString('en-IN', {
                        minimumFractionDigits: 2,
                      })}
                    </span>
                  </div>
                </div>

                <div className="mt-2 pt-2 border-t border-slate-100 text-[10.5px] text-slate-500 flex justify-between font-mono">
                  <span>L: {(idx.low ?? 0).toLocaleString('en-IN')}</span>
                  <span>H: {(idx.high ?? 0).toLocaleString('en-IN')}</span>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* 4. REAL NIFTY 50 TRADING CHART */}
      {hasLiveMarketData && (
        <div className="p-4 sm:p-5 bg-white rounded-2xl border border-slate-200 shadow-2xs">
          <TradingChart
            instrumentKey="NSE_INDEX|Nifty 50"
            symbol="NIFTY 50"
            fromDate={todayDate}
            toDate={todayDate}
            height={420}
          />
        </div>
      )}

      {/* 5. MARKET BREADTH & SECTOR STRENGTH ROW */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5 sm:gap-4">

        <div className="p-4 bg-white rounded-2xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <BarChart2 className="w-4 h-4 text-indigo-600" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                Market Breadth (NSE 500)
              </h3>
            </div>

            <span className="text-[11px] font-mono text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded font-semibold">
              Adv/Dec{' '}
              {breadth.advancing + breadth.declining > 0
                ? (
                    breadth.advancing /
                    Math.max(breadth.declining, 1)
                  ).toFixed(2)
                : '—'}
              x
            </span>
          </div>

          <div className="space-y-1.5">
            <div className="h-3 rounded-full bg-slate-100 overflow-hidden flex">
              <div
                style={{
                  width: `${
                    breadth.advancing + breadth.declining > 0
                      ? (breadth.advancing /
                          (breadth.advancing + breadth.declining)) *
                        100
                      : 0
                  }%`,
                }}
                className="bg-emerald-500"
              />

              <div
                style={{
                  width: `${
                    breadth.advancing + breadth.declining > 0
                      ? (breadth.declining /
                          (breadth.advancing + breadth.declining)) *
                        100
                      : 0
                  }%`,
                }}
                className="bg-rose-500"
              />
            </div>

            <div className="flex justify-between text-xs font-medium font-mono">
              <span className="text-emerald-700">
                Advancing: {breadth.advancing}
              </span>
              <span className="text-rose-700">
                Declining: {breadth.declining}
              </span>
            </div>
          </div>

          <div className="mt-3 pt-2.5 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600">
            <span>DII Institutional Flow:</span>
            <span className="font-mono font-bold text-slate-800">
              {breadth.diiFlow}
            </span>
          </div>
        </div>

        <div className="p-4 bg-white rounded-2xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <Layers className="w-4 h-4 text-indigo-600" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                Sector Momentum
              </h3>
            </div>

            <span className="text-[11px] text-slate-500">
              {hasLiveMarketData ? 'Live sector feed' : 'Feed offline'}
            </span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
            {!hasLiveMarketData || sectors.length === 0 ? (
              <div className="col-span-2 sm:col-span-3 p-3 rounded-xl bg-slate-50 border border-slate-200 text-center text-[11px] text-slate-500">
                Sector momentum will appear when live sector data is available.
              </div>
            ) : (
              sectors.map((sec) => (
                <div
                  key={sec.name}
                  className={`p-2 rounded-xl border text-xs flex flex-col justify-between ${
                    sec.status === 'bullish'
                      ? 'bg-emerald-50/60 border-emerald-200/80 text-emerald-950'
                      : sec.status === 'bearish'
                      ? 'bg-rose-50/60 border-rose-200/80 text-rose-950'
                      : 'bg-slate-50 border-slate-200 text-slate-800'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="font-semibold truncate">
                      {sec.name.replace('Nifty ', '')}
                    </span>
                    <span className="font-mono text-[11px] font-bold">
                      {sec.changePercent > 0 ? '+' : ''}
                      {sec.changePercent}%
                    </span>
                  </div>

                  <span className="text-[10px] text-slate-500 truncate mt-1">
                    Lead: {sec.leader}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* 6. PRE-MARKET INTELLIGENCE & AI TRADER PREP BRIEF */}
      <div className="p-4 sm:p-5 bg-white rounded-2xl border border-slate-200 shadow-2xs space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-indigo-50 text-indigo-700">
              <Sparkles className="w-4 h-4" />
            </div>

            <div>
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800">
                Trader Pre-Market Intelligence Brief
              </h3>
              <p className="text-[11px] text-slate-500">
                "What matters for today's trading environment?"
              </p>
            </div>
          </div>

          <button
            onClick={handleRefreshAiBrief}
            disabled={isAiLoading || !hasLiveMarketData}
            className="flex items-center gap-1 text-xs font-semibold px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 transition-all"
          >
            <RefreshCw
              className={`w-3 h-3 ${isAiLoading ? 'animate-spin' : ''}`}
            />
            <span className="hidden sm:inline">
              {hasLiveMarketData ? 'Refresh AI Brief' : 'Feed Offline'}
            </span>
          </button>
        </div>

        <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-xs sm:text-sm text-slate-800 leading-relaxed font-normal">
          {aiBrief}
        </div>

        <div className="pt-2 border-t border-slate-100 flex flex-wrap gap-2 text-xs">
          <button
            onClick={() =>
              setExpandedSection(
                expandedSection === 'levels' ? null : 'levels'
              )
            }
            className={`px-3 py-1.5 rounded-lg font-semibold border transition-all ${
              expandedSection === 'levels'
                ? 'bg-indigo-50 text-indigo-700 border-indigo-200'
                : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
            }`}
          >
            Key Support & Resistance Levels
          </button>

          <button
            onClick={() =>
              setExpandedSection(
                expandedSection === 'events' ? null : 'events'
              )
            }
            className={`px-3 py-1.5 rounded-lg font-semibold border transition-all ${
              expandedSection === 'events'
                ? 'bg-indigo-50 text-indigo-700 border-indigo-200'
                : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
            }`}
          >
            Macro Events ({marketIntel.importantEvents.length})
          </button>
        </div>

        {expandedSection === 'levels' && (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-3 bg-slate-50/70 rounded-xl border border-slate-200 text-xs">
            <div>
              <span className="font-bold text-slate-900 block mb-1">
                NIFTY 50 Critical Levels
              </span>

              <div className="flex justify-between py-1 border-b border-slate-200/60 font-mono">
                <span className="text-slate-600">Major Resistance:</span>
                <span className="font-bold text-rose-700">
                  {marketIntel.keyLevels.niftyResistance.length
                    ? marketIntel.keyLevels.niftyResistance.join(', ')
                    : 'Unavailable'}
                </span>
              </div>

              <div className="flex justify-between py-1 font-mono">
                <span className="text-slate-600">Major Support:</span>
                <span className="font-bold text-emerald-700">
                  {marketIntel.keyLevels.niftySupport.length
                    ? marketIntel.keyLevels.niftySupport.join(', ')
                    : 'Unavailable'}
                </span>
              </div>
            </div>

            <div>
              <span className="font-bold text-slate-900 block mb-1">
                BANK NIFTY Critical Levels
              </span>

              <div className="flex justify-between py-1 border-b border-slate-200/60 font-mono">
                <span className="text-slate-600">Major Resistance:</span>
                <span className="font-bold text-rose-700">
                  {marketIntel.keyLevels.bankNiftyResistance.length
                    ? marketIntel.keyLevels.bankNiftyResistance.join(', ')
                    : 'Unavailable'}
                </span>
              </div>

              <div className="flex justify-between py-1 font-mono">
                <span className="text-slate-600">Major Support:</span>
                <span className="font-bold text-emerald-700">
                  {marketIntel.keyLevels.bankNiftySupport.length
                    ? marketIntel.keyLevels.bankNiftySupport.join(', ')
                    : 'Unavailable'}
                </span>
              </div>
            </div>
          </div>
        )}

        {expandedSection === 'events' && (
          <div className="space-y-2 p-3 bg-slate-50/70 rounded-xl border border-slate-200 text-xs">
            {marketIntel.importantEvents.length === 0 ? (
              <div className="text-[11px] text-slate-500">
                No live macro events supplied by the market-intelligence feed.
              </div>
            ) : (
              marketIntel.importantEvents.map((evt, i) => (
                <div
                  key={i}
                  className="flex items-start gap-2.5 py-1 border-b border-slate-200/50 last:border-0"
                >
                  <span className="px-1.5 py-0.5 rounded bg-amber-100 text-amber-900 font-mono text-[10px] font-bold shrink-0">
                    {evt.time}
                  </span>

                  <div>
                    <span className="font-bold text-slate-900 block">
                      {evt.title}
                    </span>
                    <span className="text-slate-600 text-[11px]">
                      {evt.description}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>

      {/* 7. DISCOVERY PREVIEW: POTENTIAL SETUPS WORTH ANALYZING */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800">
              Potential Setups Worth Analyzing
            </h3>
            <p className="text-[11px] text-slate-500">
              Not buy/sell recommendations — structural candidates for your Decision Engine
            </p>
          </div>

          <button
            onClick={() => onNavigate('discover')}
            className="text-xs font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
          >
            <span>View All</span>
            <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          {discoveries.slice(0, 3).map((stock) => (
            <div
              key={stock.id}
              className="p-3.5 bg-white rounded-2xl border border-slate-200 shadow-2xs hover:border-indigo-300 hover:shadow-xs transition-all flex flex-col justify-between"
            >
              <div>
                <div className="flex items-start justify-between">
                  <div>
                    <span className="font-bold text-sm text-slate-900">
                      {stock.symbol}
                    </span>
                    <span className="text-[11px] text-slate-500 block truncate">
                      {stock.companyName}
                    </span>
                  </div>

                  <span
                    className={`text-xs font-bold font-mono px-2 py-0.5 rounded-full ${
                      stock.changePercent >= 0
                        ? 'bg-emerald-50 text-emerald-700'
                        : 'bg-rose-50 text-rose-700'
                    }`}
                  >
                    {stock.changePercent > 0 ? '+' : ''}
                    {stock.changePercent}%
                  </span>
                </div>

                <div className="mt-2.5 flex items-center gap-2">
                  <span className="text-[10px] font-semibold uppercase px-2 py-0.5 rounded bg-indigo-50 text-indigo-700 border border-indigo-200/60">
                    {stock.marketStructure}
                  </span>

                  {stock.oiData && (
                    <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-slate-100 text-slate-700">
                      OI: {stock.oiData.buildup}
                    </span>
                  )}
                </div>

                <p className="text-xs text-slate-600 mt-2 line-clamp-2">
                  {stock.reasonForAnalysis}
                </p>
              </div>

              <button
                onClick={() => {
                  onSelectDiscoveryForDecision(stock);
                  onNavigate('decision');
                }}
                className="mt-3 w-full py-2 rounded-xl text-xs font-bold bg-slate-50 hover:bg-indigo-50 text-indigo-700 border border-slate-200 hover:border-indigo-200 transition-all flex items-center justify-center gap-1.5"
              >
                <span>Evaluate in Decision Engine</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* 8. BEHAVIORAL LEAK & AI DISCIPLINE ALERT */}
      <div className="p-4 bg-gradient-to-r from-amber-50/80 via-white to-slate-50 rounded-2xl border border-amber-200/90 shadow-2xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
        <div className="flex items-start gap-3">
          <div className="p-2 rounded-xl bg-amber-100 text-amber-800 shrink-0">
            <Lightbulb className="w-5 h-5" />
          </div>

          <div>
            <div className="flex items-center gap-2">
              <span className="text-xs font-extrabold uppercase tracking-wider text-amber-950">
                BEHAVIORAL LEAK DETECTED
              </span>

              <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-rose-100 text-rose-800">
                High Priority
              </span>
            </div>

            <p className="text-xs text-slate-700 mt-0.5">
              "You frequently increase trade frequency after a losing trade." —
              <span className="font-semibold text-slate-900">
                {' '}
                Recommended: Activate a 20-minute cooldown timer.
              </span>
            </p>
          </div>
        </div>

        <button
          onClick={() => onNavigate('analytics')}
          className="text-xs font-bold px-3.5 py-1.5 rounded-xl bg-white border border-amber-300 text-amber-900 hover:bg-amber-50 transition-all shrink-0"
        >
          View Analytics & Leaks
        </button>
      </div>

      {/* 9. ACADEMY & KNOWLEDGE SCORE QUICK PROGRESS */}
      <div className="p-4 bg-white rounded-2xl border border-slate-200 shadow-2xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-2xl bg-indigo-50 border border-indigo-200 text-indigo-700 flex items-center justify-center font-bold text-lg">
            {knowledgeScore.overallScore}
          </div>

          <div>
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-500">
                Quanttora Knowledge Score
              </span>

              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700">
                Discipline: 86/100
              </span>
            </div>

            <p className="text-xs text-slate-700 font-medium">
              Completed {knowledgeScore.lessonsCompleted} lessons •{' '}
              {knowledgeScore.practicePoints} Practice Points earned
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <button
            onClick={() => onNavigate('practice')}
            className="flex-1 sm:flex-initial px-3.5 py-2 rounded-xl text-xs font-bold bg-slate-100 hover:bg-slate-200 text-slate-800 transition-all"
          >
            Practice Scenarios
          </button>

          <button
            onClick={() => onNavigate('academy')}
            className="flex-1 sm:flex-initial px-4 py-2 rounded-xl text-xs font-bold bg-indigo-600 text-white hover:bg-indigo-700 transition-all flex items-center justify-center gap-1"
          >
            <BookOpen className="w-3.5 h-3.5" />
            <span>Open Academy</span>
          </button>
        </div>
      </div>
    </div>
  );
};

