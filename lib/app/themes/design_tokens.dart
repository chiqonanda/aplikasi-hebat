import 'package:flutter/material.dart';
import 'app_colors.dart';

class DesignTokens {
  DesignTokens._();

  // Spacing Tokens
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;
  static const double spacingXxxl = 32;

  // Border Radius Tokens
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // Elevation Values
  static const double elevationNone = 0;
  static const double elevationLow = 2;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

  // Shadow Presets (Neutral)
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Shadow Presets (Role-Specific: Pengelola / Green)
  static List<BoxShadow> get pengelolaShadowSm => [
        BoxShadow(
          color: AppColors.pengelolaMain.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get pengelolaShadowMd => [
        BoxShadow(
          color: AppColors.pengelolaMain.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get pengelolaShadowLg => [
        BoxShadow(
          color: AppColors.pengelolaMain.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Shadow Presets (Role-Specific: Kelurahan / Blue)
  static List<BoxShadow> get kelurahanShadowSm => [
        BoxShadow(
          color: AppColors.kelurahanMain.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get kelurahanShadowMd => [
        BoxShadow(
          color: AppColors.kelurahanMain.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get kelurahanShadowLg => [
        BoxShadow(
          color: AppColors.kelurahanMain.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}
