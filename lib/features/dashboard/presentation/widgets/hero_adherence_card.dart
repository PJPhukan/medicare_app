import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';

/// The one raised surface on the dashboard — everything else sits flatter so
/// this reads as the headline. Accent follows the adherence band.
class HeroAdherenceCard extends StatelessWidget {
  const HeroAdherenceCard({
    super.key,
    required this.percent,
    required this.taken,
    required this.total,
    required this.isLoading,
  });

  final int  percent;
  final int  taken;
  final int  total;
  final bool isLoading;

  Color get _accent => percent >= 90
      ? AppColors.teal
      : percent >= 60
          ? AppColors.amber
          : AppColors.red;

  /// Green is reserved for "achieved" — a perfect week earns it, the ordinary
  /// on-track case stays brand teal so green keeps meaning something.
  AppBadgeVariant get _variant {
    if (percent >= 100 && total > 0) return AppBadgeVariant.green;
    if (percent >= 90) return AppBadgeVariant.teal;
    if (percent >= 60) return AppBadgeVariant.amber;
    return AppBadgeVariant.red;
  }

  ({String label, String headline, String body}) get _status {
    if (total == 0) {
      return (
        label: AppStrings.adherenceNoneLabel,
        headline: AppStrings.adherenceNoneTitle,
        body: AppStrings.adherenceNoneBody,
      );
    }
    if (percent >= 100) {
      return (
        label: AppStrings.adherencePerfectLabel,
        headline: AppStrings.adherencePerfectTitle,
        body: AppStrings.adherencePerfectBody,
      );
    }
    if (percent >= 90) {
      return (
        label: AppStrings.adherenceGoodLabel,
        headline: AppStrings.adherenceGoodTitle,
        body: AppStrings.adherenceGoodBody,
      );
    }
    if (percent >= 60) {
      return (
        label: AppStrings.adherenceFairLabel,
        headline: AppStrings.adherenceFairTitle,
        body: AppStrings.adherenceFairBody,
      );
    }
    return (
      label: AppStrings.adherencePoorLabel,
      headline: AppStrings.adherencePoorTitle,
      body: AppStrings.adherencePoorBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppCard(
        raised: true,
        padding: const EdgeInsets.all(20),
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 84, height: 10, borderRadius: BorderRadius.circular(5)),
              const SizedBox(height: 14),
              SkeletonBox(width: 140, height: 44, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 16),
              SkeletonBox(height: 6, borderRadius: BorderRadius.circular(3)),
            ],
          ),
        ),
      );
    }

    return AppCard(
      raised: true,
      effectColor: _accent,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(label: _status.label, variant: _variant, dot: true),
              const Spacer(),
              Text('$taken/$total taken',
                  style: AppTypography.dataSm.copyWith(color: _accent)),
            ],
          ),
          const SizedBox(height: 12),

          // The sentence is the point: a bare number doesn't tell a patient
          // whether they should act.
          AppText.h3(_status.headline),
          const SizedBox(height: 6),
          AppText.bodySm(_status.body, color: context.secondaryText),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.statXl('$percent', color: _accent),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 2),
                child: AppText.statMd('%',
                    color: _accent.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText.overline(AppStrings.adherenceRate),
          const SizedBox(height: 16),
          // Real progress, not decoration: filled share = doses actually taken.
          ClipRRect(
            borderRadius: AppBorderRadius.pill,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : taken / total,
              minHeight: 6,
              backgroundColor: _accent.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation(_accent),
            ),
          ),
        ],
      ),
    );
  }
}
