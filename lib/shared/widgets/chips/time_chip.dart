import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Displays a scheduled time string with an automatic sun / moon icon.
///
/// Hour <  18 → sun  icon, [sunColor]  (defaults to [AppColors.amber])
/// Hour >= 18 → moon icon, [moonColor] (defaults to [AppColors.purple])
///
/// Example:
///   AppTimeChip(time: '09:00')  // ☀ 09:00
///   AppTimeChip(time: '21:00')  // 🌙 21:00
class AppTimeChip extends StatelessWidget {
  const AppTimeChip({
    super.key,
    required this.time,
    this.sunColor,
    this.moonColor,
    this.padding,
  });

  /// Time string in "HH:MM" format.
  final String time;

  /// Icon color for daytime hours (< 18:00). Defaults to [AppColors.amber].
  final Color? sunColor;

  /// Icon color for night hours (>= 18:00). Defaults to [AppColors.purple].
  final Color? moonColor;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:8, vertical:4)`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bg        = context.inputBg;
    final border    = context.borderCol;
    final hour      = int.tryParse(time.split(':').first) ?? 0;
    final isNight   = hour >= 18;
    final iconColor = isNight
        ? (moonColor ?? AppColors.purple).withValues(alpha: 0.85)
        : (sunColor  ?? AppColors.amber);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            size: 10,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: AppTypography.labelXs.copyWith(
              color: context.primaryText,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
