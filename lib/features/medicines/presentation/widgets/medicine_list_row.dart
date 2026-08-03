import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import 'medicine_status.dart';

/// Row for one cabinet entry, used by the list view.
///
/// Mirrors [MedicineGridCard]'s composition (icon beside identity, then dose
/// times, then stock) rather than cramming stock/schedule/course/scope into
/// one packed line of tiny icon+text fragments — that's what made the
/// previous version look cluttered, and risked overflowing on a narrow
/// screen since a [Row] of five fixed-width fragments has nowhere to give.
class MedicineListRow extends StatelessWidget {
  const MedicineListRow({
    super.key,
    required this.medicine,
    required this.onTap,
  });

  final UserMedicineEntity medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = medicine.status.color;

    return AppCard(
      onTap: onTap,
      effectColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Identity ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineTypeIcon(type: medicine.form, size: 40, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(
                      medicine.displayName,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (medicine.subtitle.isNotEmpty)
                      AppText.bodyXs(
                        medicine.subtitle,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── When ──────────────────────────────────────────────────────────
          MedicineDoseTimesWrap(medicine),
          const SizedBox(height: 10),

          // ── How much ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 13, color: context.secondaryText),
              const SizedBox(width: 5),
              AppText.bodyXs(
                medicine.hasStock
                    ? '${medicine.stockQuantity} units left'
                    : 'No stock recorded',
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              // Both can apply — a shared bottle that's also low. Wrap takes
              // the remaining width and drops the second badge to its own
              // line rather than clipping; the row height is content-sized.
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (medicine.status == MedStatus.lowStock)
                      MedicineStatusBadge(medicine.status),
                    MedicineScopeBadge(medicine),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
