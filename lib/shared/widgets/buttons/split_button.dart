import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';

/// A button split into a main action area and a separate chevron/dropdown area.
///
/// ```dart
/// AppSplitButton(
///   label: 'Download',
///   onPressed: _download,
///   onDropdown: _showOptions,
/// )
/// AppSplitButton(
///   label: 'Share',
///   leadingIcon: Icons.share_rounded,
///   onPressed: _share,
///   onDropdown: _showShareOptions,
///   color: AppColors.blue,
/// )
/// ```
class AppSplitButton extends StatelessWidget {
  const AppSplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.onDropdown,
    this.leadingIcon,
    this.color,
    this.foregroundColor,
    this.size = AppSplitButtonSize.md,
    this.isLoading = false,
    this.enabled = true,
    this.dropdownIcon = Icons.keyboard_arrow_down_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final VoidCallback onDropdown;
  final IconData? leadingIcon;
  final Color? color;
  final Color? foregroundColor;
  final AppSplitButtonSize size;
  final bool isLoading;
  final bool enabled;
  final IconData dropdownIcon;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.teal;
    final fg = foregroundColor ?? Colors.white;
    final (height, hzPad, textStyle, iSize) = switch (size) {
      AppSplitButtonSize.sm => (36.0, 14.0, AppTypography.buttonSm, 13.0),
      AppSplitButtonSize.md => (44.0, 18.0, AppTypography.buttonMd, 15.0),
      AppSplitButtonSize.lg => (52.0, 22.0, AppTypography.buttonLg, 17.0),
    };
    final br = AppBorderRadius.lgAll;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: br,
          boxShadow: AppShadows.button,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main action ──────────────────────────────────────────────────
            _PressArea(
              onTap: enabled && !isLoading ? onPressed : null,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.lg),
                bottomLeft: Radius.circular(AppBorderRadius.lg),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hzPad),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: iSize,
                        height: iSize,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: fg),
                      )
                    else ...[
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, size: iSize, color: fg),
                        const SizedBox(width: 7),
                      ],
                      Text(label,
                          style: textStyle.copyWith(color: fg),
                          maxLines: 1),
                    ],
                  ],
                ),
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────────
            Container(
              width: 1,
              height: height * 0.55,
              color: fg.withValues(alpha: 0.25),
            ),

            // ── Dropdown trigger ─────────────────────────────────────────────
            _PressArea(
              onTap: enabled ? onDropdown : null,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppBorderRadius.lg),
                bottomRight: Radius.circular(AppBorderRadius.lg),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hzPad * 0.6),
                child: Icon(dropdownIcon, size: iSize + 2, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AppSplitButtonSize { sm, md, lg }

// ─── Internal press-ripple helper ─────────────────────────────────────────────

class _PressArea extends StatefulWidget {
  const _PressArea({
    required this.child,
    required this.borderRadius,
    this.onTap,
  });
  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  State<_PressArea> createState() => _PressAreaState();
}

class _PressAreaState extends State<_PressArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: AppAnimations.pressScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _ctrl.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap!();
            },
      onTapCancel: widget.onTap == null ? null : () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: SizedBox.expand(child: Center(child: widget.child)),
      ),
    );
  }
}
