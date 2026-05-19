import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Large greeting / page title block used at the top of main screens.
///
/// ```dart
/// AppPageHeaderText(
///   greeting: 'Good morning,',
///   title: 'Parag 👋',
///   subtitle: 'Here's your health summary for today.',
/// )
/// ```
class AppPageHeaderText extends StatelessWidget {
  const AppPageHeaderText({
    super.key,
    this.greeting,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.padding,
    this.trailing,
  });

  /// Small text shown above [title] (e.g. "Good morning,").
  final String? greeting;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final EdgeInsetsGeometry? padding;

  /// Optional widget aligned to the right of the title row (e.g. an avatar).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (greeting != null)
                  Text(
                    greeting!,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  title,
                  style: AppTypography.h1.copyWith(
                    color: titleColor ?? context.primaryText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
