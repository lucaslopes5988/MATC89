import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class PlayceColors {
  static const Color primary = Color(0xFFAF232B);
  static const Color primaryContainer = Color(0xFFFF7672);
  static const Color primaryDim = Color(0xFF9E1521);
  static const Color onPrimary = Color(0xFFFFEFEE);

  static const Color secondary = Color(0xFF7345A3);
  static const Color secondaryContainer = Color(0xFFE4C6FF);
  static const Color onSecondaryContainer = Color(0xFF5E2F8D);

  static const Color tertiary = Color(0xFF006761);
  static const Color tertiaryContainer = Color(0xFF85FFF5);

  static const Color surface = Color(0xFFFFF4F4);
  static const Color surfaceContainerLow = Color(0xFFFFECEE);
  static const Color surfaceContainer = Color(0xFFFFE1E5);
  static const Color surfaceContainerHighest = Color(0xFFFFD1D8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF4D212A);
  static const Color onSurfaceVariant = Color(0xFF814C56);
  static const Color outlineVariant = Color(0xFFDD9CA7);

  static const Color error = Color(0xFFB02500);
}

abstract final class PlayceSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class PlayceRadius {
  static const double md = 16;
  static const double lg = 24;
  static const double full = 999;
}

class PlayceTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PlayceColors.primary,
      onPrimary: PlayceColors.onPrimary,
      primaryContainer: PlayceColors.primaryContainer,
      onPrimaryContainer: PlayceColors.onSurface,
      secondary: PlayceColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: PlayceColors.secondaryContainer,
      onSecondaryContainer: PlayceColors.onSecondaryContainer,
      tertiary: PlayceColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: PlayceColors.tertiaryContainer,
      onTertiaryContainer: PlayceColors.tertiary,
      error: PlayceColors.error,
      onError: Colors.white,
      surface: PlayceColors.surface,
      onSurface: PlayceColors.onSurface,
      onSurfaceVariant: PlayceColors.onSurfaceVariant,
      outline: PlayceColors.outlineVariant,
      outlineVariant: PlayceColors.outlineVariant,
    );

    final headlineFont = GoogleFonts.lexendTextTheme();
    final bodyFont = GoogleFonts.beVietnamProTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PlayceColors.surface,
      textTheme: bodyFont.copyWith(
        displayLarge: headlineFont.displayLarge,
        displayMedium: headlineFont.displayMedium,
        displaySmall: headlineFont.displaySmall,
        headlineLarge: headlineFont.headlineLarge,
        headlineMedium: headlineFont.headlineMedium,
        headlineSmall: headlineFont.headlineSmall,
        titleLarge: headlineFont.titleLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: PlayceColors.surface.withValues(alpha: 0.85),
        foregroundColor: PlayceColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: PlayceColors.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PlayceColors.primary,
          foregroundColor: PlayceColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlayceRadius.full),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PlayceColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlayceRadius.md),
          borderSide: BorderSide(
            color: PlayceColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlayceRadius.md),
          borderSide: BorderSide(
            color: PlayceColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlayceRadius.md),
          borderSide: const BorderSide(color: PlayceColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PlayceSpacing.md,
          vertical: PlayceSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        color: PlayceColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlayceRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PlayceColors.secondaryContainer,
        labelStyle: GoogleFonts.beVietnamPro(
          color: PlayceColors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlayceRadius.full),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
