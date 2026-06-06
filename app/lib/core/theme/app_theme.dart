// Single import for all design tokens and theme config.
// In any widget file: import 'package:golden_goals/core/theme/app_theme.dart';

export 'tokens/color_tokens.dart';
export 'tokens/duration_tokens.dart';
export 'tokens/radius_tokens.dart';
export 'tokens/shadow_tokens.dart';
export 'tokens/spacing_tokens.dart';
export 'tokens/typography_tokens.dart';

import 'package:flutter/cupertino.dart';
import 'tokens/color_tokens.dart';

abstract class AppTheme {
  static const cupertinoTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundBase,
    barBackgroundColor: AppColors.backgroundSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.textPrimary,
      textStyle: TextStyle(
        color: AppColors.textPrimary,
        fontFamily: '.SF Pro Text',
      ),
    ),
  );
}
