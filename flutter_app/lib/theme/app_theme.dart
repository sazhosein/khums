import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// پالت رنگی اسلامی «خمس‌یار»
/// سبز زمردی، طلایی، سفید
class AppColors {
  static const emerald = Color(0xFF046A38); // سبز زمردی اصلی
  static const emeraldDark = Color(0xFF024D28);
  static const emeraldLight = Color(0xFF0E8A4C);
  static const gold = Color(0xFFC9A227); // طلایی
  static const goldLight = Color(0xFFE3C766);
  static const goldDark = Color(0xFF9A7B18);
  static const ivory = Color(0xFFFBF9F4); // سفید گرم
  static const white = Color(0xFFFFFFFF);

  // تاریک
  static const nightBg = Color(0xFF0B1F17);
  static const nightSurface = Color(0xFF12291F);
  static const nightCard = Color(0xFF173425);

  static const danger = Color(0xFFB3261E);
  static const warn = Color(0xFFB7791F);
  static const success = Color(0xFF0E8A4C);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        primary: AppColors.emerald,
        secondary: AppColors.gold,
        surface: AppColors.ivory,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ivory,
      textTheme: _textTheme(base.textTheme, AppColors.emeraldDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.emerald.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.vazirmatn(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.emerald.withOpacity(0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.emerald.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        primary: AppColors.emeraldLight,
        secondary: AppColors.gold,
        surface: AppColors.nightSurface,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.nightBg,
      textTheme: _textTheme(base.textTheme, AppColors.ivory),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.nightSurface,
        foregroundColor: AppColors.goldLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.goldLight,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.nightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldLight,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.vazirmatn(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.goldLight, width: 2),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    return GoogleFonts.vazirmatnTextTheme(base).copyWith(
      displayLarge: GoogleFonts.vazirmatn(
        fontSize: 40, fontWeight: FontWeight.w700, color: color,
      ),
      titleLarge: GoogleFonts.vazirmatn(
        fontSize: 20, fontWeight: FontWeight.w700, color: color,
      ),
      titleMedium: GoogleFonts.vazirmatn(
        fontSize: 17, fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.vazirmatn(fontSize: 16, height: 1.8),
      bodyMedium: GoogleFonts.vazirmatn(fontSize: 14, height: 1.7),
      labelLarge: GoogleFonts.vazirmatn(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
    );
  }
}
