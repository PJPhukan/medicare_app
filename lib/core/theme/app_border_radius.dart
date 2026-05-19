import 'package:flutter/material.dart';

abstract class AppBorderRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;

  // ─── BorderRadius shortcuts ───────────────────────────────────────────────
  static final BorderRadius xsAll  = BorderRadius.circular(xs);
  static final BorderRadius smAll  = BorderRadius.circular(sm);
  static final BorderRadius mdAll  = BorderRadius.circular(md);
  static final BorderRadius lgAll  = BorderRadius.circular(lg);
  static final BorderRadius xlAll  = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius pill   = BorderRadius.circular(full);

  // ─── Top-only (for bottom sheets, tab bars) ───────────────────────────────
  static final BorderRadius topLg = const BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  static final BorderRadius topXl = const BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  static final BorderRadius topXxl = const BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );

  // ─── Bottom-only ──────────────────────────────────────────────────────────
  static final BorderRadius bottomLg = const BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
}
