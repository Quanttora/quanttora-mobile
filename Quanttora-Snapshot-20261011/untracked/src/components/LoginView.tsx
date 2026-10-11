import React, {
  FormEvent,
  useState,
} from 'react';

import {
  login,
  register,
  QuanttoraSession,
} from '../services/authService';

interface LoginViewProps {
  onAuthenticated: (
    session: QuanttoraSession,
  ) => void;
}

export function LoginView({
  onAuthenticated,
}: LoginViewProps) {
  const [
    mode,
    setMode,
  ] = useState<'login' | 'register'>(
    'login',
  );

  const [
    displayName,
    setDisplayName,
  ] = useState('');

  const [
    email,
    setEmail,
  ] = useState('');

  const [
    password,
    setPassword,
  ] = useState('');

  const [
    confirmPassword,
    setConfirmPassword,
  ] = useState('');

  const [
    loading,
    setLoading,
  ] = useState(false);

  const [
    error,
    setError,
  ] = useState<string | null>(
    null,
  );

  const [
    showPassword,
    setShowPassword,
  ] = useState(false);

  const isRegister =
    mode === 'register';

  const handleSubmit = async (
    event: FormEvent<HTMLFormElement>,
  ) => {
    event.preventDefault();

    setError(null);

    const cleanEmail =
      email.trim().toLowerCase();

    if (!cleanEmail) {
      setError(
        'Please enter your email address.',
      );
      return;
    }

    if (!password) {
      setError(
        'Please enter your password.',
      );
      return;
    }

    if (isRegister) {
      if (!displayName.trim()) {
        setError(
          'Please enter your name.',
        );
        return;
      }

      if (
        password.length < 8
      ) {
        setError(
          'Password must be at least 8 characters.',
        );
        return;
      }

      if (
        password !==
        confirmPassword
      ) {
        setError(
          'Passwords do not match.',
        );
        return;
      }
    }

    try {
      setLoading(true);

      let session: QuanttoraSession;

      if (isRegister) {
        session =
          await register(
            cleanEmail,
            password,
            displayName.trim(),
          );
      } else {
        session =
          await login(
            cleanEmail,
            password,
          );
      }

      onAuthenticated(
        session,
      );
    } catch (requestError) {
      setError(
        requestError instanceof Error
          ? requestError.message
          : 'Unable to authenticate with Quanttora.',
      );
    } finally {
      setLoading(false);
    }
  };

  const switchMode = (
    nextMode:
      | 'login'
      | 'register',
  ) => {
    setMode(nextMode);
    setError(null);
    setPassword('');
    setConfirmPassword('');
  };

  return (
    <main className="min-h-screen bg-[#FDFDFB] text-slate-900 flex items-center justify-center px-5 py-10">
      <div className="w-full max-w-[1120px] grid lg:grid-cols-[1.05fr_0.95fr] gap-10 lg:gap-16 items-center">
        <section className="hidden lg:block">
          <div className="max-w-[560px]">
            <div className="flex items-center gap-3 mb-12">
              <div className="h-11 w-11 rounded-[14px] bg-indigo-600 text-white flex items-center justify-center text-lg font-semibold shadow-sm">
                Q
              </div>

              <div>
                <div className="font-semibold tracking-[-0.02em] text-[18px]">
                  Quanttora
                </div>

                <div className="text-[11px] text-slate-500">
                  Intelligent Trading Decision &amp; Risk Platform
                </div>
              </div>
            </div>

            <div className="mb-7">
              <div className="text-[11px] uppercase tracking-[0.16em] text-indigo-600 font-semibold mb-4">
                INTELLIGENCE · DISCIPLINE · PRECISION
              </div>

              <h1 className="font-serif text-[52px] leading-[1.02] tracking-[-0.035em] text-slate-950">
                Trade with clarity.
                <br />
                Decide with confidence.
              </h1>
            </div>

            <p className="text-[16px] leading-7 text-slate-600 max-w-[500px]">
              Quanttora brings market intelligence,
              structured decision-making, strategy
              analysis and trading education into one
              disciplined workspace.
            </p>

            <div className="mt-10 grid grid-cols-3 gap-3 max-w-[510px]">
              <div className="border border-[#EEECE7] bg-white rounded-xl p-4">
                <div className="text-[11px] uppercase tracking-wider text-slate-400 mb-2">
                  Markets
                </div>

                <div className="text-sm font-medium text-slate-800">
                  Live intelligence
                </div>
              </div>

              <div className="border border-[#EEECE7] bg-white rounded-xl p-4">
                <div className="text-[11px] uppercase tracking-wider text-slate-400 mb-2">
                  Decision
                </div>

                <div className="text-sm font-medium text-slate-800">
                  Risk first
                </div>
              </div>

              <div className="border border-[#EEECE7] bg-white rounded-xl p-4">
                <div className="text-[11px] uppercase tracking-wider text-slate-400 mb-2">
                  Academy
                </div>

                <div className="text-sm font-medium text-slate-800">
                  Learn systematically
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="w-full max-w-[460px] mx-auto lg:mx-0 lg:ml-auto">
          <div className="lg:hidden flex items-center justify-center gap-3 mb-8">
            <div className="h-10 w-10 rounded-[12px] bg-indigo-600 text-white flex items-center justify-center font-semibold">
              Q
            </div>

            <div>
              <div className="font-semibold tracking-[-0.02em]">
                Quanttora
              </div>

              <div className="text-[10px] text-slate-500">
                Intelligent Trading Platform
              </div>
            </div>
          </div>

          <div className="bg-white border border-[#EEECE7] rounded-[22px] shadow-[0_18px_60px_rgba(15,23,42,0.06)] p-7 sm:p-9">
            <div className="mb-7">
              <div className="flex items-center gap-1 p-1 rounded-xl bg-slate-50 border border-slate-100">
                <button
                  type="button"
                  onClick={() =>
                    switchMode('login')
                  }
                  className={`flex-1 h-10 rounded-lg text-sm font-medium transition ${
                    mode === 'login'
                      ? 'bg-white text-slate-900 shadow-sm border border-slate-200'
                      : 'text-slate-500 hover:text-slate-800'
                  }`}
                >
                  Sign in
                </button>

                <button
                  type="button"
                  onClick={() =>
                    switchMode(
                      'register',
                    )
                  }
                  className={`flex-1 h-10 rounded-lg text-sm font-medium transition ${
                    mode === 'register'
                      ? 'bg-white text-slate-900 shadow-sm border border-slate-200'
                      : 'text-slate-500 hover:text-slate-800'
                  }`}
                >
                  Create account
                </button>
              </div>
            </div>

            <div className="mb-7">
              <h2 className="font-serif text-[30px] tracking-[-0.025em] text-slate-950">
                {isRegister
                  ? 'Create your Quanttora account'
                  : 'Welcome back'}
              </h2>

              <p className="mt-2 text-sm leading-6 text-slate-500">
                {isRegister
                  ? 'Build a disciplined workspace for your trading journey.'
                  : 'Sign in to continue to your trading workspace.'}
              </p>
            </div>

            {error && (
              <div
                role="alert"
                className="mb-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm leading-5 text-red-700"
              >
                {error}
              </div>
            )}

            <form
              onSubmit={
                handleSubmit
              }
              className="space-y-5"
            >
              {isRegister && (
                <div>
                  <label
                    htmlFor="displayName"
                    className="block text-xs font-medium text-slate-700 mb-2"
                  >
                    Name
                  </label>

                  <input
                    id="displayName"
                    name="displayName"
                    type="text"
                    autoComplete="name"
                    value={
                      displayName
                    }
                    onChange={(event) =>
                      setDisplayName(
                        event.target.value,
                      )
                    }
                    placeholder="Your name"
                    disabled={loading}
                    className="w-full h-12 rounded-xl border border-slate-200 bg-white px-4 text-sm outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-50 disabled:bg-slate-50"
                  />
                </div>
              )}

              <div>
                <label
                  htmlFor="email"
                  className="block text-xs font-medium text-slate-700 mb-2"
                >
                  Email address
                </label>

                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  value={email}
                  onChange={(event) =>
                    setEmail(
                      event.target.value,
                    )
                  }
                  placeholder="you@example.com"
                  disabled={loading}
                  className="w-full h-12 rounded-xl border border-slate-200 bg-white px-4 text-sm outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-50 disabled:bg-slate-50"
                />
              </div>

              <div>
                <label
                  htmlFor="password"
                  className="block text-xs font-medium text-slate-700 mb-2"
                >
                  Password
                </label>

                <div className="relative">
                  <input
                    id="password"
                    name="password"
                    type={
                      showPassword
                        ? 'text'
                        : 'password'
                    }
                    autoComplete={
                      isRegister
                        ? 'new-password'
                        : 'current-password'
                    }
                    value={
                      password
                    }
                    onChange={(event) =>
                      setPassword(
                        event.target.value,
                      )
                    }
                    placeholder="Enter your password"
                    disabled={loading}
                    className="w-full h-12 rounded-xl border border-slate-200 bg-white px-4 pr-20 text-sm outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-50 disabled:bg-slate-50"
                  />

                  <button
                    type="button"
                    onClick={() =>
                      setShowPassword(
                        (current) =>
                          !current,
                      )
                    }
                    disabled={loading}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-medium text-slate-500 hover:text-slate-800 disabled:opacity-50"
                  >
                    {showPassword
                      ? 'Hide'
                      : 'Show'}
                  </button>
                </div>
              </div>

              {isRegister && (
                <div>
                  <label
                    htmlFor="confirmPassword"
                    className="block text-xs font-medium text-slate-700 mb-2"
                  >
                    Confirm password
                  </label>

                  <input
                    id="confirmPassword"
                    name="confirmPassword"
                    type={
                      showPassword
                        ? 'text'
                        : 'password'
                    }
                    autoComplete="new-password"
                    value={
                      confirmPassword
                    }
                    onChange={(event) =>
                      setConfirmPassword(
                        event.target.value,
                      )
                    }
                    placeholder="Enter your password again"
                    disabled={loading}
                    className="w-full h-12 rounded-xl border border-slate-200 bg-white px-4 text-sm outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-50 disabled:bg-slate-50"
                  />
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full h-12 rounded-xl bg-indigo-600 text-white text-sm font-semibold shadow-sm transition hover:bg-indigo-700 active:scale-[0.99] disabled:cursor-not-allowed disabled:opacity-60"
              >
                {loading
                  ? isRegister
                    ? 'Creating account…'
                    : 'Signing in…'
                  : isRegister
                    ? 'Create Quanttora account'
                    : 'Sign in to Quanttora'}
              </button>
            </form>

            <div className="mt-7 pt-6 border-t border-[#EEECE7]">
              <p className="text-[11px] leading-5 text-slate-400 text-center">
                Quanttora is a decision-support and
                education platform. Trading and investing
                involve market risk. Nothing on this
                platform should be treated as a guaranteed
                return or investment recommendation.
              </p>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}