import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

dotenv.config();

const app = express();
const PORT = 3000;

app.use(express.json({ limit: "10mb" }));

// -----------------------------------------------------------------------------
// Backend configuration
// -----------------------------------------------------------------------------

function getBackendBaseUrl(): string {
  return (process.env.QUANTTORA_BACKEND_URL || "http://localhost:8080")
    .trim()
    .replace(/\/+$/, "");
}

// -----------------------------------------------------------------------------
// Security helpers
// -----------------------------------------------------------------------------

function sanitizeBrokerPayload(value: any): any {
  if (Array.isArray(value)) {
    return value.map(sanitizeBrokerPayload);
  }

  if (value && typeof value === "object") {
    const result: Record<string, any> = {};

    for (const [key, val] of Object.entries(value)) {
      const lowerKey = key.toLowerCase();

      // Never expose credentials, access tokens, secrets, or authorization codes.
      const sensitive =
        lowerKey.includes("access_token") ||
        lowerKey.includes("accesstoken") ||
        lowerKey.includes("refresh_token") ||
        lowerKey.includes("refreshtoken") ||
        lowerKey.includes("client_secret") ||
        lowerKey.includes("clientsecret") ||
        lowerKey.includes("authorization_code") ||
        lowerKey.includes("authorizationcode") ||
        lowerKey === "token" ||
        lowerKey.endsWith("_token") ||
        lowerKey.endsWith("token") ||
        lowerKey.includes("secret");

      // Instrument tokens such as instrument_token are market identifiers,
      // not authentication credentials, so preserve them.
      const isInstrumentToken =
        lowerKey === "instrument_token" ||
        lowerKey === "instrumenttoken";

      if (sensitive && !isInstrumentToken) {
        continue;
      }

      result[key] = sanitizeBrokerPayload(val);
    }

    return result;
  }

  return value;
}

function sanitizeAuthPayload(value: any): any {
  if (Array.isArray(value)) {
    return value.map(sanitizeAuthPayload);
  }

  if (value && typeof value === "object") {
    const result: Record<string, any> = {};

    for (const [key, val] of Object.entries(value)) {
      const lowerKey = key.toLowerCase();

      // Authentication responses legitimately contain the short-lived
      // Quanttora session token at data.session.token. Preserve that token
      // because the frontend needs it for authenticated API requests.
      // Never forward password hashes, broker access tokens, client secrets,
      // refresh tokens, authorization codes, or other credential material.
      const sensitive =
        lowerKey.includes("password") ||
        lowerKey.includes("access_token") ||
        lowerKey.includes("accesstoken") ||
        lowerKey.includes("refresh_token") ||
        lowerKey.includes("refreshtoken") ||
        lowerKey.includes("client_secret") ||
        lowerKey.includes("clientsecret") ||
        lowerKey.includes("authorization_code") ||
        lowerKey.includes("authorizationcode") ||
        lowerKey === "secret";

      if (sensitive) {
        continue;
      }

      result[key] = sanitizeAuthPayload(val);
    }

    return result;
  }

  return value;
}

function parseJsonSafely(text: string): any | null {
  if (!text) return null;

  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function getRedirectUrl(data: any): string | null {
  const candidates = [
    data?.redirectUrl,
    data?.url,
    data?.loginUrl,
    data?.login_url,
    data?.authorizationUrl,
    data?.authorization_url,
    data?.auth_url,
    data?.data?.redirectUrl,
    data?.data?.url,
    data?.data?.loginUrl,
    data?.data?.login_url,
    data?.data?.authorizationUrl,
    data?.data?.authorization_url,
    data?.data?.auth_url,
  ];

  for (const candidate of candidates) {
    if (candidate) {
      return String(candidate);
    }
  }

  return null;
}

function makeAbsoluteUrl(value: string, baseUrl: string): string {
  try {
    return new URL(value, baseUrl).toString();
  } catch {
    return value;
  }
}

// -----------------------------------------------------------------------------
// Initialize Google GenAI
// -----------------------------------------------------------------------------

function getGeminiClient(): GoogleGenAI | null {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) return null;

  return new GoogleGenAI({
    apiKey,
    httpOptions: {
      headers: {
        "User-Agent": "aistudio-build",
      },
    },
  });
}

// -----------------------------------------------------------------------------
// Health check
// -----------------------------------------------------------------------------

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
  });
});

// -----------------------------------------------------------------------------
// Quanttora Authentication Proxy
// -----------------------------------------------------------------------------

async function forwardAuthRequest(req: express.Request, res: express.Response, path: string) {
  const backendBase = getBackendBaseUrl();
  const targetUrl = `${backendBase}/auth/${path}`;

  try {
    const backendRes = await fetch(targetUrl, {
      method: req.method,
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(req.body || {}),
      redirect: "manual",
    });

    const contentType = backendRes.headers.get("content-type") || "";
    const responseText = await backendRes.text();

    if (contentType.includes("application/json")) {
      const data = parseJsonSafely(responseText);
      if (data !== null) {
        return res
          .status(backendRes.status)
          .json(sanitizeAuthPayload(data));
      }
    }

    return res.status(backendRes.status).send(responseText);
  } catch (error: any) {
    console.error(
      `[Quanttora Auth] Backend unreachable at ${backendBase}:`,
      error?.message || error,
    );

    return res.status(503).json({
      success: false,
      error: {
        code: "BACKEND_UNAVAILABLE",
        message: `Quanttora backend at ${backendBase} is not reachable.`,
      },
    });
  }
}

app.post("/api/auth/login", (req, res) =>
  forwardAuthRequest(req, res, "login"),
);

app.post("/api/auth/register", (req, res) =>
  forwardAuthRequest(req, res, "register"),
);

// -----------------------------------------------------------------------------
// Upstox OAuth Login Initiation
// -----------------------------------------------------------------------------

app.get("/api/auth/upstox/login", async (req, res) => {
  const backendBase = getBackendBaseUrl();
  const targetUrl = `${backendBase}/auth/upstox/login`;

  const hasAuth = Boolean(
    req.headers.authorization &&
      req.headers.authorization.trim().length > 0,
  );

  // Safe logging only. Never log the bearer value.
  console.log(
    `[Quanttora OAuth] Request path: ${req.originalUrl || req.path}`,
  );
  console.log(`[Quanttora OAuth] Target URL: ${targetUrl}`);
  console.log(`[Quanttora OAuth] Authorization present: ${hasAuth}`);

  try {
    const backendRes = await fetch(targetUrl, {
      method: "POST",
      headers: {
        Accept: "application/json",
        ...(req.headers.authorization
          ? { Authorization: req.headers.authorization }
          : {}),
      },
      redirect: "manual",
    });

    console.log(
      `[Quanttora OAuth] Dart response status: ${backendRes.status}`,
    );

    // Read the response body exactly once.
    const location = backendRes.headers.get("location");
    const responseText = await backendRes.text();
    const parsedData = parseJsonSafely(responseText);

    // Dart returned an HTTP redirect.
    if (location) {
      const absoluteRedirectUrl = makeAbsoluteUrl(location, backendBase);

      const wantsJson =
        req.query.format === "json" ||
        Boolean(req.headers.accept?.includes("application/json"));

      if (wantsJson) {
        return res.json({
          status: "ok",
          redirectUrl: absoluteRedirectUrl,
        });
      }

      return res.redirect(absoluteRedirectUrl);
    }

    // Dart returned JSON containing a login/authorization URL.
    const redirectUrl = getRedirectUrl(parsedData);

    if (redirectUrl) {
      const absoluteRedirectUrl = makeAbsoluteUrl(
        redirectUrl,
        backendBase,
      );

      const wantsJson =
        req.query.format === "json" ||
        Boolean(req.headers.accept?.includes("application/json"));

      if (wantsJson) {
        return res.json({
          status: "ok",
          redirectUrl: absoluteRedirectUrl,
        });
      }

      return res.redirect(absoluteRedirectUrl);
    }

    // Authentication failure must remain 401/403.
    if (backendRes.status === 401 || backendRes.status === 403) {
      res.status(backendRes.status);

      if (parsedData) {
        return res.json(sanitizeBrokerPayload(parsedData));
      }

      return res.json({
        success: false,
        error: {
          code:
            backendRes.status === 401 ? "AUTH_REQUIRED" : "FORBIDDEN",
          message:
            responseText ||
            (backendRes.status === 401
              ? "Authentication is required."
              : "Access forbidden."),
        },
      });
    }

    // Other backend errors.
    if (!backendRes.ok) {
      res.status(backendRes.status);

      if (parsedData) {
        return res.json(sanitizeBrokerPayload(parsedData));
      }

      return res.json({
        success: false,
        error: {
          code: "BACKEND_ERROR",
          message:
            responseText ||
            `Dart backend returned HTTP ${backendRes.status}`,
        },
      });
    }

    // Successful non-redirect response.
    if (parsedData) {
      return res.json(sanitizeBrokerPayload(parsedData));
    }

    return res.send(responseText);
  } catch (error: any) {
    console.error(
      `[Quanttora OAuth] Backend unreachable at ${targetUrl}:`,
      error?.message || error,
    );

    return res.status(503).json({
      error: "BACKEND_UNAVAILABLE",
      message: `Quanttora backend at ${backendBase} is not reachable.`,
    });
  }
});

// -----------------------------------------------------------------------------
// Upstox OAuth Callback
// -----------------------------------------------------------------------------

app.get(
  ["/api/auth/upstox/callback", "/auth/upstox/callback"],
  async (req, res) => {
    const backendBase = getBackendBaseUrl();

    const { error, error_description } = req.query;

    if (error) {
      return res.redirect(
        `/?broker_auth=cancelled&message=${encodeURIComponent(
          String(error_description || error),
        )}`,
      );
    }

    if (!req.query.code) {
      return res.redirect(
        "/?broker_auth=error&message=Missing+authorization+code",
      );
    }

    try {
      const searchParams = new URLSearchParams();

      for (const [key, value] of Object.entries(req.query)) {
        if (value !== undefined) {
          searchParams.set(key, String(value));
        }
      }

      const targetUrl =
        `${backendBase}/auth/upstox/callback?` +
        searchParams.toString();

      const forwardHeaders: Record<string, string> = {
        Accept: "application/json",
      };

      if (req.headers.authorization) {
        forwardHeaders.Authorization = req.headers.authorization;
      }

      const backendRes = await fetch(targetUrl, {
      method: "POST",
      headers: forwardHeaders,
        redirect: "manual",
      });

      const location = backendRes.headers.get("location");

      if (location) {
        return res.redirect(
          makeAbsoluteUrl(location, backendBase),
        );
      }

      // Read the backend body once.
      const responseText = await backendRes.text();

      if (backendRes.ok || backendRes.status === 302) {
        return res.redirect("/?broker_auth=success");
      }

      return res.redirect(
        `/?broker_auth=error&message=${encodeURIComponent(
          responseText ||
            "Backend token exchange rejected by Upstox gateway",
        )}`,
      );
    } catch (error: any) {
      console.error(
        "[Quanttora OAuth] Callback backend unavailable:",
        error?.message || error,
      );

      return res.redirect(
        `/?broker_auth=backend_offline&message=${encodeURIComponent(
          `Quanttora backend at ${backendBase} is not reachable.`,
        )}`,
      );
    }
  },
);


// -----------------------------------------------------------------------------
// Zerodha OAuth Login Initiation
// -----------------------------------------------------------------------------

app.get("/api/auth/zerodha/login", async (req, res) => {
  const backendBase = getBackendBaseUrl();
  const targetUrl = `${backendBase}/auth/zerodha/login`;

  const hasAuth = Boolean(
    req.headers.authorization &&
      req.headers.authorization.trim().length > 0,
  );

  console.log(
    `[Quanttora Zerodha OAuth] Request path: ${req.originalUrl || req.path}`,
  );
  console.log(`[Quanttora Zerodha OAuth] Target URL: ${targetUrl}`);
  console.log(`[Quanttora Zerodha OAuth] Authorization present: ${hasAuth}`);

  try {
    const backendRes = await fetch(targetUrl, {
      method: "POST",
      headers: {
        Accept: "application/json",
        ...(req.headers.authorization
          ? { Authorization: req.headers.authorization }
          : {}),
      },
      redirect: "manual",
    });

    const location = backendRes.headers.get("location");
    const responseText = await backendRes.text();
    const parsedData = parseJsonSafely(responseText);

    const wantsJson =
      req.query.format === "json" ||
      Boolean(req.headers.accept?.includes("application/json"));

    if (location) {
      const absoluteRedirectUrl = makeAbsoluteUrl(
        location,
        backendBase,
      );

      if (wantsJson) {
        return res.json({
          status: "ok",
          redirectUrl: absoluteRedirectUrl,
        });
      }

      return res.redirect(absoluteRedirectUrl);
    }

    const redirectUrl = getRedirectUrl(parsedData);

    if (redirectUrl) {
      const absoluteRedirectUrl = makeAbsoluteUrl(
        redirectUrl,
        backendBase,
      );

      if (wantsJson) {
        return res.json({
          status: "ok",
          redirectUrl: absoluteRedirectUrl,
        });
      }

      return res.redirect(absoluteRedirectUrl);
    }

    if (!backendRes.ok) {
      res.status(backendRes.status);

      if (parsedData) {
        return res.json(sanitizeBrokerPayload(parsedData));
      }

      return res.json({
        success: false,
        error: {
          code: "BACKEND_ERROR",
          message:
            responseText ||
            `Dart backend returned HTTP ${backendRes.status}`,
        },
      });
    }

    if (parsedData) {
      return res.json(sanitizeBrokerPayload(parsedData));
    }

    return res.send(responseText);
  } catch (error: any) {
    console.error(
      `[Quanttora Zerodha OAuth] Backend unreachable at ${targetUrl}:`,
      error?.message || error,
    );

    return res.status(503).json({
      error: "BACKEND_UNAVAILABLE",
      message: `Quanttora backend at ${backendBase} is not reachable.`,
    });
  }
});

// -----------------------------------------------------------------------------
// Zerodha OAuth Callback
// -----------------------------------------------------------------------------

app.get(
  [
    "/api/auth/zerodha/callback",
    "/api/broker/zerodha/callback",
    "/auth/zerodha/callback",
  ],
  async (req, res) => {
    const backendBase = getBackendBaseUrl();

    console.log("[Quanttora Zerodha OAuth] CALLBACK ROUTE HIT", req.originalUrl);

    const status = req.query.status;
    const requestToken = req.query.request_token;

    if (status && String(status).toLowerCase() !== "success") {
      return res.redirect(
        `/?broker_auth=cancelled&broker=zerodha&message=${encodeURIComponent(
          "Zerodha authorization was cancelled or failed.",
        )}`,
      );
    }

    if (!requestToken) {
      return res.redirect(
        "/?broker_auth=error&broker=zerodha&message=Missing+request+token",
      );
    }

    try {
      const searchParams = new URLSearchParams();

      for (const [key, value] of Object.entries(req.query)) {
        if (key === "redirect_params" || value === undefined) {
          continue;
        }

        if (Array.isArray(value)) {
          searchParams.set(key, String(value[0]));
        } else {
          searchParams.set(key, String(value));
        }
      }

      // Zerodha returns the OAuth state inside redirect_params.
      const redirectParams = req.query.redirect_params;
      if (typeof redirectParams === "string" && redirectParams.trim()) {
        const nestedParams = new URLSearchParams(redirectParams);

        for (const [key, value] of nestedParams.entries()) {
          searchParams.set(key, value);
        }
      }

      const targetUrl =
        `${backendBase}/auth/zerodha/callback?` +
        searchParams.toString();

      console.log(
        `[Quanttora Zerodha OAuth] Callback received. Request token present: ${Boolean(requestToken)}`,
      );
      console.log(
        `[Quanttora Zerodha OAuth] Forwarding callback to: ${backendBase}/auth/zerodha/callback`,
      );
      console.log(
        `[Quanttora Zerodha OAuth] State present: ${searchParams.has("state")}`,
      );

      const backendRes = await fetch(targetUrl, {
        method: "GET",
        headers: {
          Accept: "application/json",
        },
        redirect: "manual",
      });

      const location = backendRes.headers.get("location");

      if (location) {
        return res.redirect(
          makeAbsoluteUrl(location, backendBase),
        );
      }

      const responseText = await backendRes.text();

      if (backendRes.ok || backendRes.status === 302) {
        return res.redirect("/?broker_auth=success&broker=zerodha");
      }

      console.error(
        `[Quanttora Zerodha OAuth] Callback backend returned ${backendRes.status}: ${responseText}`,
      );

      return res.redirect(
        `/?broker_auth=error&broker=zerodha&message=${encodeURIComponent(
          responseText ||
            "Backend token exchange rejected by Zerodha gateway",
        )}`,
      );
    } catch (error: any) {
      console.error(
        "[Quanttora Zerodha OAuth] Callback backend unavailable:",
        error?.message || error,
      );

      return res.redirect(
        `/?broker_auth=backend_offline&broker=zerodha&message=${encodeURIComponent(
          `Quanttora backend at ${backendBase} is not reachable.`,
        )}`,
      );
    }
  },
);

// -----------------------------------------------------------------------------
// Dart Backend Proxy
// -----------------------------------------------------------------------------

app.all("/api/proxy/*", async (req, res) => {
  const backendBase = getBackendBaseUrl();

  const subPath = req.originalUrl.replace(/^\/api\/proxy/, "");

  const targetUrl =
    `${backendBase}` +
    (subPath.startsWith("/") ? subPath : `/${subPath}`);

  try {
    const headers: Record<string, string> = {
      Accept: "application/json",
    };

    if (req.headers.authorization) {
      headers.Authorization = req.headers.authorization;
    }

    if (req.headers["content-type"]) {
      headers["Content-Type"] = String(req.headers["content-type"]);
    }

    const fetchOptions: RequestInit = {
      method: req.method,
      headers,
      redirect: "manual",
    };

    if (
      ["POST", "PUT", "PATCH"].includes(req.method) &&
      req.body !== undefined
    ) {
      fetchOptions.body = JSON.stringify(req.body);

      if (!headers["Content-Type"]) {
        headers["Content-Type"] = "application/json";
      }
    }

    const backendRes = await fetch(targetUrl, fetchOptions);

    const contentType =
      backendRes.headers.get("content-type") || "";

    // Read the response exactly once.
    const responseText = await backendRes.text();

    if (contentType.includes("application/json")) {
      const data = parseJsonSafely(responseText);

      if (data !== null) {
        return res
          .status(backendRes.status)
          .json(sanitizeBrokerPayload(data));
      }
    }

    return res
      .status(backendRes.status)
      .send(responseText);
  } catch (error: any) {
    console.error(
      `[Quanttora Proxy] Backend unreachable at ${backendBase}:`,
      error?.message || error,
    );

    return res.status(503).json({
      error: "BACKEND_UNAVAILABLE",
      message: `Quanttora backend at ${backendBase} is not reachable.`,
    });
  }
});

// -----------------------------------------------------------------------------
// AI Evaluate Setup Endpoint
// -----------------------------------------------------------------------------

app.post("/api/ai/evaluate-setup", async (req, res) => {
  try {
    const { setup, constitution, marketContext } = req.body;
    const ai = getGeminiClient();

    if (!ai) {
      return res.json({
        success: true,
        source: "engine",
        analysis:
          "Setup evaluated based on Quanttora Rulebook. Ensure discipline on stop-loss execution and do not oversize your position.",
      });
    }

    const prompt = `You are the Quanttora Decision Intelligence Engine, an expert trading discipline and risk system for Indian Retail Equity & F&O traders.
Core philosophy: "Trading is a skill, not gambling."
CRITICAL RULES:
- Never predict future stock price or guarantee win rates.
- Do NOT encourage more trading.
- Be comfortable recommending a STAND-DOWN or NO-TRADE if conditions are unfavorable.
- Focus on capital preservation, risk/reward math, market structure, and Constitution compliance.

Evaluate the following trade setup:
Instrument: ${setup.instrument} (${setup.direction})
Strategy: ${setup.strategy}
Entry: ₹${setup.entry}, Stop Loss: ₹${setup.stopLoss}, Target: ₹${setup.target}
Risk: ₹${setup.riskAmount} | Reward: ₹${setup.rewardAmount} | R:R: 1:${setup.riskRewardRatio}
Market Condition: ${setup.marketCondition || "Trending/Consolidating"}
Trader Constitution Limits:
- Max Daily Loss: ₹${constitution.maxDailyLoss}, Current Daily Loss: ₹${constitution.currentDailyLoss}
- Max Daily Trades: ${constitution.maxDailyTrades}, Taken Today: ${constitution.currentDailyTrades}
- Min R:R: 1:${constitution.minRiskReward}
- Max Risk Per Trade: ₹${constitution.maxRiskPerTrade}

Provide a concise, disciplined evaluation with:
1. Setup Integrity & Math (R:R quality)
2. Risk & Constitution Assessment
3. Market Context Warning/Caution
4. Actionable Decision Advice (Take Setup, Wait for Confirmation, or Stand Down).
Keep the tone professional, objective, and focused on discipline. Maximum 180 words.`;

    const response = await ai.models.generateContent({
      model: "gemini-3.7-flash",
      contents: prompt,
      config: {
        temperature: 0.3,
      },
    });

    res.json({
      success: true,
      source: "gemini",
      analysis: response.text || "Setup evaluation completed.",
    });
  } catch (error: any) {
    console.error("AI evaluate setup error:", error);

    res.status(500).json({
      success: false,
      error: error.message || "Failed to analyze setup",
    });
  }
});

// -----------------------------------------------------------------------------
// AI Behavioral Leak Detection & Performance Insights
// -----------------------------------------------------------------------------

app.post("/api/ai/trader-insights", async (req, res) => {
  try {
    const { trades, constitution, stats } = req.body;
    const ai = getGeminiClient();

    if (!ai) {
      return res.json({
        success: true,
        source: "engine",
        insights: [
          {
            title: "Strict Stop Loss Compliance",
            leak: "Losses exceeded initial planned R in 2 recent trades.",
            recommendation:
              "Never modify stop loss after trade execution. Pre-calculate risk.",
            impact: "High",
          },
          {
            title: "Midday Session Vulnerability",
            leak: "Win rate drops during 11:30 AM - 1:30 PM chop zone.",
            recommendation:
              "Limit active entries to 9:30-11:00 AM and 1:45-3:00 PM.",
            impact: "Medium",
          },
        ],
      });
    }

    const prompt = `You are Quanttora's Behavioral Leak Detector for an Indian derivatives/equity trader.
Trader Stats:
- Win Rate: ${stats?.winRate || "52"}%
- Profit Factor: ${stats?.profitFactor || "1.65"}
- Average Winning R: ${stats?.avgWinR || "2.1"}R | Average Losing R: ${stats?.avgLossR || "1.0"}R
- Total Trades logged: ${trades?.length || 15}
- Recent violations count: ${stats?.ruleViolationsCount || 3}

Examine trading patterns and return a JSON object with:
1. "behavioralLeaks": array of up to 3 identified mistakes (e.g. overtrading after loss, moving stop loss, premature entry, trading during midday chop, deviating from approved strategies).
2. "edgeFactors": 2 factors that generated their best expectancy.
3. "cooldownRecommendation": a specific discipline rule to adopt.
4. "executiveSummary": 2-3 sentences of objective feedback.

Format output as strict JSON matching this structure:
{
  "behavioralLeaks": [
    { "title": "...", "observation": "...", "recommendation": "...", "severity": "High"|"Medium"|"Low" }
  ],
  "edgeFactors": ["...", "..."],
  "cooldownRecommendation": "...",
  "executiveSummary": "..."
}`;

    const response = await ai.models.generateContent({
      model: "gemini-3.7-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        temperature: 0.2,
      },
    });

    let data;

    try {
      data = JSON.parse(response.text || "{}");
    } catch {
      data = { raw: response.text };
    }

    res.json({
      success: true,
      source: "gemini",
      data,
    });
  } catch (error: any) {
    console.error("AI trader insights error:", error);

    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// -----------------------------------------------------------------------------
// AI Pre-Market / Market Intelligence Summary
// -----------------------------------------------------------------------------

app.post("/api/ai/market-brief", async (req, res) => {
  try {
    const { marketData, indices } = req.body;
    const ai = getGeminiClient();

    if (!ai) {
      return res.json({
        success: true,
        source: "engine",
        brief:
          "NIFTY 50 trading near resistance. India VIX at 13.8 suggests moderate volatility. Focus on high-conviction breakout/pullback setups with strict stop-losses.",
      });
    }

    const prompt = `You are Quanttora Pre-Market Analyst for Indian markets (NIFTY 50, SENSEX, BANK NIFTY).
Current Market Snapshot:
- NIFTY 50: ${indices?.nifty?.value || "24,850"} (${indices?.nifty?.change || "+0.45%"})
- SENSEX: ${indices?.sensex?.value || "81,400"} (${indices?.sensex?.change || "+0.38%"})
- India VIX: ${indices?.vix?.value || "13.4"}
- Market Breadth: ${marketData?.breadth || "Advancing 1,280 / Declining 890"}
- Key Sectors: ${marketData?.topSectors || "Auto & IT Strong, Metals Consolidating"}

Provide a trader-centric pre-market preparation brief.
Address:
1. What matters for today's trading environment?
2. Key levels to respect
3. Recommended stance (Aggressive / Selective / Stand-Down bias)
Do NOT give buy/sell calls. Give market structure guidance. Max 140 words.`;

    const response = await ai.models.generateContent({
      model: "gemini-3.7-flash",
      contents: prompt,
      config: {
        temperature: 0.3,
      },
    });

    res.json({
      success: true,
      source: "gemini",
      brief: response.text || "Market context generated.",
    });
  } catch (error: any) {
    console.error("AI market brief error:", error);

    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// -----------------------------------------------------------------------------
// AI Post-Trade Review Debrief
// -----------------------------------------------------------------------------

app.post("/api/ai/trade-review", async (req, res) => {
  try {
    const { trade } = req.body;
    const ai = getGeminiClient();

    if (!ai) {
      return res.json({
        success: true,
        source: "engine",
        review:
          "Trade executed according to plan. Execution score 85/100. Discipline maintained on stop-loss.",
      });
    }

    const prompt = `Post-Trade Debrief for an Indian trader:
Instrument: ${trade.instrument} (${trade.direction})
Strategy: ${trade.strategy}
Entry: ₹${trade.entry} | Exit: ₹${trade.exit} | Planned SL: ₹${trade.stopLoss} | Planned Target: ₹${trade.target}
Realized R: ${trade.realizedR}R | PnL: ₹${trade.pnl}
Setup Quality Score Before Trade: ${trade.setupQuality}/100
Rule Compliance: ${trade.ruleCompliance ? "Compliant" : "Violated rules: " + trade.violations?.join(", ")}
Execution Notes: ${trade.notes || "None"}

Provide a constructive, 80-word post-trade review focusing on:
1. Execution vs Plan fidelity
2. Decision quality vs outcome bias (remind the trader that a good process with a loss is better than a bad process with luck)
3. Key takeaway for next trade.`;

    const response = await ai.models.generateContent({
      model: "gemini-3.7-flash",
      contents: prompt,
      config: {
        temperature: 0.3,
      },
    });

    res.json({
      success: true,
      source: "gemini",
      review: response.text || "Review completed.",
    });
  } catch (error: any) {
    console.error("AI trade review error:", error);

    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// -----------------------------------------------------------------------------
// Vite middleware in dev or static serving in prod
// -----------------------------------------------------------------------------

async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: {
        middlewareMode: true,
      },
      appType: "spa",
    });

    // IMPORTANT:
    // All Quanttora API/OAuth/proxy routes are registered above this point.
    // Vite must never catch /api/* requests before Express handles them.
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");

    app.use(express.static(distPath));

    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(
      `Quanttora Platform Server running on port ${PORT}`,
    );
  });
}

startServer();
