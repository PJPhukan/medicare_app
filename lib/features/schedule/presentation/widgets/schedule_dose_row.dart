import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../models/presentation_dose.dart';
import '../utils/dose_mapper.dart';

class ScheduleDoseRow extends StatelessWidget {
  const ScheduleDoseRow({
    super.key,
    required this.dose,
    required this.onTake,
    required this.onSkip,
    required this.textColor,
    required this.secondaryColor,
  });

  final PresentationDose dose;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final statusVariant = switch (dose.status) {
      DoseStatus.taken => AppBadgeVariant.green,
      DoseStatus.skipped => AppBadgeVariant.amber,
      DoseStatus.pending => AppBadgeVariant.neutral,
    };
    final statusLabel = switch (dose.status) {
      DoseStatus.taken => AppStrings.taken,
      DoseStatus.skipped => AppStrings.skip,
      DoseStatus.pending => AppStrings.pending,
    };

    final formattedTime = formatTime12h(dose.time);
    final timeParts = formattedTime.split(' ');
    final timeNum = timeParts[0];
    final period = timeParts.length > 1 ? timeParts[1] : '';
    final accentColor = dose.group.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Time Column: 08:30 on line 1, AM on line 2
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.bodyMd(timeNum, color: textColor, fontWeight: FontWeight.w800),
                const SizedBox(height: 2),
                AppText.labelXs(period, color: secondaryColor),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Card using AppCard with effectColor
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
              effectColor: accentColor,
              child: Row(
                children: [
                  // Vertical accent line on left inside of card
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: AppBorderRadius.pill,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name and detail pill
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelLg(
                          dose.name,
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        AppBadge(
                          label:
                              '${dose.unit} · ${DoseMapper.foodTimingLabel(dose.foodTiming)}',
                          variant: dose.group.badgeVariant,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action buttons or Status badge
                  if (dose.status == DoseStatus.pending) ...[
                    AppButton(
                      label: AppStrings.taken,
                      size: AppButtonSize.sm,
                      color: AppColors.green,
                      borderRadius: AppBorderRadius.pill,
                      onPressed: onTake,
                    ),
                    const SizedBox(width: 6),
                    AppButton(
                      label: AppStrings.skip,
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.outline,
                      color: AppColors.amber,
                      borderRadius: AppBorderRadius.pill,
                      onPressed: onSkip,
                    ),
                  ] else
                    AppBadge(
                      label: statusLabel,
                      variant: statusVariant,
                      size: AppBadgeSize.sm,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
