import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Compact pill-shaped action chip.
///
/// Two states: unselected (muted) and selected (accent-tinted).
///
/// ```dart
/// AppChipButton(label: 'Today', onTap: () {})
/// AppChipButton(label: 'Medications', icon: Icons.medication_rounded, selected: true)
/// AppChipButton(label: 'Filter', icon: Icons.tune_rounded, onTap: _openFilter)
/// ```
class AppChipButton extends StatefulWidget {
  const AppChipButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.trailingIcon,
    this.selected = false,
    this.color,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool selected;

  /// Accent colour used when [selected]. Defaults to [AppColors.teal].
  final Color? color;

  final bool enabled;

  @override
  State<AppChipButton> createState() => _AppChipButtonState();
}

class _AppChipButtonState extends State<AppChipButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => !widget.enabled || widget.onTap == null;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final accent  = widget.color ?? AppColors.teal;
    final sel     = widget.selected;

    final bgColor = sel
        ? accent.withValues(alpha: 0.15)
        : (isDark ? AppColors.dark700 : AppColors.light200);
    final fgColor = sel ? accent : context.primaryText;
    final borderColor = sel
        ? accent.withValues(alpha: 0.4)
        : (isDark ? AppColors.dark600 : AppColors.light300);

    return GestureDetector(
      onTapDown: _disabled ? null : (_) => _ctrl.forward(),
      onTapUp: _disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap!();
            },
      onTapCancel: _disabled ? null : () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppBorderRadius.pill,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 14, color: fgColor),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: AppTypography.labelSm.copyWith(
                  color: fgColor,
                  letterSpacing: 0,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 5),
                Icon(widget.trailingIcon, size: 13, color: fgColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
