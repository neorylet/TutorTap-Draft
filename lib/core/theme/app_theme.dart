import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final TextStyle bodyType = GoogleFonts.dmSans();
    final TextStyle displayType = GoogleFonts.fraunces();

    final ColorScheme scheme = ColorScheme.light(
      primary: AppColors.emerald,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.mint,
      onPrimaryContainer: AppColors.forest,
      secondary: AppColors.pistachio,
      onSecondary: AppColors.forest,
      surface: AppColors.white,
      onSurface: AppColors.forest,
      surfaceContainerHighest: AppColors.sage,
      outline: AppColors.border,
      error: AppColors.brick,
      onError: AppColors.white,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: displayType.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.forest,
      ),
      headlineLarge: displayType.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: AppColors.forest,
      ),
      headlineMedium: displayType.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.forest,
      ),
      headlineSmall: displayType.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.forest,
      ),
      titleLarge: bodyType.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.forest,
      ),
      titleMedium: bodyType.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.forest,
      ),
      bodyLarge: bodyType.copyWith(
        fontSize: 14,
        height: 1.55,
        color: AppColors.forest,
      ),
      bodyMedium: bodyType.copyWith(
        fontSize: 13,
        height: 1.5,
        color: AppColors.forest,
      ),
      bodySmall: bodyType.copyWith(
        fontSize: 11,
        height: 1.4,
        color: AppColors.muted,
      ),
      labelLarge: bodyType.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald,
      ),
      labelMedium: bodyType.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.emerald,
      ),
      labelSmall: bodyType.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.forest,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: bodyType.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.forest,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: bodyType.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.emerald,
          side: const BorderSide(color: AppColors.emerald),
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: bodyType.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brick),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brick, width: 2),
        ),
        hintStyle: bodyType.copyWith(fontSize: 14, color: AppColors.muted),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.forest,
        contentTextStyle: bodyType.copyWith(fontSize: 12, color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.paper,
        selectedItemColor: AppColors.emerald,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: bodyType.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: bodyType.copyWith(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
