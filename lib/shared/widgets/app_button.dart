import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_shadows.dart';
import 'app_loading.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger, gradient }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.danger;

  const AppButton.gradient({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  }) : variant = AppButtonVariant.gradient;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailing;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1, end: AppAnimations.pressScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTapDown(_)  => _ctrl.forward();
  void _onTapUp(_)    { _ctrl.reverse(); widget.onPressed?.call(); }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    Widget btn = GestureDetector(
      onTapDown:   disabled ? null : _onTapDown,
      onTapUp:     disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: _buildInner(disabled),
      ),
    );
    if (widget.isFullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }

  Widget _buildInner(bool disabled) {
    final br = widget.borderRadius ?? AppBorderRadius.lgAll;
    final EdgeInsets padding = switch (widget.size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    };
    final TextStyle textStyle = switch (widget.size) {
      AppButtonSize.sm => AppTypography.buttonSm,
      AppButtonSize.md => AppTypography.buttonMd,
      AppButtonSize.lg => AppTypography.buttonLg,
    };
    final iconSize = switch (widget.size) {
      AppButtonSize.sm => 14.0,
      AppButtonSize.md => 16.0,
      AppButtonSize.lg => 18.0,
    };
    final fg = _fgColor();

    final content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          AppLoadingSpinner(size: iconSize, color: fg)
        else ...[
          if (widget.icon != null) ...[
            IconTheme(data: IconThemeData(size: iconSize, color: fg), child: widget.icon!),
            const SizedBox(width: 8),
          ],
          Text(widget.label, style: textStyle.copyWith(color: fg)),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            IconTheme(data: IconThemeData(size: iconSize, color: fg), child: widget.trailing!),
          ],
        ],
      ],
    );

    if (widget.variant == AppButtonVariant.gradient) {
      return Opacity(
        opacity: disabled ? 0.5 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
            borderRadius: br,
            boxShadow: disabled ? [] : AppShadows.button,
          ),
          child: Padding(padding: padding, child: content),
        ),
      );
    }

    return AnimatedOpacity(
      duration: AppAnimations.fast,
      opacity: disabled ? 0.45 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _bgColor(),
          border: _border(),
          borderRadius: br,
          boxShadow: (widget.variant == AppButtonVariant.primary && !disabled)
              ? AppShadows.button : [],
        ),
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  Color _bgColor() {
    final c = widget.color ?? AppColors.teal;
    return switch (widget.variant) {
      AppButtonVariant.primary   => c,
      AppButtonVariant.secondary => AppColors.dark700,
      AppButtonVariant.outline   => Colors.transparent,
      AppButtonVariant.ghost     => Colors.transparent,
      AppButtonVariant.danger    => AppColors.errorBg,
      AppButtonVariant.gradient  => Colors.transparent,
    };
  }

  Color _fgColor() {
    final c = widget.color ?? AppColors.teal;
    return switch (widget.variant) {
      AppButtonVariant.primary   => AppColors.textInverse,
      AppButtonVariant.secondary => AppColors.textPrimary,
      AppButtonVariant.outline   => c,
      AppButtonVariant.ghost     => c,
      AppButtonVariant.danger    => AppColors.error,
      AppButtonVariant.gradient  => AppColors.textInverse,
    };
  }

  Border? _border() {
    final c = widget.color ?? AppColors.teal;
    return switch (widget.variant) {
      AppButtonVariant.outline => Border.all(color: c),
      AppButtonVariant.danger  => Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      _                        => null,
    };
  }
}

// ─── Icon-only button ────────────────────────────────────────────────────────

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 18,
    this.borderRadius,
    this.hasBorder = false,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;
  final bool hasBorder;
  final String? tooltip;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final br  = widget.borderRadius ?? AppBorderRadius.mdAll;
    final fg  = widget.color ?? AppColors.textSecondary;
    final bg  = widget.backgroundColor ?? AppColors.dark700;

    Widget btn = GestureDetector(
      onTapDown:   widget.onPressed == null ? null : (_) => _ctrl.forward(),
      onTapUp:     widget.onPressed == null ? null : (_) { _ctrl.reverse(); widget.onPressed!(); },
      onTapCancel: widget.onPressed == null ? null : () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: br,
            border: widget.hasBorder ? Border.all(color: AppColors.dark600) : null,
          ),
          child: SizedBox(
            width: widget.size, height: widget.size,
            child: Center(
              child: IconTheme(
                data: IconThemeData(size: widget.iconSize, color: fg),
                child: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );

    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: btn)
        : btn;
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class AppFAB extends StatelessWidget {
  const AppFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.color,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: c,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        icon: icon,
        label: Text(label!, style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: c,
      foregroundColor: AppColors.textInverse,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      child: icon,
    );
  }
}
