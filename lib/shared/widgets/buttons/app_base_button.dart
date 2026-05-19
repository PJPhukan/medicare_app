import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

// ─── Size preset ──────────────────────────────────────────────────────────────

enum AppButtonSize { sm, md, lg }

extension AppButtonSizeX on AppButtonSize {
  EdgeInsets get defaultPadding => switch (this) {
        AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      };

  TextStyle get defaultTextStyle => switch (this) {
        AppButtonSize.sm => AppTypography.buttonSm,
        AppButtonSize.md => AppTypography.buttonMd,
        AppButtonSize.lg => AppTypography.buttonLg,
      };

  double get defaultIconSize => switch (this) {
        AppButtonSize.sm => 14.0,
        AppButtonSize.md => 16.0,
        AppButtonSize.lg => 18.0,
      };

  double get spinnerSize => switch (this) {
        AppButtonSize.sm => 13.0,
        AppButtonSize.md => 15.0,
        AppButtonSize.lg => 17.0,
      };
}

// ─── Internal loading spinner ─────────────────────────────────────────────────

class _BtnSpinner extends StatelessWidget {
  const _BtnSpinner({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
}

// ─── Base button ──────────────────────────────────────────────────────────────

/// Fully-configurable base button used by every specialized button variant.
///
/// All properties are optional — defaults fall back to the design-system tokens.
/// Prefer the named subclasses for common patterns and use [AppBaseButton]
/// only when you need pixel-level control.
///
/// Icon placement:
/// - [leadingIcon] / [leadingWidget] — rendered **before** the label
/// - [trailingIcon] / [trailingWidget] — rendered **after** the label
///
/// ```dart
/// AppBaseButton(
///   label: 'Save',
///   leadingIcon: Icons.save_rounded,
///   backgroundColor: AppColors.teal,
///   foregroundColor: Colors.white,
///   borderRadius: AppBorderRadius.pill,
///   onPressed: _save,
/// )
/// ```
class AppBaseButton extends StatefulWidget {
  const AppBaseButton({
    super.key,
    required this.label,
    this.onPressed,
    // ── Icon placement ──────────────────────────────────────────────────────
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.iconSize,
    this.iconSpacing = 8,
    // ── Colours ─────────────────────────────────────────────────────────────
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.gradient,
    // ── Border ──────────────────────────────────────────────────────────────
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius,
    // ── Layout ──────────────────────────────────────────────────────────────
    this.size = AppButtonSize.md,
    this.padding,
    this.isFullWidth = false,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.height,
    // ── Typography ──────────────────────────────────────────────────────────
    this.textStyle,
    this.letterSpacing,
    // ── State ───────────────────────────────────────────────────────────────
    this.isLoading = false,
    this.enabled = true,
    // ── Decoration ──────────────────────────────────────────────────────────
    this.shadow,
    this.pressScale = AppAnimations.pressScale,
  });

  final String label;
  final VoidCallback? onPressed;

  // Icon slots
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final double? iconSize;
  final double iconSpacing;

  // Colours
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Gradient? gradient;

  // Border
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;

  // Layout
  final AppButtonSize size;
  final EdgeInsetsGeometry? padding;
  final bool isFullWidth;
  final MainAxisAlignment mainAxisAlignment;
  final double? height;

  // Typography
  final TextStyle? textStyle;
  final double? letterSpacing;

  // State
  final bool isLoading;
  final bool enabled;

  // Decoration
  final List<BoxShadow>? shadow;
  final double pressScale;

  bool get _isDisabled => !enabled || onPressed == null || isLoading;

  @override
  State<AppBaseButton> createState() => _AppBaseButtonState();
}

class _AppBaseButtonState extends State<AppBaseButton>
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

  void _down(TapDownDetails _) {
    if (!widget._isDisabled) _ctrl.forward();
  }

  void _up(TapUpDetails _) {
    if (!widget._isDisabled) {
      _ctrl.reverse();
      widget.onPressed?.call();
    }
  }

  void _cancel() {
    if (!widget._isDisabled) _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final inner = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: _buildSurface(),
    );

    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      child: widget.isFullWidth
          ? SizedBox(width: double.infinity, child: inner)
          : inner,
    );
  }

  Widget _buildSurface() {
    final isDisabled = widget._isDisabled;
    final pad        = widget.padding ?? widget.size.defaultPadding;
    final iSize      = widget.iconSize ?? widget.size.defaultIconSize;
    final br         = widget.borderRadius ?? AppBorderRadius.lgAll;

    final fg = isDisabled
        ? (widget.disabledForegroundColor ??
            widget.foregroundColor?.withValues(alpha: 0.45) ??
            AppColors.textSecondary)
        : (widget.foregroundColor ?? AppColors.textInverse);

    final bg = isDisabled
        ? (widget.disabledBackgroundColor ??
            widget.backgroundColor?.withValues(alpha: 0.35) ??
            AppColors.dark700)
        : (widget.backgroundColor ?? AppColors.teal);

    final labelStyle =
        (widget.textStyle ?? widget.size.defaultTextStyle).copyWith(
      color: fg,
      letterSpacing: widget.letterSpacing,
    );

    Widget rowContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isLoading)
          _BtnSpinner(size: widget.size.spinnerSize, color: fg)
        else ...[
          // ── Leading ──────────────────────────────────────────────────────
          if (widget.leadingWidget != null) ...[
            widget.leadingWidget!,
            SizedBox(width: widget.iconSpacing),
          ] else if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, size: iSize, color: fg),
            SizedBox(width: widget.iconSpacing),
          ],

          // ── Label ────────────────────────────────────────────────────────
          Flexible(
            child: Text(
              widget.label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Trailing ─────────────────────────────────────────────────────
          if (widget.trailingWidget != null) ...[
            SizedBox(width: widget.iconSpacing),
            widget.trailingWidget!,
          ] else if (widget.trailingIcon != null) ...[
            SizedBox(width: widget.iconSpacing),
            Icon(widget.trailingIcon, size: iSize, color: fg),
          ],
        ],
      ],
    );

    if (widget.height != null) {
      rowContent = SizedBox(height: widget.height, child: rowContent);
    }

    // Gradient variant — no AnimatedOpacity so colours stay vivid
    if (widget.gradient != null && !isDisabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: br,
          border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!, width: widget.borderWidth)
              : null,
          boxShadow: widget.shadow ?? [],
        ),
        child: Padding(padding: pad, child: rowContent),
      );
    }

    return AnimatedOpacity(
      duration: AppAnimations.fast,
      opacity: isDisabled ? 0.5 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: br,
          border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!, width: widget.borderWidth)
              : null,
          boxShadow: isDisabled ? [] : (widget.shadow ?? []),
        ),
        child: Padding(padding: pad, child: rowContent),
      ),
    );
  }
}
