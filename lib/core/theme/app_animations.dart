import 'package:flutter/material.dart';

abstract class AppAnimations {
  // ─── Durations ───────────────────────────────────────────────────────────────
  static const Duration ultraFast = Duration(milliseconds: 80);
  static const Duration fast      = Duration(milliseconds: 150);
  static const Duration normal    = Duration(milliseconds: 250);
  static const Duration medium    = Duration(milliseconds: 350);
  static const Duration slow      = Duration(milliseconds: 500);
  static const Duration verySlow  = Duration(milliseconds: 800);

  // ─── Curves ──────────────────────────────────────────────────────────────────
  static const Curve standard      = Curves.easeInOut;
  static const Curve decelerate    = Curves.easeOut;
  static const Curve accelerate    = Curves.easeIn;
  static const Curve spring        = Curves.elasticOut;
  static const Curve bounce        = Curves.bounceOut;
  static const Curve emphasized    = Curves.easeInOutCubicEmphasized;
  static const Curve sharp         = Curves.easeInOutExpo;

  // ─── Page transitions ────────────────────────────────────────────────────────
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve    pageCurve      = Curves.easeInOutCubicEmphasized;

  // ─── Stagger helpers ─────────────────────────────────────────────────────────
  static Duration stagger(int index, {Duration base = const Duration(milliseconds: 60)}) =>
      base * index;

  // ─── Scale values for press feedback ─────────────────────────────────────────
  static const double pressScale    = 0.97;
  static const double hoverScale    = 1.02;
  static const double expandedScale = 1.05;
}
