export interface QuanttoraUser {
  id?: number | string;
  email?: string;
  displayName?: string;
  name?: string;
  status?: string;
  [key: string]: unknown;
}

export interface QuanttoraSession {
  token: string;
  user: QuanttoraUser;
}

const SESSION_KEY = 'quanttora_auth_session_v1';

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object'
    ? (value as Record<string, unknown>)
    : {};
}

function findToken(payload: unknown): string | null {
  const root = asRecord(payload);
  const data = asRecord(root.data);
  const rootSession = asRecord(root.session);
  const dataSession = asRecord(data.session);
  const auth = asRecord(root.authentication);

  const candidates = [
    // Root-level formats
    root.token,
    root.accessToken,
    root.access_token,
    root.sessionToken,
    root.session_token,

    // data-level formats
    data.token,
    data.accessToken,
    data.access_token,
    data.sessionToken,
    data.session_token,

    // Actual Quanttora backend contract:
    // data.session.token
    dataSession.token,
    dataSession.accessToken,
    dataSession.access_token,

    // Alternative root session formats
    rootSession.token,
    rootSession.accessToken,
    rootSession.access_token,

    // Authentication wrapper formats
    auth.token,
    auth.accessToken,
    auth.access_token,
  ];

  for (const candidate of candidates) {
    if (typeof candidate === 'string' && candidate.trim()) {
      return candidate.trim();
    }
  }

  return null;
}

function findUser(payload: unknown): QuanttoraUser {
  const root = asRecord(payload);
  const data = asRecord(root.data);
  const dataSession = asRecord(data.session);

  const candidates = [
    root.user,
    data.user,
    root.profile,
    data.profile,
    dataSession.user,
    root,
  ];

  for (const candidate of candidates) {
    const record = asRecord(candidate);

    if (
      Object.keys(record).length > 0 &&
      (
        record.email ||
        record.displayName ||
        record.name ||
        record.id
      )
    ) {
      return record as QuanttoraUser;
    }
  }

  return {};
}

function readErrorMessage(
  payload: unknown,
  fallback: string,
): string {
  const root = asRecord(payload);
  const error = asRecord(root.error);
  const data = asRecord(root.data);

  const candidates = [
    error.message,
    root.message,
    data.message,
  ];

  for (const candidate of candidates) {
    if (
      typeof candidate === 'string' &&
      candidate.trim()
    ) {
      return candidate.trim();
    }
  }

  return fallback;
}

async function requestAuth(
  path: string,
  body: Record<string, unknown>,
): Promise<unknown> {
  let response: Response;

  try {
    response = await fetch(
      `/api/auth/${path}`,
      {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        credentials: 'same-origin',
      },
    );
  } catch {
    throw new Error(
      'Quanttora backend is not reachable. Start the Dart backend on port 8080.',
    );
  }

  const contentType =
    response.headers.get('content-type') || '';

  const payload: unknown =
    contentType.includes('application/json')
      ? await response.json()
      : await response.text();

  if (!response.ok) {
    throw new Error(
      readErrorMessage(
        payload,
        response.status === 401
          ? 'Invalid email or password.'
          : `Authentication request failed (${response.status}).`,
      ),
    );
  }

  return payload;
}

export function getStoredSession(): QuanttoraSession | null {
  try {
    const raw =
      sessionStorage.getItem(SESSION_KEY);

    if (!raw) {
      return null;
    }

    const parsed =
      JSON.parse(raw) as unknown;

    const record =
      asRecord(parsed);

    const token =
      typeof record.token === 'string'
        ? record.token.trim()
        : '';

    const user =
      asRecord(record.user) as QuanttoraUser;

    if (!token) {
      sessionStorage.removeItem(
        SESSION_KEY,
      );

      return null;
    }

    return {
      token,
      user,
    };
  } catch {
    sessionStorage.removeItem(
      SESSION_KEY,
    );

    return null;
  }
}

export function getAuthToken(): string | null {
  return getStoredSession()?.token ?? null;
}

export function getAuthHeaders(): Record<string, string> {
  const token =
    getAuthToken();

  return token
    ? {
        Authorization:
          `Bearer ${token}`,
      }
    : {};
}

export function saveSession(
  session: QuanttoraSession,
): void {
  sessionStorage.setItem(
    SESSION_KEY,
    JSON.stringify(session),
  );
}

export function clearSession(): void {
  sessionStorage.removeItem(
    SESSION_KEY,
  );
}

export async function login(
  email: string,
  password: string,
): Promise<QuanttoraSession> {
  const payload =
    await requestAuth(
      'login',
      {
        email,
        password,
      },
    );

  const token =
    findToken(payload);

  if (!token) {
    throw new Error(
      'Quanttora login succeeded but no session token was returned by the backend.',
    );
  }

  const session: QuanttoraSession = {
    token,
    user: findUser(payload),
  };

  saveSession(session);

  return session;
}

export async function register(
  email: string,
  password: string,
  displayName: string,
): Promise<QuanttoraSession> {
  await requestAuth(
    'register',
    {
      email,
      password,
      displayName,
    },
  );

  // Registration creates the user.
  // Authenticate through the normal login flow
  // so the browser uses the same session mechanism
  // as an existing user.
  return login(
    email,
    password,
  );
}