import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppInputTheme {
  AppInputTheme._();

  static final InputDecorationTheme inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 16,
    ),

    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textHint,
    ),

    labelStyle: AppTextStyles.bodyMedium,

    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),

    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,

    border: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.border,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.border,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.danger,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.danger,
        width: 1.5,
      ),
    ),

    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgBorder,
      borderSide: const BorderSide(
        color: AppColors.divider,
      ),
    ),
  );
}