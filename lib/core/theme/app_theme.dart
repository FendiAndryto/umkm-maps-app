import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─── Spacing ────────────────────────────────────────────
  static const double spaceXs  = 4.0;
  static const double spaceSm  = 8.0;
  static const double spaceMd  = 16.0;
  static const double spaceLg  = 24.0;
  static const double spaceXl  = 32.0;
  static const double space2xl = 48.0;

  // ─── Border Radius ──────────────────────────────────────
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 20.0;
  static const double radius2xl = 28.0;
  static const double radiusFull = 999.0;

  static BorderRadius get roundedSm   => BorderRadius.circular(radiusSm);
  static BorderRadius get roundedMd   => BorderRadius.circular(radiusMd);
  static BorderRadius get roundedLg   => BorderRadius.circular(radiusLg);
  static BorderRadius get roundedXl   => BorderRadius.circular(radiusXl);
  static BorderRadius get rounded2xl  => BorderRadius.circular(radius2xl);
  static BorderRadius get roundedFull => BorderRadius.circular(radiusFull);

  // ─── Text Styles ────────────────────────────────────────
  static TextStyle get headingXl => GoogleFonts.plusJakartaSans(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
    height: 1.2, letterSpacing: -0.5,
  );
  static TextStyle get headingLg => GoogleFonts.plusJakartaSans(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    height: 1.3, letterSpacing: -0.3,
  );
  static TextStyle get headingMd => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    height: 1.3,
  );
  static TextStyle get headingSm => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    height: 1.4,
  );
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.5,
  );
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.5,
  );
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.5,
  );
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
  static TextStyle get priceLg => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary,
  );
  static TextStyle get priceMd => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontSize: 16,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary, fontSize: 14,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          color: AppColors.textTertiary, fontSize: 12,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        shadowColor: AppColors.border,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textTertiary, fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary, fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
      ),
    );
  }
}