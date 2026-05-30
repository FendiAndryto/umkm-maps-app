import 'package:flutter/material.dart';

class AppColors {
  // ─── Primary (Teal) ───────────────────────────────────
  static const Color primary        = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark    = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight   = Color(0xFF14B8A6); // Teal 500
  static const Color primarySurface = Color(0xFFF0FDFA); // Teal 50

  // ─── Accent ───────────────────────────────────────────
  static const Color secondary      = Color(0xFFF59E0B); // Amber 500 (promo)
  static const Color secondarySurface = Color(0xFFFEF3C7); // Amber 50

  // ─── Neutrals ─────────────────────────────────────────
  static const Color background     = Color(0xFFF8FAFC); // Slate 50
  static const Color surface        = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color border         = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocus    = Color(0xFF0D9488); // same as primary

  // ─── Text ─────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary  = Color(0xFF64748B); // Slate 500
  static const Color textTertiary   = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ─── Status ───────────────────────────────────────────
  static const Color success        = Color(0xFF10B981); // Emerald 500
  static const Color successSurface = Color(0xFFECFDF5); // Emerald 50
  static const Color warning        = Color(0xFFF59E0B); // Amber 500
  static const Color warningSurface = Color(0xFFFEF3C7); // Amber 50
  static const Color error          = Color(0xFFEF4444); // Red 500
  static const Color errorSurface   = Color(0xFFFEF2F2); // Red 50
  static const Color info           = Color(0xFF3B82F6); // Blue 500
  static const Color infoSurface    = Color(0xFFEFF6FF); // Blue 50

  // ─── Shadows ──────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}