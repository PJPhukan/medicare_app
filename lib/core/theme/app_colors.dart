import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ─────────────────────────────────────────────────────────────────

  // Updated with your teal palette
  static const teal    = Color(0xFF2D9596);
  static const blue    = Color(0xFF265073);

  // Keeping existing variables
  static const purple  = Color(0xFFA855F7);
  static const amber   = Color(0xFFF59E0B);
  static const red     = Color(0xFFEF4444);
  static const green   = Color(0xFF22C55E);
  static const pink    = Color(0xFFEC4899);

  // Added from palette
  static const mint    = Color(0xFF9AD0C2);
  static const cream   = Color(0xFFECF4D6);

  // ─── Brand tints ────────────────────────────────────────────────────────────

  static const teal10   = Color(0x1A2D9596);
  static const teal20   = Color(0x332D9596);

  static const blue10   = Color(0x1A265073);
  static const blue20   = Color(0x33265073);

  static const purple10 = Color(0x1AA855F7);
  static const amber10  = Color(0x1AF59E0B);
  static const red10    = Color(0x1AEF4444);
  static const green10  = Color(0x1A22C55E);

  // Added tint for new colors
  static const mint10   = Color(0x1A9AD0C2);
  static const mint20   = Color(0x339AD0C2);

  static const cream10  = Color(0x1AECF4D6);
  static const cream20  = Color(0x33ECF4D6);

  // ─── Elevation & surface effects ───────────────────────────────────────────
  // Every shadow / card-gradient ink resolves here, so retheming the app is a
  // change in this file rather than a hunt through widgets.

  /// Ink for drop shadows and the shaded corner of a card gradient (dark mode).
  static const shadowInk      = Color(0xFF000000);

  /// Same, for light mode — a cool slate so shadows don't read as dirty grey.
  static const shadowInkLight = Color(0xFF101828);

  /// Neutral highlight, for surfaces that shouldn't carry a brand hue.
  static const sheenNeutral   = Color(0xFFFFFFFF);

  /// Colour of a card's lit corner when it doesn't name one.
  static const sheenDefault   = teal;

  /// Hairline edge on an elevated card — the surface gradient does the
  /// separating, so this only keeps the top edge from dissolving into the page.
  static const cardEdgeDark   = Color(0x0FFFFFFF); // white @ ~6%
  static const cardEdgeLight  = Color(0xB3E2E8F0); // light300 @ 70%

  // ─── Dark theme backgrounds ────────────────────────────────────────────────

  static const dark900 = Color(0xFF0F172A); // page bg
  static const dark800 = Color(0xFF1E293B); // card bg
  static const dark700 = Color(0xFF265073); // secondary bg / inputs
  static const dark600 = Color(0xFF334155); // border
  static const dark500 = Color(0xFF475569); // dividers

  // ─── Light theme backgrounds ───────────────────────────────────────────────

  // Cards are white and can't get lighter, so in light mode the page carries
  // the contrast instead. At the old #F8FAFC the card's shaded corner landed on
  // the exact page colour and the surface dissolved into it.
  static const light100 = Color(0xFFEDF1F6); // scaffold bg
  static const light200 = Color(0xFFFFFFFF); // card bg
  static const light300 = Color(0xFFE2E8F0); // borders / dividers
  static const light400 = Color(0xFFCBD5E1); // secondary borders

  // ─── Text ──────────────────────────────────────────────────────────────────

  // Light theme text
  static const textPrimaryLight   = Color(0xFF1E293B);
  // Darkened alongside the page background above: at #64748B secondary text
  // fell to 4.2:1 on the new scaffold colour, under the 4.5:1 AA floor. Now
  // 4.8:1 on the page and 5.4:1 on a white card.
  static const textSecondaryLight = Color(0xFF5C6B80);
  static const textHintLight      = Color(0xFF7C8A9C);

  // Dark theme text
  static const textPrimary   = Color(0xFFF0F6FF);
  static const textSecondary = Color(0xFFCBD5E1);
  static const textHint      = Color(0xFF94A3B8);

  static const textInverse   = Color(0xFF0D1117);

  // ─── Semantic ──────────────────────────────────────────────────────────────

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);

  static const successBg = Color(0x1A22C55E);
  static const warningBg = Color(0x1AF59E0B);
  static const errorBg   = Color(0x1AEF4444);
  static const infoBg    = Color(0x1A3B82F6);

  // ─── Buttons ───────────────────────────────────────────────────────────────

  static const primaryButton   = teal;
  static const secondaryButton = blue;
  static const disabledButton  = Color(0xFF94A3B8);

  // ─── Input fields ──────────────────────────────────────────────────────────

  static const inputFillLight   = Color(0xFFF8FAFC);
  static const inputFillDark    = Color(0xFF1E293B);

  static const inputBorderLight = Color(0xFFE2E8F0);
  static const inputBorderDark  = Color(0xFF334155);

  static const focusedBorder    = teal;

  // ─── Dividers & Shadows ────────────────────────────────────────────────────

  static const dividerLight = Color(0xFFE2E8F0);
  static const dividerDark  = Color(0xFF334155);

  static const shadowLight  = Color(0x14000000);
  static const shadowDark   = Color(0x33000000);

  // ─── Status Colors ─────────────────────────────────────────────────────────

  static const online  = Color(0xFF22C55E);
  static const offline = Color(0xFF94A3B8);
  static const busy    = Color(0xFFEF4444);
  static const away    = Color(0xFFF59E0B);

  // ─── Transparent ───────────────────────────────────────────────────────────

  static const transparent = Colors.transparent;
  static const white       = Colors.white;
  static const black       = Colors.black;
}