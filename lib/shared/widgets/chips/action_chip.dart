import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_base_chip.dart';

/// A tappable chip that triggers a one-shot action — not selectable.
///
/// Renders with a solid tinted background and an optional leading/trailing icon.
/// Use for quick-action rows: "Share", "Copy", "Remind me", etc.
///
/// ```dart
/// AppActionChip(label: 'Share', icon: Icons.share_rounded, onTap: _share)
/// AppActionChip(label: 'Set Reminder', icon: Icons.alarm_add_rounded, color: AppColors.amber)
/// ```
class AppActionChip extends StatelessWidget {
  const AppActionChip({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.trailingIcon,
    this.color,
    this.size = AppChipSize.md,
    this.borderRadius,
    this.enabled = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Accent colour. Defaults to [AppColors.teal].
  final Color? color;

  final AppChipSize size;
  final BorderRadius? borderRadius;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.teal;
    return AppBaseChip(
      label: label,
      onTap: onTap,
      leadingIcon: icon,
      trailingIcon: trailingIcon,
      color: accent,
      // Always show the tinted "active" look — it's not a toggle
      selected: true,
      selectedBackgroundColor: accent.withValues(alpha: 0.12),
      selectedForegroundColor: accent,
      selectedBorderColor: accent.withValues(alpha: 0.35),
      size: size,
      borderRadius: borderRadius,
      enabled: enabled,
      padding: padding,
    );
  }
}
