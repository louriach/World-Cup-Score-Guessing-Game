import 'package:flutter/cupertino.dart';
import 'color_tokens.dart';

/// Typography scale — mirrors iOS Dynamic Type roles.
/// Font family defaults to SF Pro (system font on iOS).
abstract class AppTextStyles {
  // --- Display ---
  static const displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // --- Headings ---
  static const heading1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.37,
    height: 1.2,
  );
  static const heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static const heading3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // --- Body ---
  static const bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const bodyLargeBold = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const bodySecondary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- Labels ---
  static const labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // --- Caption ---
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.07,
  );
  static const captionBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.07,
  );

  // --- Score / numeric display ---
  static const scoreDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -1,
  );
  static const scoreLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const scoreMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // --- Leaderboard rank ---
  static const rank = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // --- Brand / special ---
  static const brandTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );
}
