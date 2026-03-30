import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color accent      = Color(0xFF1A1AFF);
  static const Color accentLight = Color(0xFFE8E8FF);
  static const Color ink         = Color(0xFF0A0A0A);
  static const Color ink2        = Color(0xFF3A3A3A);
  static const Color ink3        = Color(0xFF8A8A8A);
  static const Color bg          = Color(0xFFFFFFFF);
  static const Color bg2         = Color(0xFFF5F5F7);
  static const Color border      = Color(0x12000000);
  static const Color border2     = Color(0x21000000);
  static const Color green       = Color(0xFF16A34A);
  static const Color greenLight  = Color(0xFFF0FDF4);
  // Aliases used by original screen files
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color textMuted   = Color(0xFF8A8A8A);
  static const Color starFilled  = Color(0xFFF59E0B);
  static const Color starEmpty   = Color(0xFFDDDDDD);
  // Badge colours
  static const Color badgeSaleFg = Color(0xFFCC0000);
  static const Color badgeSaleBg = Color(0xFFFFF0F0);
  static const Color badgeSaleBd = Color(0xFFFFD5D5);
  static const Color badgeNewFg  = Color(0xFF1A1AFF);
  static const Color badgeNewBg  = Color(0xFFE8E8FF);
  static const Color badgeNewBd  = Color(0xFFD0D0FF);
  static const Color badgeHotFg  = Color(0xFFC06000);
  static const Color badgeHotBg  = Color(0xFFFFF4E8);
  static const Color badgeHotBd  = Color(0xFFFFE0B0);
  // Aliases for screens that reference the short names
static const Color badgeSale = badgeSaleFg;
static const Color badgeNew  = badgeNewFg;
static const Color badgeHot  = badgeHotFg;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        background: AppColors.bg2,
        surface: AppColors.bg,
      ),
      scaffoldBackgroundColor: AppColors.bg2,
      // Use Google Fonts in pubspec — fallback to system sans
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge:  _syne(56, FontWeight.w800, -2.5, AppColors.ink, 0.98),
        displayMedium: _syne(44, FontWeight.w800, -2.0, AppColors.ink, 1.0),
        displaySmall:  _syne(36, FontWeight.w800, -1.5, AppColors.ink, 1.05),
        headlineLarge: _syne(32, FontWeight.w700, -1.5, AppColors.ink, 1.05),
        headlineMedium:_syne(24, FontWeight.w700, -0.8, AppColors.ink, 1.1),
        headlineSmall: _syne(20, FontWeight.w700, -0.5, AppColors.ink, 1.2),
        titleLarge:    _syne(17, FontWeight.w800, -0.4, AppColors.ink, 1.2),
        titleMedium:   GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
        titleSmall:    GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.ink2),
        bodyLarge:     GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.ink3, height: 1.7),
        bodyMedium:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.ink3, height: 1.6),
        bodySmall:     GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w300, color: AppColors.ink3, height: 1.6),
        labelLarge:    GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium:   GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.ink2),
        labelSmall:    GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.ink3, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 17, fontWeight: FontWeight.w800,
          letterSpacing: -0.4, color: AppColors.ink,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink2,
          side: const BorderSide(color: AppColors.border2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink3, fontWeight: FontWeight.w300),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bg2,
        selectedColor: AppColors.ink,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.border2)),
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.ink2),
        secondaryLabelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextStyle _syne(double size, FontWeight weight, double spacing, Color color, double height) =>
      GoogleFonts.syne(fontSize: size, fontWeight: weight, letterSpacing: spacing, color: color, height: height);
}
