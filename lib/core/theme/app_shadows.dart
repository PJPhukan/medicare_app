import 'package:flutter/material.dart';

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
