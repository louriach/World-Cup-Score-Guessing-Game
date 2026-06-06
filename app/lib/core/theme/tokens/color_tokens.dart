import 'package:flutter/cupertino.dart';

/// Raw colour palette — never use these directly in widgets.
/// Reference semantic tokens from [AppColors] instead.
abstract class _Palette {
  // Brand
  static const gold100 = Color(0xFFFFF8DC);
  static const gold300 = Color(0xFFFFE566);
  static const gold500 = Color(0xFFFFD700); // primary
  static const gold700 = Color(0xFFC9A800);
  static const gold900 = Color(0xFF7A6500);

  // Greens
  static const green400 = Color(0xFF34C759); // iOS system green

  // Reds
  static const red400 = Color(0xFFFF3B30); // iOS system red

  // Neutrals (dark-mode first)
  static const grey50  = Color(0xFFFFFFFF);
  static const grey100 = Color(0xFFF2F2F7);
  static const grey200 = Color(0xFFE5E5EA);
  static const grey400 = Color(0xFF8E8E93);
  static const grey600 = Color(0xFF48484A);
  static const grey700 = Color(0xFF38383A);
  static const grey800 = Color(0xFF2C2C2E);
  static const grey850 = Color(0xFF1C1C1E);
  static const grey900 = Color(0xFF0A0A0A);
  static const black   = Color(0xFF000000);
}

/// Semantic colour tokens — use these everywhere in UI code.
/// To retheme the app, change values here only.
abstract class AppColors {
  // --- Brand ---
  static const primary        = _Palette.gold500;
  static const primaryLight   = _Palette.gold300;
  static const primaryDark    = _Palette.gold700;

  // --- Backgrounds ---
  static const backgroundBase      = _Palette.grey900;  // main scaffold bg
  static const backgroundSurface   = _Palette.grey850;  // cards, sheets
  static const backgroundElevated  = _Palette.grey800;  // elevated cards, modals
  static const backgroundInput     = _Palette.grey800;  // text field bg

  // --- Text ---
  static const textPrimary    = _Palette.grey50;
  static const textSecondary  = _Palette.grey400;
  static const textDisabled   = _Palette.grey600;
  static const textInverse    = _Palette.black;
  static const textBrand      = _Palette.gold500;

  // --- Borders ---
  static const borderSubtle   = _Palette.grey700;
  static const borderDefault  = _Palette.grey600;
  static const borderActive   = _Palette.gold500;
  static const borderSuccess  = _Palette.green400;
  static const borderError    = _Palette.red400;

  // --- Status ---
  static const success  = _Palette.green400;
  static const error    = _Palette.red400;
  static const warning  = _Palette.gold300;

  // --- Interactive ---
  static const buttonPrimary        = _Palette.gold500;
  static const buttonPrimaryLabel   = _Palette.black;
  static const buttonSecondary      = _Palette.grey800;
  static const buttonSecondaryLabel = _Palette.grey50;
  static const buttonDisabled       = _Palette.grey700;
  static const buttonDisabledLabel  = _Palette.grey400;

  // --- Score input specific ---
  static const scoreFieldIdle     = _Palette.grey600;
  static const scoreFieldActive   = _Palette.gold500;
  static const scoreFieldSuccess  = _Palette.green400;
}
