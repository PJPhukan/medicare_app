import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  Color get bg         => isDark ? AppColors.dark900  : AppColors.light100;
  Color get cardBg     => isDark ? AppColors.dark800  : Colors.white;
  Color get inputBg    => isDark ? AppColors.dark700  : AppColors.light200;
  Color get borderCol  => isDark ? AppColors.dark600  : AppColors.light300;
  Color get dividerCol => isDark ? AppColors.dark500  : AppColors.light300;

  // ── Text ────────────────────────────────────────────────────────────────────
  Color get primaryText   => isDark ? AppColors.textPrimary        : AppColors.textPrimaryLight;
  Color get secondaryText => isDark ? AppColors.textSecondary      : AppColors.textSecondaryLight;
  Color get hintText      => isDark ? AppColors.textHint           : AppColors.textHintLight;

  // ── System UI ───────────────────────────────────────────────────────────────
  SystemUiOverlayStyle get overlayStyle =>
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
}
