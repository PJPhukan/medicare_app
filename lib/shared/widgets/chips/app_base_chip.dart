import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

// ─── Size preset ──────────────────────────────────────────────────────────────

enum AppChipSize { sm, md, lg }

extension AppChipSizeX on AppChipSize {
  EdgeInsets get defaultPadding => switch (this) {
        AppChipSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        AppChipSize.md => const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        AppChipSize.lg => const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      };

  double get defaultIconSize => switch (this) {
        AppChipSize.sm => 11.0,
        AppChipSize.md => 13.0,
        AppChipSize.lg => 15.0,
      };

  TextStyle get defaultTextStyle => switch (this) {
        AppChipSize.sm => AppTypography.labelXs,
        AppChipSize.md => AppTypography.labelSm,
        AppChipSize.lg => AppTypography.labelMd,
      };
}

// ─── Base chip ────────────────────────────────────────────────────────────────

/// Fully-configurable base chip used by every specialised chip variant.
///
/// Prefer named subclasses for common patterns. Use [AppBaseChip] only
/// when you need pixel-level control over every property.
///
/// Icon placement:
/// - [leadingIcon] / [leadingWidget] — rendered **before** the label
/// - [trailingIcon] / [trailingWidget] — rendered **after** the label
///
/// Selected behaviour is animated automatically via [AnimatedContainer].
///
/// ```dart
/// AppBaseChip(
///   label: 'Hypertension',
///   leadingIcon: Icons.favorite_rounded,
///   selected: true,
///   color: AppColors.red,
///   onTap: _toggle,
/// )
/// ```
class AppBaseChip extends StatefulWidget {
  const AppBaseChip({
    super.key,
    required this.label,
    this.onTap,
    // ── Icon placement ──────────────────────────────────────────────────────
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.iconSize,
    this.iconSpacing = 5,
    // ── Colours ─────────────────────────────────────────────────────────────
    this.color,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.foregroundColor,
    this.selectedForegroundColor,
    this.borderColor,
    this.selectedBorderColor,
    // ── Border ──────────────────────────────────────────────────────────────
    this.borderWidth = 1,
    this.borderRadius,
    // ── Layout ──────────────────────────────────────────────────────────────
    this.size = AppChipSize.md,
    this.padding,
    // ── Typography ──────────────────────────────────────────────────────────
    this.textStyle,
    this.letterSpacing,
    // ── State ───────────────────────────────────────────────────────────────
    this.selected = false,
    this.enabled = true,
    this.pressScale = 0.94,
  });

  final String label;
  final VoidCallback? onTap;

  // Icon slots
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final double? iconSize;
  final double iconSpacing;

  // Colours — unselected
  /// Accent colour used to derive defaults for all colour slots.
  final Color? color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  // Colours — selected overrides
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final Color? selectedBorderColor;

  // Border
  final double borderWidth;
  final BorderRadius? borderRadius;

  // Layout
  final AppChipSize size;
  final EdgeInsetsGeometry? padding;

  // Typography
  final TextStyle? textStyle;
  final double? letterSpacing;

  // State
  final bool selected;
  final bool enabled;
  final double pressScale;

  @override
  State<AppBaseChip> createState() => _AppBaseChipState();
}

class _AppBaseChipState extends State<AppBaseChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
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

    // ── Resolved colours ────────────────────────────────────────────────────
    final bg = sel
        ? (widget.selectedBackgroundColor ?? accent.withValues(alpha: 0.15))
        : (widget.backgroundColor ??
            (isDark ? AppColors.dark700 : AppColors.light200));

    final fg = sel
        ? (widget.selectedForegroundColor ?? accent)
        : (widget.foregroundColor ??
            (isDark ? AppColors.textSecondary : const Color(0xFF64748B)));

    final bc = sel
        ? (widget.selectedBorderColor ?? accent.withValues(alpha: 0.45))
        : (widget.borderColor ??
            (isDark ? AppColors.dark600 : AppColors.light300));

    // ── Sizes ───────────────────────────────────────────────────────────────
    final pad    = widget.padding ?? widget.size.defaultPadding;
    final iSize  = widget.iconSize ?? widget.size.defaultIconSize;
    final br     = widget.borderRadius ?? AppBorderRadius.pill;

    final labelStyle =
        (widget.textStyle ?? widget.size.defaultTextStyle).copyWith(
      color: fg,
      letterSpacing: widget.letterSpacing ?? 0,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading
        if (widget.leadingWidget != null) ...[
          widget.leadingWidget!,
          SizedBox(width: widget.iconSpacing),
        ] else if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: iSize, color: fg),
          SizedBox(width: widget.iconSpacing),
        ],

        // Label
        Text(widget.label, style: labelStyle),

        // Trailing
        if (widget.trailingWidget != null) ...[
          SizedBox(width: widget.iconSpacing),
          widget.trailingWidget!,
        ] else if (widget.trailingIcon != null) ...[
          SizedBox(width: widget.iconSpacing),
          Icon(widget.trailingIcon, size: iSize, color: fg),
        ],
      ],
    );

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
        child: AnimatedOpacity(
          duration: AppAnimations.fast,
          opacity: _disabled ? 0.45 : 1.0,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.standard,
            padding: pad,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: br,
              border: Border.all(color: bc, width: widget.borderWidth),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
