import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  static const Color secondary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF14B8A6);

  // ---------------------------------------------------------------------------
  // Profit / Loss
  // ---------------------------------------------------------------------------

  static const Color profit = Color(0xFF16A34A);
  static const Color loss = Color(0xFFDC2626);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;

  // Backward Compatibility
  static const Color text = textPrimary;
  static const Color subtitle = textSecondary;

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEDF2F7);

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  static const Color card = Colors.white;
  static const Color cardHover = Color(0xFFF8FAFC);

  // ---------------------------------------------------------------------------
  // Market Colors
  // ---------------------------------------------------------------------------

  static const Color bullish = Color(0xFF10B981);
  static const Color bearish = Color(0xFFEF4444);
  static const Color neutral = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // AI
  // ---------------------------------------------------------------------------

  static const Color ai = Color(0xFF7C3AED);

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  static const Color connected = Color(0xFF22C55E);
  static const Color disconnected = Color(0xFFEF4444);
  static const Color pending = Color(0xFFF59E0B);
}