import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../utils/animated_tap.dart';

// ─── Medicine type icon ───────────────────────────────────────────────────────

class MedicineTypeIcon extends StatelessWidget {
  const MedicineTypeIcon({super.key, required this.type, this.size = 40, this.color});

  final String type;
  final double size;
  final Color? color;

  static IconData _icon(String type) => switch (type.toLowerCase()) {
    'tablet'   => Icons.tablet_rounded,
    'capsule'  => Icons.medication_rounded,
    'liquid'   => Icons.water_drop_rounded,
    'injection'=> Icons.colorize_rounded,
    'drops'    => Icons.opacity_rounded,
    'inhaler'  => Icons.air_rounded,
    'patch'    => Icons.square_rounded,
    _          => Icons.medication_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.lgAll,
      ),
      child: Icon(_icon(type), color: c, size: size * 0.48),
    );
  }
}

// ─── Medicine list card ───────────────────────────────────────────────────────

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.type = 'tablet',
    this.color,
    this.nextDoseTime,
    this.adherencePercent,
    this.onTap,
    this.onEdit,
    this.isActive = true,
  });

  final String name;
  final String dosage;
  final String frequency;
  final String type;
  final Color? color;
  final String? nextDoseTime;
  final double? adherencePercent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;

    return AnimatedTap(
      onTap: onTap,
      borderRadius: AppBorderRadius.xlAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(color: isActive ? c.withValues(alpha: 0.2) : context.borderCol),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              MedicineTypeIcon(type: type, color: isActive ? c : AppColors.textHint),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      '$dosage · $frequency',
                      style: AppTypography.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (nextDoseTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            'Next: $nextDoseTime',
                            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (adherencePercent != null) ...[
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      '${adherencePercent!.round()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: adherencePercent! >= 80 ? AppColors.green
                            : adherencePercent! >= 50 ? AppColors.amber
                            : AppColors.error,
                      ),
                    ),
                    Text(AppStrings.adherenceRate.split(' ').first,
                      style: AppTypography.bodyXs,
                    ),
                  ],
                ),
              ],
              if (onEdit != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textHint),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Adherence streak bar ─────────────────────────────────────────────────────

class AdherenceStreakBar extends StatelessWidget {
  const AdherenceStreakBar({
    super.key,
    required this.days,
    this.color,
    this.size = 28,
    this.spacing = 4,
  });

  final List<bool?> days; // true=taken, false=missed, null=upcoming
  final Color? color;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: days.map((taken) {
        final dotColor = taken == null
            ? context.borderCol
            : taken ? c : AppColors.error;
        return Container(
          width: size, height: size,
          margin: EdgeInsets.only(right: spacing),
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: taken == null ? 0.3 : 0.15),
            borderRadius: AppBorderRadius.smAll,
            border: Border.all(color: dotColor.withValues(alpha: taken == null ? 0.2 : 0.5)),
          ),
          child: taken != null
              ? Icon(
                  taken ? Icons.check_rounded : Icons.close_rounded,
                  size: size * 0.5,
                  color: dotColor,
                )
              : null,
        );
      }).toList(),
    );
  }
}
