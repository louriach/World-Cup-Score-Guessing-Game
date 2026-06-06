/// Animation duration tokens — keeps motion consistent across the app.
abstract class AppDurations {
  static const instant  = Duration(milliseconds: 100);
  static const fast     = Duration(milliseconds: 150); // button state changes
  static const standard = Duration(milliseconds: 250); // most transitions
  static const medium   = Duration(milliseconds: 350); // sheet presentation
  static const slow     = Duration(milliseconds: 500); // celebration / reveal
}
