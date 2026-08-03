import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../utils/animated_tap.dart';
import '../cards/app_card.dart';

/// Card-style list tile used throughout the app.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.color,
    this.padding,
    this.showChevron = false,
    this.isDestructive = false,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Rich subtitle — for a row of metadata, an inline icon, or tabular figures
  /// that a plain [subtitle] string can't express. Takes precedence over it.
  final Widget? subtitleWidget;

  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool showChevron;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? AppColors.error : context.primaryText;

    Widget tile = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? context.cardBg,
        // borderRadius: AppBorderRadius.xlAll,
        // border: Border.all(color: context.borderCol),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: AppTypography.labelMd.copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitleWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: subtitleWidget!,
                    )
                  else if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!,
                        style: AppTypography.bodySm.copyWith(color: context.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return AnimatedTap(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppBorderRadius.xlAll,
        child: tile,
      );
    }
    return tile;
  }
}

/// Settings-style grouped list section with AppCard styling.
class AppListSection extends StatelessWidget {
  const AppListSection({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.dividerIndent = 56,
    this.hasShadow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.margin = const EdgeInsets.all(10),
  });

  final List<AppListTile> items;
  final String? header;
  final String? footer;
  final double dividerIndent;
  final bool hasShadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(header!,
              style: AppTypography.overline.copyWith(color: AppColors.textHint),
            ),
          ),
        AppCard(
          hasShadow: hasShadow,
          padding: padding,
          margin: margin,
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: e.value,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: dividerIndent,
                      color: context.dividerCol,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(footer!,
                style: AppTypography.caption.copyWith(color: context.secondaryText)),
          ),
      ],
    );
  }
}
