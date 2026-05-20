import 'package:flutter/material.dart';
import 'package:cima_mens/utils/constants.dart';

/// Centralized theme configuration for the FlowMate app.
///
/// Provides a [getTheme] factory method that builds a complete
/// [ThemeData] based on the user's selected color palette.
class FlowMateTheme {
  FlowMateTheme._(); // prevent instantiation

  // ──────────────────────────────────────────────
  // Font family
  // ──────────────────────────────────────────────

  /// Primary font family. Uses Poppins (must be added to pubspec.yaml
  /// assets, or use google_fonts package).
  static const String _fontFamily = 'Poppins';

  // ──────────────────────────────────────────────
  // Theme builder
  // ──────────────────────────────────────────────

  /// Build a complete [ThemeData] for the given [themeColor] key.
  ///
  /// Supported keys: `'pink'`, `'peach'`, `'lavender'`.
  static ThemeData getTheme(String themeColor) {
    final palette = FlowMateConstants.getPalette(themeColor);

    final primary = palette['primary']!;
    final primaryLight = palette['primaryLight']!;
    final background = palette['background']!;
    final surface = palette['surface']!;
    final card = palette['card']!;
    final onPrimary = palette['onPrimary']!;
    final textPrimary = palette['textPrimary']!;
    final textSecondary = palette['textSecondary']!;

    final colorScheme = ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight,
      secondary: palette['accent']!,
      secondaryContainer: primaryLight,
      surface: surface,
      error: const Color(0xFFD32F2F),
      onPrimary: onPrimary,
      onSecondary: onPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      brightness: Brightness.light,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        iconTheme: IconThemeData(color: onPrimary),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Elevated buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined buttons ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Floating action button ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Input decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: textSecondary,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: textSecondary.withValues(alpha: 0.6),
        ),
      ),

      // ── Bottom navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
        ),
      ),

      // ── Chip theme ──
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        selectedColor: primary,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          color: textPrimary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          color: onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── Dialog theme ──
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // ── Text theme ──
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }
}
