import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppShadows {
  // ─── Card shadows ────────────────────────────────────────────────────────────
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Soft "raised slab" card elevation ───────────────────────────────────────
  // Two layers: a tight contact shadow that anchors the corners, plus a wide
  // diffuse one that lifts the whole surface. Dark surfaces need a deeper,
  // wider shadow to read as raised at all.
  /// Default shadow ink. Dark mode goes to pure black; light mode uses a cool
  /// slate so the shadow doesn't read as dirty grey on white.
  static Color _defaultInk(bool isDark) =>
      isDark ? AppColors.shadowInk : AppColors.shadowInkLight;

  /// Soft "raised slab" elevation.
  ///
  /// Pass [color] to tint the glow — e.g. `AppShadows.softCard(isDark,
  /// color: AppColors.teal)` for an accent card. A tinted glow reads much
  /// weaker than black, so it is given more alpha to land at the same weight.
  static List<BoxShadow> softCard(bool isDark, {Color? color}) =>
      _slab(isDark, color, raised: false);

  /// Stronger elevation for the one hero / "recommended" card on a screen.
  static List<BoxShadow> softCardRaised(bool isDark, {Color? color}) =>
      _slab(isDark, color, raised: true);

  static List<BoxShadow> _slab(bool isDark, Color? color, {required bool raised}) {
    final ink    = color ?? _defaultInk(isDark);
    final tinted = color != null;

    // Wide diffuse layer that lifts the surface…
    final spreadAlpha = switch ((raised, isDark, tinted)) {
      (true,  true,  _)     => 0.62,
      (true,  false, true)  => 0.34,
      (true,  false, false) => 0.20,
      (false, true,  _)     => 0.48,
      (false, false, true)  => 0.24,
      (false, false, false) => 0.13,
    };
    // …and a tight contact layer that anchors the corners.
    final contactAlpha = spreadAlpha * 0.55;

    return [
      BoxShadow(
        color: ink.withValues(alpha: spreadAlpha),
        blurRadius: raised ? 34 : 22,
        offset: Offset(0, raised ? 14 : 8),
        spreadRadius: raised ? -6 : -4,
      ),
      BoxShadow(
        color: ink.withValues(alpha: contactAlpha),
        blurRadius: raised ? 10 : 6,
        offset: Offset(0, raised ? 4 : 2),
        spreadRadius: -2,
      ),
    ];
  }

  // ─── Button shadows ──────────────────────────────────────────────────────────
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x2900e5c3),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonDanger = [
    BoxShadow(
      color: Color(0x29ef4444),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // ─── Glow shadows ────────────────────────────────────────────────────────────
  static List<BoxShadow> glow(Color color, {double intensity = 0.3, double blur = 24}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: blur,
      spreadRadius: 0,
    ),
  ];

  // ─── Modal / Bottom-sheet shadow ─────────────────────────────────────────────
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 40,
      offset: Offset(0, -8),
    ),
  ];

  // ─── Floating action button ──────────────────────────────────────────────────
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x4000e5c3),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Avatar shadow ───────────────────────────────────────────────────────────
  static const List<BoxShadow> avatar = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ─── Input focus ring ────────────────────────────────────────────────────────
  static const List<BoxShadow> inputFocus = [
    BoxShadow(
      color: Color(0x3300e5c3),
      blurRadius: 0,
      spreadRadius: 2,
    ),
  ];

  // ─── None ────────────────────────────────────────────────────────────────────
  static const List<BoxShadow> none = [];
}
