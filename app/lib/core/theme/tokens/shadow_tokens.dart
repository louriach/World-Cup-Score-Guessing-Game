import 'package:flutter/cupertino.dart';
import 'color_tokens.dart';

/// Shadow / elevation tokens.
abstract class AppShadows {
  static const cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const goldGlow = [
    BoxShadow(
      color: Color(0x66FFD700),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  static const subtleShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
