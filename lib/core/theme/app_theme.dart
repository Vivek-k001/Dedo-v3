import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return _buildTheme(brightness: Brightness.light);
  }

  static ThemeData dark() {
    return _buildTheme(brightness: Brightness.dark);
  }

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassTheme.accentPrimary,
        brightness: brightness,
      ).copyWith(
        primary: GlassTheme.accentPrimary,
        secondary: GlassTheme.accentSecondary,
        surface: Colors.transparent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Colors.white.withValues(alpha: 0.9)
              : const Color(0xFF2A1A3E),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isDark
              ? Colors.white.withValues(alpha: 0.85)
              : const Color(0xFF3A2A4E),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          color: isDark
              ? Colors.white.withValues(alpha: 0.65)
              : const Color(0xFF5A4A6E),
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Colors.white.withValues(alpha: 0.50)
              : const Color(0xFF7A6A8E),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GlassTheme.accentPrimary.withValues(alpha: 0.9),
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.outfit(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : const Color(0xFF5A4A6E),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
