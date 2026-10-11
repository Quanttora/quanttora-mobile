import {
  clearSession,
  getAuthHeaders,
} from './authService';

export interface BrokerFeedStatus {
  success?: boolean;
  connected: boolean;
  brokerConnected?: boolean;
  userId?: number | string;
  subscriptions?: string[];
  [key: string]: unknown;
}

export interface BrokerStatus {
  success?: boolean;
  connected?: boolean;
  marketFeed?: boolean;
  broker?: string | null;
  user?: Record<string, unknown> | null;
  tokenExpiry?: string | null;
  [key: string]: unknown;
}

export interface BrokerApiResponse {
  success?: boolean;
  connected?: boolean;
  brokerConnected?: boolean;
  message?: string;
  error?: {
    code?: string;
    message?: string;
  };
  [key: string]: unknown;
}

export class BrokerServiceError extends Error {
  status: number;
  code?: string;

  constructor(
    message: string,
    status: number,
    code?: string,
  ) {
    super(message);

    this.name = 'BrokerServiceError';
    this.status = status;
    this.code = code;
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  let response: Response;

  try {
    response = await fetch(
      `/api/proxy${path}`,
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
    throw new BrokerServiceError(
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
    payload =
      await response.json();
  } else {
    const text =
      await response.text();

    payload =
      text || null;
  }

  if (!response.ok) {
    const root =
      payload &&
      typeof payload === 'object'
        ? (
            payload as Record<
              string,
              unknown
            >
          )
        : {};

    const error =
      root.error &&
      typeof root.error === 'object'
        ? (
            root.error as Record<
              string,
              unknown
            >
          )
        : {};

    const message =
      typeof error.message ===
        'string' &&
      error.message.trim()
        ? error.message.trim()
        : typeof root.message ===
              'string' &&
            root.message.trim()
          ? root.message.trim()
          : response.status === 401
            ? 'Your Quanttora session has expired. Please sign in again.'
            : `Broker request failed (${response.status}).`;

    if (response.status === 401) {
      clearSession();
    }

    throw new BrokerServiceError(
      message,
      response.status,
      typeof error.code ===
        'string'
        ? error.code
        : undefined,
    );
  }

  return payload as T;
}

function readMessage(
  payload: unknown,
  fallback: string,
): string {
  if (
    payload &&
    typeof payload === 'object'
  ) {
    const root =
      payload as Record<
        string,
        unknown
      >;

    if (
      typeof root.message ===
        'string' &&
      root.message.trim()
    ) {
      return root.message.trim();
    }

    if (
      root.error &&
      typeof root.error ===
        'object'
    ) {
      const error =
        root.error as Record<
          string,
          unknown
        >;

      if (
        typeof error.message ===
          'string' &&
        error.message.trim()
      ) {
        return error.message.trim();
      }
    }
  }

  return fallback;
}

function unwrap<T>(
  payload: T | {
    data?: T;
    success?: boolean;
  },
): T {
  if (
    payload &&
    typeof payload ===
      'object' &&
    'data' in payload
  ) {
    const data =
      (
        payload as {
          data?: T;
        }
      ).data;

    if (data !== undefined) {
      return data;
    }
  }

  return payload as T;
}

/**
 * Returns the authenticated user's broker status.
 *
 * Backend:
 * GET /broker/status
 */
export async function getBrokerStatus(): Promise<BrokerStatus> {
  const response =
    await request<
      BrokerStatus
    >(
      '/broker/status',
      {
        method: 'GET',
      },
    );

  return unwrap(response);
}

/**
 * Returns the authenticated user's
 * Upstox market-feed status.
 *
 * Backend:
 * GET /broker/feed/status
 */
export async function getBrokerFeedStatus(): Promise<BrokerFeedStatus> {
  const response =
    await request<
      BrokerFeedStatus
    >(
      '/broker/feed/status',
      {
        method: 'GET',
      },
    );

  return unwrap(response);
}

/**
 * Connects the Upstox market-data feed.
 *
 * The Dart backend determines the authenticated
 * broker session itself, so no request body is sent.
 *
 * Backend:
 * POST /broker/feed/connect
 */
export async function connectBrokerFeed(
  broker = 'upstox',
): Promise<BrokerApiResponse> {
  if (
    broker.toLowerCase() !==
    'upstox'
  ) {
    throw new BrokerServiceError(
      `Broker "${broker}" is not supported by the live feed integration yet.`,
      400,
    );
  }

  const response =
    await request<
      BrokerApiResponse
    >(
      '/broker/feed/connect',
      {
        method: 'POST',
      },
    );

  return unwrap(response);
}

/**
 * Disconnects only the market-data feed.
 *
 * This does not remove the user's broker OAuth
 * session from the backend.
 *
 * Backend:
 * POST /broker/feed/disconnect
 */
export async function disconnectBrokerFeed(
  broker = 'upstox',
): Promise<BrokerApiResponse> {
  if (
    broker.toLowerCase() !==
    'upstox'
  ) {
    throw new BrokerServiceError(
      `Broker "${broker}" is not supported by the live feed integration yet.`,
      400,
    );
  }

  const response =
    await request<
      BrokerApiResponse
    >(
      '/broker/feed/disconnect',
      {
        method: 'POST',
      },
    );

  return unwrap(response);
}

/**
 * Completely disconnects the authenticated
 * broker session.
 *
 * The Dart backend also disconnects the
 * market feed as part of this operation.
 *
 * Backend:
 * POST /broker/disconnect
 */
export async function disconnectBroker(
  broker = 'upstox',
): Promise<BrokerApiResponse> {
  if (
    broker.toLowerCase() !==
    'upstox'
  ) {
    throw new BrokerServiceError(
      `Broker "${broker}" is not supported by the live broker integration yet.`,
      400,
    );
  }

  const response =
    await request<
      BrokerApiResponse
    >(
      '/broker/disconnect',
      {
        method: 'POST',
      },
    );

  return unwrap(response);
}

/**
 * Gets the secure Upstox OAuth authorization URL.
 *
 * This endpoint is different from the generic
 * /api/proxy route because the frontend server
 * intentionally handles the OAuth initiation.
 */
export async function getUpstoxLoginUrl(): Promise<string> {
  let response: Response;

  try {
    response =
      await fetch(
        '/api/auth/upstox/login',
        {
          method: 'GET',

          headers: {
            Accept:
              'application/json',

            ...getAuthHeaders(),
          },

          credentials:
            'same-origin',

          redirect: 'manual',
        },
      );
  } catch {
    throw new BrokerServiceError(
      'Quanttora backend is not reachable. Start the Dart backend on port 8080.',
      0,
    );
  }

  const contentType =
    response.headers.get(
      'content-type',
    ) || '';

  let payload: unknown =
    null;

  if (
    contentType.includes(
      'application/json',
    )
  ) {
    payload =
      await response.json();
  }

  if (
    response.status ===
      401
  ) {
    clearSession();

    throw new BrokerServiceError(
      'Your Quanttora session has expired. Please sign in again.',
      401,
    );
  }

  if (
    !response.ok &&
    response.status !==
      302 &&
    response.status !==
      303 &&
    response.status !==
      307 &&
    response.status !==
      308
  ) {
    throw new BrokerServiceError(
      readMessage(
        payload,
        'Unable to start Upstox connection.',
      ),
      response.status,
    );
  }

  if (
    payload &&
    typeof payload ===
      'object'
  ) {
    const root =
      payload as Record<
        string,
        unknown
      >;

    const redirectUrl =
      root.redirectUrl;

    if (
      typeof redirectUrl ===
        'string' &&
      redirectUrl.trim()
    ) {
      return redirectUrl.trim();
    }

    const url =
      root.url;

    if (
      typeof url ===
        'string' &&
      url.trim()
    ) {
      return url.trim();
    }
  }

  const location =
    response.headers.get(
      'location',
    );

  if (
    location &&
    location.trim()
  ) {
    return location.trim();
  }

  throw new BrokerServiceError(
    'Upstox OAuth authorization URL was not returned by the backend.',
    response.status,
  );
}

/**
 * Starts the secure Upstox OAuth flow.
 *
 * The browser is redirected to the authorization
 * URL returned by the Quanttora backend.
 */
export async function startUpstoxOAuth(): Promise<void> {
  const authorizationUrl =
    await getUpstoxLoginUrl();

  window.location.assign(
    authorizationUrl,
  );
}