import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ─────────────────────────────────────────────────────────────────
  static const teal    = Color(0xFF00E5C3);
  static const blue    = Color(0xFF4D9EFF);
  static const purple  = Color(0xFFA855F7);
  static const amber   = Color(0xFFF59E0B);
  static const red     = Color(0xFFEF4444);
  static const green   = Color(0xFF22C55E);
  static const pink    = Color(0xFFEC4899);

  // ─── Brand tints ────────────────────────────────────────────────────────────
  static const teal10  = Color(0x1A00E5C3);
  static const teal20  = Color(0x3300E5C3);
  static const blue10  = Color(0x1A4D9EFF);
  static const blue20  = Color(0x334D9EFF);
  static const purple10 = Color(0x1AA855F7);
  static const amber10  = Color(0x1AF59E0B);
  static const red10    = Color(0x1AEF4444);
  static const green10  = Color(0x1A22C55E);

  // ─── Dark theme backgrounds ─────────────────────────────────────────────────
  static const dark900 = Color(0xFF0B0F14); // page bg
  static const dark800 = Color(0xFF131920); // card bg
  static const dark700 = Color(0xFF1A2332); // secondary bg / inputs
  static const dark600 = Color(0xFF1F2D3F); // border
  static const dark500 = Color(0xFF2A3A4E); // dividers

  // ─── Light theme backgrounds ────────────────────────────────────────────────
  static const light100 = Color(0xFFF8FAFC);
  static const light200 = Color(0xFFF1F5F9);
  static const light300 = Color(0xFFE2E8F0);
  static const light400 = Color(0xFFCBD5E1);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF0F6FF);
  static const textSecondary = Color(0xFF8B9BB4);
  static const textHint      = Color(0xFF4A5568);
  static const textInverse   = Color(0xFF0D1117);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF4D9EFF);

  static const successBg = Color(0x1A22C55E);
  static const warningBg = Color(0x1AF59E0B);
  static const errorBg   = Color(0x1AEF4444);
  static const infoBg    = Color(0x1A4D9EFF);

  // ─── Transparent ───────────────────────────────────────────────────────────
  static const transparent = Colors.transparent;
  static const white       = Colors.white;
  static const black       = Colors.black;
}
