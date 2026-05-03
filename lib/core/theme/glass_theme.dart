import 'package:flutter/material.dart';

/// Global glass design tokens — single source of truth for all glass surfaces.
class GlassTheme {
  GlassTheme._();

  // ─── Blur ─────────────────────────────────────────────────────────────────
  static const double blurLight = 18.0;
  static const double blurDark = 14.0;
  static const double blurHeavy = 30.0; // modal backgrounds

  // ─── Fill opacities ───────────────────────────────────────────────────────
  static const double fillLightMode = 0.14;
  static const double fillDarkMode = 0.08;
  static const double fillCard = 0.10;
  static const double fillModal = 0.18;
  static const double fillNavBar = 0.12;

  // ─── Border ───────────────────────────────────────────────────────────────
  static const double borderLight = 0.45;
  static const double borderDark = 0.18;
  static const double borderWidth = 1.0;

  // ─── Radius ───────────────────────────────────────────────────────────────
  static const double radiusSmall = 16.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 32.0;
  static const double radiusXL = 40.0;

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const List<Color> backgroundGradientLight = [
    Color(0xFFF2F2F7),
    Color(0xFFEBEBF5),
    Color(0xFFE5E5EA),
    Color(0xFFD1D1D6),
  ];

  static const List<Color> backgroundGradientDark = [
    Color(0xFF1A0A2E),
    Color(0xFF0D1B3E),
    Color(0xFF0A2E2E),
    Color(0xFF2A0A1E),
  ];

  // ─── Glow colors ────────────────────────────────────────────────────────────
  static const Color glowPurple = Color(0x556C35D6);
  static const Color glowBlue = Color(0x553575D6);
  static const Color glowTeal = Color(0x5535C4D6);
  static const Color glowPink = Color(0x55D635A8);

  // ─── Accent ───────────────────────────────────────────────────────────────
  static const Color accentPrimary = Color(0xFF7C4DFF);
  static const Color accentSecondary = Color(0xFF40C4FF);
  static const Color accentSuccess = Color(0xFF69F0AE);
  static const Color accentWarning = Color(0xFFFFD740);
  static const Color accentDanger = Color(0xFFFF5252);

  // ─── Helpers ───────────────────────────────────────────────────────────────

  static Color fillColor(bool isDark) =>
      isDark
          ? Colors.white.withValues(alpha: fillDarkMode)
          : Colors.white.withValues(alpha: fillLightMode);

  static Color borderColor(bool isDark) =>
      isDark
          ? Colors.white.withValues(alpha: borderDark)
          : Colors.white.withValues(alpha: borderLight);

  static double blurSigma(bool isDark) => isDark ? blurDark : blurLight;

  static List<Color> backgroundGradient(bool isDark) =>
      isDark ? backgroundGradientDark : backgroundGradientLight;

  static LinearGradient glassGradient(bool isDark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.03),
              ]
            : [
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.10),
              ],
      );

  static List<BoxShadow> glassShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: accentPrimary.withValues(alpha: isDark ? 0.2 : 0.10),
          blurRadius: 40,
          spreadRadius: -8,
          offset: const Offset(0, 4),
        ),
      ];
}
