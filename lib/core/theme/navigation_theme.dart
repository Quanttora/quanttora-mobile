import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppNavigationTheme {
  AppNavigationTheme._();

  static final NavigationBarThemeData navigationBarTheme =
      NavigationBarThemeData(
        height: 72,

        backgroundColor: AppColors.surface,

        elevation: 0,

        indicatorColor: AppColors.primary.withValues(alpha: 0.12),

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }

          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navigation.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            );
          }

          return AppTextStyles.navigation.copyWith(
            color: AppColors.textSecondary,
          );
        }),
      );

  static final BottomNavigationBarThemeData bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,

        elevation: 0,

        selectedItemColor: AppColors.primary,

        unselectedItemColor: AppColors.textSecondary,

        selectedLabelStyle: AppTextStyles.navigation.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),

        unselectedLabelStyle: AppTextStyles.navigation.copyWith(
          color: AppColors.textSecondary,
        ),

        type: BottomNavigationBarType.fixed,
      );
}
