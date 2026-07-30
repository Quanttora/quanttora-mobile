import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppButtonTheme {
  AppButtonTheme._();

  static ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.border,
      disabledForegroundColor: AppColors.textHint,

      elevation: 0,

      minimumSize: const Size(
        double.infinity,
        54,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),

      textStyle: AppTextStyles.buttonLarge,
    ),
  );

  static FilledButtonThemeData filledButtonTheme =
      FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,

      minimumSize: const Size(
        double.infinity,
        54,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),

      textStyle: AppTextStyles.buttonLarge,
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,

      minimumSize: const Size(
        double.infinity,
        54,
      ),

      side: const BorderSide(
        color: AppColors.primary,
        width: 1.2,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),

      textStyle: AppTextStyles.titleMedium.copyWith(
        color: AppColors.primary,
      ),
    ),
  );

  static TextButtonThemeData textButtonTheme =
      TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,

      textStyle: AppTextStyles.titleMedium,

      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
      ),
    ),
  );
}