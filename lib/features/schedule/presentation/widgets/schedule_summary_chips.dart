import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

class ScheduleSummaryChips extends StatelessWidget {
  const ScheduleSummaryChips({
    super.key,
    required this.totalCount,
    required this.takenCount,
    required this.skippedCount,
  });

  final int totalCount;
  final int takenCount;
  final int skippedCount;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AppBadge(
            label: '$totalCount total',
            variant: AppBadgeVariant.neutral,
          ),
          const SizedBox(width: 8),
          AppBadge(
            label: '$takenCount ${AppStrings.taken}',
            variant: AppBadgeVariant.green,
          ),
          if (skippedCount > 0) ...[
            const SizedBox(width: 8),
            AppBadge(
              label: '$skippedCount ${AppStrings.skip}',
              variant: AppBadgeVariant.amber,
            ),
          ],
        ],
      ),
    );
  }
}
