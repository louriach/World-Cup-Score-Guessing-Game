import 'package:flutter/cupertino.dart';

/// Border radius tokens — use these for all rounded corners.
abstract class AppRadius {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 28;
  static const double full = 999; // pill / fully rounded

  // Semantic aliases
  static const double card    = lg;
  static const double button  = md;
  static const double input   = md;
  static const double badge   = full;
  static const double avatar  = full;
  static const double sheet   = xl;   // bottom sheets

  // BorderRadius shortcuts
  static final cardBR   = BorderRadius.circular(card);
  static final buttonBR = BorderRadius.circular(button);
  static final inputBR  = BorderRadius.circular(input);
  static final sheetBR  = BorderRadius.vertical(top: Radius.circular(sheet));
}
