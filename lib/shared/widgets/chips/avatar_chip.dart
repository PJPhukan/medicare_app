import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// A chip with a leading user avatar — circular image, initials, or icon.
///
/// Useful for assignees, participants, healthcare providers, and contact lists.
/// Supports an optional trailing remove (×) button.
///
/// ```dart
/// AppAvatarChip(label: 'Dr. Meera', initials: 'MM')
/// AppAvatarChip(label: 'Parag', imageUrl: user.avatarUrl, onRemove: _remove)
/// AppAvatarChip(label: 'Assigned', imageBytes: pickedBytes, selected: true)
/// ```
class AppAvatarChip extends StatefulWidget {
  const AppAvatarChip({
    super.key,
    required this.label,
    this.sublabel,
    this.imageUrl,
    this.imageBytes,
    this.initials,
    this.avatarIcon,
    this.avatarSize = 24,
    this.color,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.size = AppAvatarChipSize.md,
    this.enabled = true,
    this.padding,
  });

  final String label;

  /// Optional secondary text shown below [label] (e.g. role, specialty).
  final String? sublabel;

  final String? imageUrl;
  final Uint8List? imageBytes;

  /// 1–2 character initials shown when no image is available.
  final String? initials;

  /// Icon shown when neither image nor initials are provided.
  final IconData? avatarIcon;

  final double avatarSize;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  /// When provided, renders a × button on the trailing edge.
  final VoidCallback? onRemove;

  final AppAvatarChipSize size;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppAvatarChip> createState() => _AppAvatarChipState();
}

class _AppAvatarChipState extends State<AppAvatarChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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

    final bg = sel
        ? accent.withValues(alpha: 0.12)
        : (isDark ? AppColors.dark700 : AppColors.light200);
    final bc = sel
        ? accent.withValues(alpha: 0.4)
        : (isDark ? AppColors.dark600 : AppColors.light300);

    final (hzPad, vyPad, labelStyle) = switch (widget.size) {
      AppAvatarChipSize.sm => (8.0, 4.0, AppTypography.labelXs),
      AppAvatarChipSize.md => (10.0, 6.0, AppTypography.labelSm),
      AppAvatarChipSize.lg => (12.0, 8.0, AppTypography.labelMd),
    };

    final fgColor = sel ? accent : context.primaryText;

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
            padding: widget.padding ??
                EdgeInsets.symmetric(horizontal: hzPad, vertical: vyPad),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppBorderRadius.pill,
              border: Border.all(color: bc),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Avatar ──────────────────────────────────────────────────
                _Avatar(
                  size: widget.avatarSize,
                  imageUrl: widget.imageUrl,
                  imageBytes: widget.imageBytes,
                  initials: widget.initials,
                  icon: widget.avatarIcon,
                  color: accent,
                ),
                const SizedBox(width: 7),

                // ── Label (+ sublabel) ───────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: labelStyle.copyWith(
                        color: fgColor,
                        letterSpacing: 0,
                      ),
                    ),
                    if (widget.sublabel != null)
                      Text(
                        widget.sublabel!,
                        style: AppTypography.bodyXs.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),

                // ── Remove button ────────────────────────────────────────────
                if (widget.onRemove != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar helper ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.size,
    this.imageUrl,
    this.imageBytes,
    this.initials,
    this.icon,
    required this.color,
  });

  final double size;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? initials;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.cover)
            : imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : Container(
                    color: color.withValues(alpha: 0.15),
                    child: Center(
                      child: initials != null
                          ? Text(
                              initials!.toUpperCase().characters.take(2).string,
                              style: TextStyle(
                                fontSize: size * 0.35,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            )
                          : Icon(
                              icon ?? Icons.person_rounded,
                              size: size * 0.55,
                              color: color.withValues(alpha: 0.7),
                            ),
                    ),
                  ),
      ),
    );
  }
}

enum AppAvatarChipSize { sm, md, lg }
