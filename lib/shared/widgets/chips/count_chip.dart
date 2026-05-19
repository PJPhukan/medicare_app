import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A compact badge chip showing a numeric count or short label.
///
/// ```dart
/// AppCountChip(count: 3)                              // "3"
/// AppCountChip(count: 120, max: 99)                   // "99+"
/// AppCountChip(count: 5, color: AppColors.amber)
/// AppCountChip.dot(color: AppColors.error)            // plain dot, no number
/// ```
class AppCountChip extends StatelessWidget {
  const AppCountChip({
    super.key,
    required this.count,
    this.max = 99,
    this.color,
    this.foregroundColor,
    this.size = AppCountChipSize.md,
    this.padding,
  }) : _dot = false;

  const AppCountChip.dot({
    super.key,
    this.color,
    this.size = AppCountChipSize.md,
  })  : count = 0,
        max = 0,
        foregroundColor = null,
        padding = null,
        _dot = true;

  final int count;

  /// Values above [max] display as "[max]+". Default 99.
  final int max;

  /// Badge background colour. Defaults to [AppColors.error].
  final Color? color;

  final Color? foregroundColor;
  final AppCountChipSize size;
  final EdgeInsetsGeometry? padding;
  final bool _dot;

  String get _label {
    if (_dot) return '';
    return count > max ? '$max+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.error;
    final fg = foregroundColor ?? Colors.white;

    final (minDim, fontSize) = switch (size) {
      AppCountChipSize.xs => (14.0, 8.0),
      AppCountChipSize.sm => (16.0, 9.0),
      AppCountChipSize.md => (18.0, 10.0),
      AppCountChipSize.lg => (22.0, 12.0),
    };

    if (_dot) {
      return Container(
        width: minDim * 0.55,
        height: minDim * 0.55,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    }

    return Container(
      constraints: BoxConstraints(minWidth: minDim, minHeight: minDim),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: _label.length > 1 ? minDim * 0.3 : 0,
          ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.pill,
      ),
      child: Center(
        child: Text(
          _label,
          style: AppTypography.labelXs.copyWith(
            color: fg,
            fontSize: fontSize,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

enum AppCountChipSize { xs, sm, md, lg }
