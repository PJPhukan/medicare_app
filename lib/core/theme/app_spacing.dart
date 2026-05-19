import 'package:flutter/material.dart';

abstract class AppSpacing {
  // ─── Base scale ──────────────────────────────────────────────────────────────
  static const double xxs = 2;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 24;
  static const double x3l = 32;
  static const double x4l = 40;
  static const double x5l = 48;
  static const double x6l = 64;

  // ─── Page padding ────────────────────────────────────────────────────────────
  static const EdgeInsets pagePadding   = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets pageHPadding  = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  // ─── Card padding ─────────────────────────────────────────────────────────────
  static const EdgeInsets cardPadding  = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(xl);

  // ─── Input padding ───────────────────────────────────────────────────────────
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ─── Button padding ──────────────────────────────────────────────────────────
  static const EdgeInsets buttonPaddingLg = EdgeInsets.symmetric(horizontal: xxl, vertical: lg);
  static const EdgeInsets buttonPaddingMd = EdgeInsets.symmetric(horizontal: xl, vertical: md);
  static const EdgeInsets buttonPaddingSm = EdgeInsets.symmetric(horizontal: lg, vertical: sm + 2);

  // ─── Common gaps (as SizedBox) ───────────────────────────────────────────────
  static const SizedBox gapXs  = SizedBox(height: xs);
  static const SizedBox gapSm  = SizedBox(height: sm);
  static const SizedBox gapMd  = SizedBox(height: md);
  static const SizedBox gapLg  = SizedBox(height: lg);
  static const SizedBox gapXl  = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);
  static const SizedBox gapX3l = SizedBox(height: x3l);

  static const SizedBox hGapXs  = SizedBox(width: xs);
  static const SizedBox hGapSm  = SizedBox(width: sm);
  static const SizedBox hGapMd  = SizedBox(width: md);
  static const SizedBox hGapLg  = SizedBox(width: lg);
  static const SizedBox hGapXl  = SizedBox(width: xl);
}
