import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subLabel,
    this.isLoading = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? subLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? AppSkeleton(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                      width: 42,
                      height: 42,
                      borderRadius: AppBorderRadius.mdAll),
                  const SizedBox(height: 14),
                  SkeletonBox(
                      width: 52,
                      height: 26,
                      borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 8),
                  SkeletonBox(
                      width: 68,
                      height: 10,
                      borderRadius: BorderRadius.circular(5)),
                  const SizedBox(height: 5),
                  SkeletonBox(
                      width: 48,
                      height: 9,
                      borderRadius: BorderRadius.circular(5)),
                ],
              ),
            )
          // Icon chip on top, then value, then label — the stacked rhythm of
          // the reference tiles. The old side-by-side row squeezed the number
          // into a FittedBox and ellipsised the labels.
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppContainer.tinted(
                      color: color,
                      borderRadius: AppBorderRadius.mdAll,
                      padding: const EdgeInsets.all(11),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        value,
                        style: AppTypography.statLg.copyWith(color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.bodySm(
                  label,
                  color: context.primaryText,
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subLabel != null) ...[
                  const SizedBox(height: 2),
                  AppText.bodyXs(
                    subLabel!,
                    color: context.secondaryText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
    );
  }
}
