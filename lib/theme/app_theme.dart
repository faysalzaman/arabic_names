import 'package:flutter/material.dart';

/// Ivory paper, deep emerald and gold: the palette of classic Arabic manuscripts.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAF6EE); // ivory
  static const Color surface = Colors.white;
  static const Color emerald = Color(0xFF0E4D3C);
  static const Color emeraldDark = Color(0xFF07332A);
  static const Color gold = Color(0xFFC9A04E);
  static const Color goldSoft = Color(0xFFF4E9CF);
  static const Color ink = Color(0xFF1F2A26);
  static const Color muted = Color(0xFF6E7772);
  static const Color line = Color(0xFFEAE2D2);
  static const Color boy = Color(0xFF2C6E8E);
  static const Color girl = Color(0xFFB4507A);
  static const Color favourite = Color(0xFFD64545);
}

class AppFonts {
  AppFonts._();

  /// Clean, highly legible UI font.
  static const String ui = 'Tajawal';

  /// Classic Naskh for the names themselves and their meanings.
  static const String naskh = 'Amiri';

  /// Ruqaa calligraphy for decorative titles only.
  static const String ruqaa = 'ArefRuqaa';
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.emerald,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.emerald,
    onPrimary: Colors.white,
    secondary: AppColors.gold,
    onSecondary: AppColors.emeraldDark,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.ui,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: const AppBarTheme(
      // Matches the top of PatternHeader's gradient so the two read as one band.
      backgroundColor: AppColors.emeraldDark,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.naskh,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.emerald,
      suffixIconColor: AppColors.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: AppFonts.ui, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.emerald,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.gold,
      dividerColor: AppColors.line,
      labelStyle: TextStyle(fontFamily: AppFonts.ui, fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: TextStyle(fontFamily: AppFonts.ui, fontSize: 15),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.emeraldDark,
      contentTextStyle: TextStyle(fontFamily: AppFonts.ui, color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.gold),
  );
}
