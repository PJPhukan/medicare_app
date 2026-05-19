import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Inline text hyperlink button — no background, no border, optional underline.
///
/// ```dart
/// AppLinkButton(label: 'Forgot password?', onPressed: _forgot)
/// AppLinkButton(label: 'See all', trailingIcon: Icons.arrow_forward_ios_rounded, size: AppButtonSize.sm)
/// AppLinkButton(label: 'Terms & Conditions', underline: true)
/// ```
class AppLinkButton extends StatefulWidget {
  const AppLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
    this.textStyle,
    this.underline = false,
    this.iconSize = 13,
    this.iconSpacing = 4,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Text/icon colour. Defaults to [AppColors.teal].
  final Color? color;

  final TextStyle? textStyle;

  /// When true, shows a permanent underline decoration.
  final bool underline;

  final double iconSize;
  final double iconSpacing;
  final bool enabled;

  @override
  State<AppLinkButton> createState() => _AppLinkButtonState();
}

class _AppLinkButtonState extends State<AppLinkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _opacity =
        Tween<double>(begin: 1.0, end: 0.55).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => !widget.enabled || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.teal;
    final style = (widget.textStyle ?? AppTypography.labelSm).copyWith(
      color: c,
      letterSpacing: 0,
      decoration: widget.underline ? TextDecoration.underline : null,
      decorationColor: c,
    );

    return GestureDetector(
      onTapDown: _disabled ? null : (_) => _ctrl.forward(),
      onTapUp: _disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onPressed!();
            },
      onTapCancel: _disabled ? null : () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (_, child) =>
            Opacity(opacity: _disabled ? 0.4 : _opacity.value, child: child),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(widget.leadingIcon, size: widget.iconSize, color: c),
              SizedBox(width: widget.iconSpacing),
            ],
            Text(widget.label, style: style),
            if (widget.trailingIcon != null) ...[
              SizedBox(width: widget.iconSpacing),
              Icon(widget.trailingIcon, size: widget.iconSize, color: c),
            ],
          ],
        ),
      ),
    );
  }
}
