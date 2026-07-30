import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_constants.dart';
import 'app_text_styles.dart';
import 'button_theme.dart';
import 'app_card_theme.dart';
import 'input_theme.dart';
import 'navigation_theme.dart';

class AppTheme {
  AppTheme._();

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: AppConstants.appBarHeight,
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 22,
    ),
    titleTextStyle: AppTextStyles.titleLarge,
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: _appBarTheme,

      cardTheme: AppCardTheme.cardTheme,

      elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
      filledButtonTheme: AppButtonTheme.filledButtonTheme,
      outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
      textButtonTheme: AppButtonTheme.textButtonTheme,

      inputDecorationTheme: AppInputTheme.inputDecorationTheme,

      navigationBarTheme: AppNavigationTheme.navigationBarTheme,
      bottomNavigationBarTheme:
          AppNavigationTheme.bottomNavigationBarTheme,

      dividerColor: AppColors.divider,

      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 22,
      ),

      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,

        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,

        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,

        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,

        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}