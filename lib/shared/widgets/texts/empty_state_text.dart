import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Centered empty-state block with an icon, title, subtitle, and optional CTA.
///
/// ```dart
/// AppEmptyStateText(
///   icon: Icons.medication_outlined,
///   title: 'No medications yet',
///   subtitle: 'Add your first medication to start tracking.',
///   actionLabel: 'Add Medication',
///   onAction: () {},
/// )
/// ```
class AppEmptyStateText extends StatelessWidget {
  const AppEmptyStateText({
    super.key,
    this.icon,
    this.image,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.iconSize = 56,
    this.compact = false,
    this.padding,
  });

  /// Icon displayed above the title. Ignored when [image] is provided.
  final IconData? icon;

  /// Custom image widget (e.g. Lottie / SVG) displayed instead of [icon].
  final Widget? image;

  final String title;
  final String? subtitle;

  /// Primary CTA button label (e.g. "Add Medication").
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional secondary text button below the primary CTA.
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Tint used for the icon background and primary button. Defaults to teal.
  final Color? accentColor;

  final double iconSize;

  /// When true, reduces padding and icon size for use inside cards.
  final bool compact;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final accent     = accentColor ?? AppColors.teal;
    final iconBgSize = iconSize * 1.6;
    final outerPad   = padding ??
        EdgeInsets.symmetric(
          horizontal: compact ? 24 : 32,
          vertical:   compact ? 20 : 40,
        );

    return Padding(
      padding: outerPad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Icon / image ──────────────────────────────────────────────────
          if (image != null)
            image!
          else if (icon != null)
            Container(
              width: iconBgSize,
              height: iconBgSize,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize * 0.6, color: accent),
            ),

          SizedBox(height: compact ? 14 : 20),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: compact
                ? AppTypography.h3
                : AppTypography.h2,
          ),

          // ── Subtitle ──────────────────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          // ── Primary CTA ───────────────────────────────────────────────────
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: compact ? 16 : 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelMd.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],

          // ── Secondary CTA ─────────────────────────────────────────────────
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onSecondaryAction,
              child: Text(
                secondaryActionLabel!,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
