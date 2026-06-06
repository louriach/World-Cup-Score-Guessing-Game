/// Spacing scale — all layout measurements derive from this.
/// Base unit is 4pt. Never use raw numbers in widgets; use these tokens.
abstract class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Standard horizontal page margin
  static const double pagePadding = base;

  /// Gap between list items
  static const double listGap = sm;

  /// Gap between sections on a screen
  static const double sectionGap = xxl;

  /// Inner card padding
  static const double cardPadding = base;
}
