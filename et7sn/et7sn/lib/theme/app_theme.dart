import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.olive,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.oliveTint,
    onPrimaryContainer: AppColors.oliveDark,
    secondary: AppColors.oliveDark,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.oliveMist,
    onSecondaryContainer: AppColors.oliveDark,
    tertiary: AppColors.gold,
    onTertiary: AppColors.white,
    error: AppColors.negative,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.inkLight,
    onSurfaceVariant: AppColors.inkMutedLight,
    surfaceContainerHighest: Color(0xFFEDEFE8),
    outline: AppColors.lineStrongLight,
    outlineVariant: AppColors.lineLight,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.oliveBright,
    onPrimary: Color(0xFF1F2A0F),
    primaryContainer: AppColors.oliveDark,
    onPrimaryContainer: Color(0xFFDCE8BE),
    secondary: Color(0xFF8FA65A),
    onSecondary: Color(0xFF1F2A0F),
    secondaryContainer: Color(0xFF2F3C1A),
    onSecondaryContainer: Color(0xFFDCE8BE),
    tertiary: AppColors.goldBright,
    onTertiary: Color(0xFF2B2108),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: AppColors.darkSurface,
    onSurface: AppColors.inkDark,
    onSurfaceVariant: AppColors.inkMutedDark,
    surfaceContainerHighest: AppColors.darkSurfaceHigh,
    outline: AppColors.lineStrongDark,
    outlineVariant: AppColors.lineDark,
  );

  static ThemeData light() => _build(_lightScheme, AppColors.offWhite);

  static ThemeData dark() => _build(_darkScheme, AppColors.darkBackground);

  static ThemeData _build(ColorScheme scheme, Color scaffold) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.brightness == Brightness.light
            ? AppColors.oliveDark
            : AppColors.darkSurfaceHigh,
        contentTextStyle: TextStyle(
          color: scheme.brightness == Brightness.light
              ? AppColors.white
              : AppColors.inkDark,
        ),
        shape: shape,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
