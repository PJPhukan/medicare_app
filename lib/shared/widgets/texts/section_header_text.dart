import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Section header used between content blocks on a screen.
///
/// ```dart
/// AppSectionHeaderText(
///   title: 'Recent Vitals',
///   subtitle: 'Last 7 days',
///   actionLabel: 'See all',
///   onAction: () {},
///   accentColor: AppColors.teal,
/// )
/// ```
class AppSectionHeaderText extends StatelessWidget {
  const AppSectionHeaderText({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.accentColor,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// Text for the right-side action button (e.g. "See all").
  final String? actionLabel;

  /// Optional icon to show next to [actionLabel].
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Colour of the vertical accent bar shown left of the title.
  /// Pass null to hide the bar.
  final Color? accentColor;

  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  /// Widget shown to the left of the title (e.g. icon, avatar).
  final Widget? leading;

  /// Custom widget shown on the right side of the header.
  /// Takes precedence over [actionLabel] and [actionIcon].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Accent bar ───────────────────────────────────────────────────
          if (accentColor != null)
            Container(
              width: 3,
              height: subtitle != null ? 34 : 20,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: AppBorderRadius.pill,
              ),
            ),

          // ── Leading icon ─────────────────────────────────────────────────
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],

          // ── Title + subtitle ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      AppTypography.h3.copyWith(color: context.primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: subtitleStyle ??
                          AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),

          // ── Trailing element ─────────────────────────────────────────────
          if (trailing != null)
            trailing!
          else if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 0,
                    ),
                  ),
                  if (actionIcon != null) ...[
                    const SizedBox(width: 2),
                    Icon(actionIcon,
                        size: 13, color: AppColors.teal),
                  ] else ...[
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: AppColors.teal),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
