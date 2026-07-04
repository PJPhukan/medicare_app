import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/extensions/context_extensions.dart';
import '../feedback/app_loading.dart';

part '_pressable.dart';
part 'app_icon_button.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  text,
  danger,
  gradient,
}

enum AppButtonSize { sm, md, lg }

// ─── Size extension ───────────────────────────────────────────────────────────

extension AppButtonSizeX on AppButtonSize {
  double get spinnerSize => switch (this) {
        AppButtonSize.sm => 14.0,
        AppButtonSize.md => 16.0,
        AppButtonSize.lg => 18.0,
      };

  double get badgeFontSize => switch (this) {
        AppButtonSize.sm => 9.0,
        AppButtonSize.md => 10.0,
        AppButtonSize.lg => 11.0,
      };

  EdgeInsets get padding => switch (this) {
        AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
      };

  TextStyle get textStyle => switch (this) {
        AppButtonSize.sm => AppTypography.buttonSm,
        AppButtonSize.md => AppTypography.buttonMd,
        AppButtonSize.lg => AppTypography.buttonLg,
      };
}

// ─── AppButton ────────────────────────────────────────────────────────────────

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant     = AppButtonVariant.primary,
    this.size        = AppButtonSize.md,
    this.leading,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.isLoading   = false,
    this.isFullWidth = false,
    this.color,
    this.borderRadius,
  });

  /// Button label — required. For icon-only use AppIconButton.
  final String           label;
  final VoidCallback?    onPressed;
  final AppButtonVariant variant;
  final AppButtonSize    size;

  /// Widget shown to the left of the label (icon, avatar, image, etc.).
  final Widget?          leading;

  /// Widget shown to the right of the label, before badge.
  final Widget?          trailing;

  /// Badge count shown as a pill after trailing.
  final int?             badge;

  /// Badge pill color — defaults to [AppColors.error].
  final Color?           badgeColor;

  final bool             isLoading;

  /// Stretches to parent width when true; wraps content by default.
  final bool             isFullWidth;

  final Color?           color;
  final BorderRadius?    borderRadius;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    Widget btn = _Pressable(
      onPressed: disabled ? null : onPressed,
      child: _buildInner(context, disabled),
    );

    if (isFullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }

  Widget _buildInner(BuildContext context, bool disabled) {
    final br = borderRadius ?? AppBorderRadius.lgAll;
    final fg = _fgColor(context);

    final resolvedPadding = variant == AppButtonVariant.text
        ? EdgeInsets.symmetric(
            horizontal: size.padding.horizontal / 4,
            vertical: size.padding.vertical,
          )
        : size.padding;

    final content = Row(
      mainAxisSize:      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          AppLoadingSpinner(size: size.spinnerSize, color: fg)
        else ...[
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: size.textStyle.copyWith(color: fg),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (badge != null) ...[
            const SizedBox(width: 6),
            _BadgePill(
              count:    badge!,
              color:    badgeColor ?? AppColors.error,
              fontSize: size.badgeFontSize,
            ),
          ],
        ],
      ],
    );

    if (variant == AppButtonVariant.gradient) {
      return Opacity(
        opacity: disabled ? 0.5 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient:     const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
            borderRadius: br,
            boxShadow:    disabled ? [] : AppShadows.button,
          ),
          child: Padding(padding: resolvedPadding, child: content),
        ),
      );
    }

    return AnimatedOpacity(
      duration: AppAnimations.fast,
      opacity:  disabled ? 0.45 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:        _bgColor(context),
          border:       _border(context),
          borderRadius: br,
          boxShadow: (variant == AppButtonVariant.primary && !disabled)
              ? AppShadows.button
              : [],
        ),
        child: Padding(padding: resolvedPadding, child: content),
      ),
    );
  }

  Color _bgColor(BuildContext context) {
    final c = color ?? AppColors.teal;
    return switch (variant) {
      AppButtonVariant.primary   => c,
      AppButtonVariant.secondary => context.inputBg,
      AppButtonVariant.outline   => Colors.transparent,
      AppButtonVariant.ghost     => Colors.transparent,
      AppButtonVariant.text      => Colors.transparent,
      AppButtonVariant.danger    => AppColors.error,
      AppButtonVariant.gradient  => Colors.transparent,
    };
  }

  Color _fgColor(BuildContext context) {
    final c = color ?? AppColors.teal;
    return switch (variant) {
      AppButtonVariant.primary   => AppColors.textInverse,
      AppButtonVariant.secondary => context.primaryText,
      AppButtonVariant.outline   => c,
      AppButtonVariant.ghost     => c,
      AppButtonVariant.text      => c,
      AppButtonVariant.danger    => Colors.white,
      AppButtonVariant.gradient  => AppColors.textInverse,
    };
  }

  Border? _border(BuildContext context) {
    final c = color ?? AppColors.teal;
    return switch (variant) {
      AppButtonVariant.secondary => Border.all(color: context.borderCol),
      AppButtonVariant.outline   => Border.all(color: c),
      AppButtonVariant.danger    => Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      _                          => null,
    };
  }
}

// ─── Badge pill ───────────────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.count,
    required this.color,
    required this.fontSize,
  });

  final int    count;
  final Color  color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize:   fontSize,
          fontWeight: FontWeight.w700,
          color:      Colors.white,
          height:     1,
        ),
      ),
    );
  }
}
