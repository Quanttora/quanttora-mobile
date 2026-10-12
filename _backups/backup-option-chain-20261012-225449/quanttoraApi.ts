import {
  clearSession,
  getAuthHeaders,
} from './authService';

const API_PREFIX = '/api/proxy';

export interface MarketFeedStatus {
  connected: boolean;
  totalQuotes: number;
  [key: string]: unknown;
}

export interface MarketQuote {
  instrumentKey?: string;
  symbol?: string;
  name?: string;

  ltp?: number;
  lastPrice?: number;
  price?: number;

  change?: number;
  changePercent?: number;
  percentageChange?: number;

  open?: number;
  high?: number;
  low?: number;
  close?: number;
  previousClose?: number;

  volume?: number;
  averageTradedPrice?: number;

  timestamp?: string;
  updatedAt?: string;

  [key: string]: unknown;
}

export interface MarketCandle {
  instrumentKey?: string;
  timestamp: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  [key: string]: unknown;
}

export interface HistoricalCandlesResponse {
  success?: boolean;
  instrumentKey: string;
  interval: string;
  fromDate: string;
  toDate?: string;
  vwap?: number;
  candles: MarketCandle[];
  [key: string]: unknown;
}

export interface MarketDashboard {
  connected?: boolean;
  marketOpen?: boolean;
  indices?: Record<string, unknown>;
  sectors?: unknown[];
  sectorStrength?: Record<string, unknown>;
  breadth?: Record<string, unknown>;
  lastUpdated?: string;
  [key: string]: unknown;
}

export interface ApiResponse<T> {
  success?: boolean;
  data?: T;
  error?: {
    code?: string;
    message?: string;
  };
  message?: string;
  [key: string]: unknown;
}

interface MarketQuotesEnvelope {
  market?: MarketQuote[];
  quotes?: MarketQuote[];
  data?: MarketQuote[] | Record<string, unknown>;
  [key: string]: unknown;
}

export interface InstrumentSearchResult {
  name?: string;
  segment?: string;
  exchange?: string;
  isin?: string;
  instrument_key?: string;
  exchange_token?: string;
  trading_symbol?: string;
  short_name?: string;
  tick_size?: number;
  lot_size?: number;
  instrument_type?: string;
  expiry?: string | number;
  strike_price?: number;
  [key: string]: unknown;
}

export interface InstrumentSearchResponse {
  status?: string;
  data?: InstrumentSearchResult[];
  [key: string]: unknown;
}

interface MarketFeedSubscriptionResponse {
  success?: boolean;
  instrument?: string;
  subscriptions?: string[];
  [key: string]: unknown;
}

export interface RiskGuardRequest {
  capital: number;
  entryPrice: number;
  stopLossPrice: number;
  targetPrice: number;
  quantity: number;
  maxRiskPerTrade: number;
  maxDailyLoss: number;
  maxTradesPerDay: number;
  tradesTakenToday: number;
  dailyLossToday: number;
  minimumRiskReward: number;
}

export interface RiskGuardResult {
  allowed: boolean;
  status: string;
  passedRules: string[];
  blockedRules: string[];
  riskAmount: number;
  potentialProfit: number;
  riskReward: number;
  riskPercent: number;
  remainingDailyLossCapacity: number;
  remainingTrades: number;
}

export class QuanttoraApiError extends Error {
  status: number;
  code?: string;

  constructor(
    message: string,
    status: number,
    code?: string,
  ) {
    super(message);
    this.name = 'QuanttoraApiError';
    this.status = status;
    this.code = code;
  }
}

export function toNumber(
  value: unknown,
  fallback = 0,
): number {
  if (
    typeof value === 'number' &&
    Number.isFinite(value)
  ) {
    return value;
  }

  if (typeof value === 'string') {
    const parsed = Number(value);

    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return fallback;
}

function toStringValue(
  value: unknown,
  fallback = '',
): string {
  if (
    typeof value === 'string' &&
    value.trim().length > 0
  ) {
    return value;
  }

  if (
    typeof value === 'number' ||
    typeof value === 'boolean'
  ) {
    return String(value);
  }

  return fallback;
}

function asRecord(
  value: unknown,
): Record<string, unknown> {
  if (
    value &&
    typeof value === 'object' &&
    !Array.isArray(value)
  ) {
    return value as Record<string, unknown>;
  }

  return {};
}

function getOhlc(
  quote: Record<string, unknown>,
): Record<string, unknown> {
  return asRecord(quote.ohlc);
}

function normalizeMarketQuote(
  value: unknown,
  fallbackInstrumentKey?: string,
): MarketQuote {
  const quote = asRecord(value);
  const ohlc = getOhlc(quote);

  const instrumentKey =
    toStringValue(
      quote.instrumentKey ??
        quote.instrument_key ??
        quote.instrument_token,
      fallbackInstrumentKey || '',
    );

  const symbol =
    toStringValue(
      quote.symbol ??
        quote.trading_symbol,
      '',
    );

  const lastPrice = toNumber(
    quote.last_price ??
      quote.lastPrice ??
      quote.ltp ??
      quote.LTP ??
      quote.price,
    0,
  );

  const previousClose = toNumber(
    quote.prev_close_price ??
      quote.previousClose ??
      quote.previous_close ??
      quote.cp ??
      ohlc.close,
    0,
  );

  const change = toNumber(
    quote.net_change ??
      quote.change,
    lastPrice - previousClose,
  );

  const changePercent = toNumber(
    quote.change_percent ??
      quote.changePercent ??
      quote.percentageChange,
    previousClose > 0
      ? (change / previousClose) * 100
      : 0,
  );

  const open = toNumber(
    quote.open ??
      ohlc.open,
    0,
  );

  const high = toNumber(
    quote.high ??
      ohlc.high,
    0,
  );

  const low = toNumber(
    quote.low ??
      ohlc.low,
    0,
  );

  const close = toNumber(
    quote.close ??
      ohlc.close,
    0,
  );

  const volume = toNumber(
    quote.volume ??
      ohlc.volume,
    0,
  );

  const averageTradedPrice = toNumber(
    quote.average_price ??
      quote.averagePrice ??
      quote.atp,
    0,
  );

  const timestamp =
    toStringValue(
      quote.timestamp ??
        quote.updatedAt,
      '',
    );

  return {
    ...quote,

    instrumentKey:
      instrumentKey || fallbackInstrumentKey,

    symbol,

    ltp: lastPrice,
    lastPrice,
    price: lastPrice,

    change,
    changePercent,
    percentageChange: changePercent,

    open,
    high,
    low,
    close,
    previousClose,

    volume,
    averageTradedPrice,

    timestamp: timestamp || undefined,
    updatedAt: timestamp || undefined,
  };
}

function extractQuoteRecords(
  response: unknown,
): MarketQuote[] {
  let payload: unknown = response;

  if (
    payload &&
    typeof payload === 'object' &&
    'data' in payload
  ) {
    const data =
      (payload as {
        data?: unknown;
      }).data;

    if (data !== undefined) {
      payload = data;
    }
  }

  if (Array.isArray(payload)) {
    return payload.map((item) =>
      normalizeMarketQuote(item),
    );
  }

  const record = asRecord(payload);

  const directArrays = [
    record.market,
    record.quotes,
    record.items,
  ];

  for (const candidate of directArrays) {
    if (Array.isArray(candidate)) {
      return candidate.map((item) =>
        normalizeMarketQuote(item),
      );
    }
  }

  return Object.entries(record)
    .filter(([, value]) =>
      Boolean(
        value &&
          typeof value === 'object' &&
          !Array.isArray(value),
      ),
    )
    .map(([key, value]) => {
      const quote = asRecord(value);

      const instrumentKey =
        toStringValue(
          quote.instrumentKey ??
            quote.instrument_key ??
            quote.instrument_token,
          key.replace(':', '|'),
        );

      return normalizeMarketQuote(
        quote,
        instrumentKey,
      );
    });
}

function extractSingleQuote(
  response: unknown,
  instrumentKey: string,
): MarketQuote | null {
  let payload: unknown = response;

  if (
    payload &&
    typeof payload === 'object' &&
    'data' in payload
  ) {
    const data =
      (payload as {
        data?: unknown;
      }).data;

    if (data !== undefined) {
      payload = data;
    }
  }

  if (Array.isArray(payload)) {
    if (payload.length === 0) {
      return null;
    }

    return normalizeMarketQuote(
      payload[0],
      instrumentKey,
    );
  }

  const record = asRecord(payload);

  const possibleKeys = [
    instrumentKey,
    instrumentKey.replace('|', ':'),
  ];

  for (const key of possibleKeys) {
    const candidate = record[key];

    if (
      candidate &&
      typeof candidate === 'object' &&
      !Array.isArray(candidate)
    ) {
      return normalizeMarketQuote(
        candidate,
        instrumentKey,
      );
    }
  }

  const directQuoteFields = [
    'last_price',
    'lastPrice',
    'ltp',
    'LTP',
    'price',
  ];

  if (
    directQuoteFields.some(
      (key) => key in record,
    )
  ) {
    return normalizeMarketQuote(
      record,
      instrumentKey,
    );
  }

  const entries = Object.entries(record);

  for (const [, value] of entries) {
    if (
      !value ||
      typeof value !== 'object' ||
      Array.isArray(value)
    ) {
      continue;
    }

    const candidate =
      value as Record<string, unknown>;

    const candidateInstrument =
      candidate.instrument_token ??
      candidate.instrumentKey ??
      candidate.instrument_key;

    if (
      candidateInstrument === instrumentKey
    ) {
      return normalizeMarketQuote(
        candidate,
        instrumentKey,
      );
    }
  }

  if (entries.length === 1) {
    const value = entries[0][1];

    if (
      value &&
      typeof value === 'object' &&
      !Array.isArray(value)
    ) {
      return normalizeMarketQuote(
        value,
        instrumentKey,
      );
    }
  }

  return null;
}

async function request<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  let response: Response;

  try {
    response = await fetch(
      `${API_PREFIX}${path}`,
      {
        ...options,
        headers: {
          Accept: 'application/json',

          ...(options.body
            ? {
                'Content-Type':
                  'application/json',
              }
            : {}),

          ...getAuthHeaders(),

          ...(options.headers || {}),
        },

        credentials: 'same-origin',
      },
    );
  } catch {
    throw new QuanttoraApiError(
      'Quanttora backend is not reachable. Start the Dart backend on port 8080.',
      0,
    );
  }

  const contentType =
    response.headers.get(
      'content-type',
    ) || '';

  let payload: unknown;

  if (
    contentType.includes(
      'application/json',
    )
  ) {
    payload = await response.json();
  } else {
    const text =
      await response.text();

    payload = text || null;
  }

  if (!response.ok) {
    const errorPayload =
      payload &&
      typeof payload === 'object'
        ? (payload as ApiResponse<unknown>)
        : null;

    const message =
      errorPayload?.error?.message ||
      errorPayload?.message ||
      (
        response.status === 401
          ? 'Your Quanttora session has expired. Please sign in again.'
          : `Quanttora backend request failed (${response.status})`
      );

    if (response.status === 401) {
      clearSession();
    }

    throw new QuanttoraApiError(
      message,
      response.status,
      errorPayload?.error?.code,
    );
  }

  return payload as T;
}

function unwrap<T>(
  response: T | ApiResponse<T>,
): T {
  if (
    response &&
    typeof response === 'object' &&
    'data' in response
  ) {
    const data =
      (response as ApiResponse<T>)
        .data;

    if (data !== undefined) {
      return data;
    }
  }

  return response as T;
}

export async function getMarketStatus(): Promise<MarketFeedStatus> {
  const response =
    await request<MarketFeedStatus>(
      '/market/status',
    );

  return unwrap(response);
}

export async function getMarketDashboard(): Promise<MarketDashboard> {
  const response =
    await request<MarketDashboard>(
      '/market/dashboard',
    );

  return unwrap(response);
}

export async function getMarketQuotes(
  instrumentKeys?: string[],
): Promise<MarketQuote[]> {
  const params =
    new URLSearchParams();

  if (
    instrumentKeys &&
    instrumentKeys.length > 0
  ) {
    params.set(
      'instrumentKeys',
      instrumentKeys.join(','),
    );
  }

  const query =
    params.toString();

  const response =
    await request<MarketQuotesEnvelope>(
      `/broker/quotes${query ? `?${query}` : ''}`,
    );

  return extractQuoteRecords(response);
}

export async function getMarketQuote(
  instrumentKey: string,
): Promise<MarketQuote> {
  const params =
    new URLSearchParams({
      instrumentKey,
    });

  const response =
    await request<unknown>(
      `/broker/quotes?${params.toString()}`,
    );

  const quote =
    extractSingleQuote(
      response,
      instrumentKey,
    );

  if (!quote) {
    throw new QuanttoraApiError(
      `Live quote was not found for ${instrumentKey}.`,
      200,
    );
  }

  return quote;
}

export async function subscribeMarketFeed(
  instrumentKey: string,
): Promise<MarketFeedSubscriptionResponse> {
  const params =
    new URLSearchParams({
      instrumentKey,
    });

  return request<MarketFeedSubscriptionResponse>(
    `/broker/market-feed/subscribe?${params.toString()}`,
    {
      method: 'POST',
    },
  );
}

export async function searchInstruments(
  query: string,
  options: {
    exchanges?: string;
    segments?: string;
    instrumentTypes?: string;
    expiry?: string;
    atmOffset?: number;
    pageNumber?: number;
    records?: number;
  } = {},
): Promise<InstrumentSearchResult[]> {
  const params =
    new URLSearchParams();

  params.set(
    'query',
    query.trim(),
  );

  params.set(
    'exchanges',
    options.exchanges || 'NSE',
  );

  params.set(
    'segments',
    options.segments || 'EQ',
  );

  params.set(
    'pageNumber',
    String(
      options.pageNumber || 1,
    ),
  );

  params.set(
    'records',
    String(
      options.records || 30,
    ),
  );

  if (
    options.instrumentTypes
  ) {
    params.set(
      'instrumentTypes',
      options.instrumentTypes,
    );
  }

  if (options.expiry) {
    params.set(
      'expiry',
      options.expiry,
    );
  }

  if (
    options.atmOffset !== undefined
  ) {
    params.set(
      'atmOffset',
      String(options.atmOffset),
    );
  }

  const response =
    await request<InstrumentSearchResponse>(
      `/broker/instruments/search?${params.toString()}`,
    );

  const data =
    unwrap(response);

  if (
    Array.isArray(data)
  ) {
    return data;
  }

  if (
    data &&
    typeof data === 'object' &&
    Array.isArray(
      (data as InstrumentSearchResponse)
        .data,
    )
  ) {
    return (
      data as InstrumentSearchResponse
    ).data || [];
  }

  return [];
}

export async function getHistoricalCandles(
  instrumentKey: string,
  interval: string,
  fromDate: string,
  toDate: string,
): Promise<HistoricalCandlesResponse> {
  const params =
    new URLSearchParams({
      instrumentKey,
      interval,
      fromDate,
      toDate,
    });

  const response =
    await request<unknown>(
      `/broker/history?${params.toString()}`,
    );

  const payload =
    unwrap(response);

  const record =
    asRecord(payload);

  const rawCandles =
    Array.isArray(record.candles)
      ? record.candles
      : [];

  const candles: MarketCandle[] =
    rawCandles
      .map((candle) => {
        if (Array.isArray(candle)) {
          return {
            instrumentKey,
            timestamp:
              String(candle[0] ?? ''),
            open:
              toNumber(candle[1]),
            high:
              toNumber(candle[2]),
            low:
              toNumber(candle[3]),
            close:
              toNumber(candle[4]),
            volume:
              toNumber(candle[5]),
          };
        }

        const item =
          asRecord(candle);

        return {
          ...item,

          instrumentKey:
            toStringValue(
              item.instrumentKey ??
                item.instrument_key,
              instrumentKey,
            ),

          timestamp:
            toStringValue(
              item.timestamp ??
                item.time ??
                item.ts,
              '',
            ),

          open:
            toNumber(item.open),

          high:
            toNumber(item.high),

          low:
            toNumber(item.low),

          close:
            toNumber(item.close),

          volume:
            toNumber(item.volume),
        };
      })
      .filter(
        (candle) =>
          candle.timestamp.length > 0,
      );

  return {
    ...record,

    success:
      typeof record.success ===
      'boolean'
        ? record.success
        : true,

    instrumentKey,

    interval,

    fromDate,

    toDate,

    vwap:
      toNumber(
        record.vwap,
        0,
      ),

    candles,
  };
}

export async function evaluateRiskGuard(
  requestData: RiskGuardRequest,
): Promise<RiskGuardResult> {
  const response =
    await request<RiskGuardResult>(
      '/risk-guard/evaluate',
      {
        method: 'POST',
        body: JSON.stringify(requestData),
      },
    );

  return unwrap(response);
}
// ============================================================
// BROKER PORTFOLIO API — QUANTTORA WEBSITE
// ============================================================

export interface BrokerApiResult {
  success?: boolean;
  connected?: boolean;
  broker?: string;
  data?: unknown;
  error?: {
    code?: string;
    message?: string;
  };
  [key: string]: unknown;
}

export async function getZerodhaPortfolio(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/dashboard');
}

export async function getZerodhaFunds(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/funds');
}

export async function getZerodhaHoldings(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/holdings');
}

export async function getZerodhaPositions(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/positions');
}

export async function getZerodhaOrders(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/orders');
}

export async function getZerodhaTrades(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/trades');
}

export async function getConnectedBrokerStatus(): Promise<BrokerApiResult> {
  return request<BrokerApiResult>('/broker/status');
}
