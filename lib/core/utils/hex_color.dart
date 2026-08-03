import 'package:flutter/material.dart';

/// "#3B82F6" or "3B82F6" → opaque Color. Accepts 6-digit RGB (alpha assumed
/// FF) or 8-digit ARGB hex, with or without the leading '#'. These values
/// come from the server (vital/note colors); malformed input falls back to
/// [fallback] instead of throwing, so one bad record doesn't crash a screen.
Color hexToColor(String hex, {Color fallback = const Color(0xFF9E9E9E)}) {
  final h = hex.replaceFirst('#', '');
  if (h.length != 6 && h.length != 8) return fallback;
  final value = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return value == null ? fallback : Color(value);
}
