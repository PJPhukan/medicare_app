import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_base_card.dart';

/// Card with a drop shadow — use for primary content surfaces.
///
/// ```dart
/// AppElevatedCard(
///   child: ProfileSummary(),
/// )
/// ```
class AppElevatedCard extends StatelessWidget {
  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.raised = false,
    this.effectColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  /// Deepen the corner lighting as well as the drop shadow.
  final bool raised;

  /// Tints the lit corner and the drop shadow — e.g. `AppColors.teal`.
  final Color? effectColor;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AppBaseCard(
      padding: padding,
      margin: margin,
      color: color,
      borderRadius: borderRadius ?? AppBorderRadius.xlAll,
      raised: raised,
      effectColor: effectColor,
      // This is the explicitly-elevated variant, so it keeps the outer shadow
      // that AppCard/AppBaseCard now omit by default.
      shadow: raised
          ? AppShadows.softCardRaised(isDark, color: effectColor)
          : AppShadows.softCard(isDark, color: effectColor),
      onTap: onTap,
      onLongPress: onLongPress,
      width: width,
      height: height,
      child: child,
    );
  }
}
