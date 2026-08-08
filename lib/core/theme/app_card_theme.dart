import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

class AppCardTheme {
  AppCardTheme._();

  static final CardThemeData cardTheme = CardThemeData(
    color: AppColors.card,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.lgBorder,
      side: const BorderSide(color: AppColors.border, width: 1),
    ),
  );

  static BoxDecoration primaryCard = BoxDecoration(
    color: AppColors.card,
    borderRadius: AppRadius.lgBorder,
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );

  static BoxDecoration highlightedCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.lgBorder,
    border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
    boxShadow: const [
      BoxShadow(color: Color(0x142563EB), blurRadius: 22, offset: Offset(0, 8)),
    ],
  );

  static BoxDecoration successCard = BoxDecoration(
    color: const Color(0xFFF0FDF4),
    borderRadius: AppRadius.lgBorder,
    border: Border.all(color: AppColors.success),
  );

  static BoxDecoration dangerCard = BoxDecoration(
    color: const Color(0xFFFEF2F2),
    borderRadius: AppRadius.lgBorder,
    border: Border.all(color: AppColors.danger),
  );

  static BoxDecoration infoCard = BoxDecoration(
    color: const Color(0xFFF0F9FF),
    borderRadius: AppRadius.lgBorder,
    border: Border.all(color: AppColors.info),
  );
}
