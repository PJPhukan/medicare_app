import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import 'medicine_status.dart';

class MedicineGridCard extends StatelessWidget {
  const MedicineGridCard({
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // The tile is sized to its content instead of stretching to a fixed
        // aspect ratio — a Spacer between the chips and the footer left a
        // visible void on every card that didn't have the maximum number of
        // dose times.
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Identity ──────────────────────────────────────────────────────
          // Icon beside the name, not above it: at this width a row holding
          // one 40px icon and nothing else was the biggest single waste of
          // vertical space on the card.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineTypeIcon(type: medicine.form, size: 36, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(
                      medicine.displayName,
                      fontWeight: FontWeight.w700,
                      maxLines: 2,
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StockCount(medicine: medicine, color: color),
              const SizedBox(width: 6),
              // Both badges can apply at once — a shared bottle that is also
              // running low. The Wrap takes the remaining width and drops the
              // second badge onto its own line when they don't fit side by
              // side; the card is content-sized, so growing a row is free.
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    // PRN is deliberately not badged here — the chip row above
                    // already says "Take as needed".
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

class _StockCount extends StatelessWidget {
  const _StockCount({required this.medicine, required this.color});

  final UserMedicineEntity medicine;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Built from AppText rather than RichText/TextSpan: AppText remaps the
    // dark-theme semantic colours (textSecondary, textHint) to their light
    // variants, and a raw TextSpan skips that entirely — which left this text
    // near-invisible in light mode.
    final known = medicine.hasStock;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.h3(
          known ? '${medicine.stockQuantity}' : '—',
          color: known ? color : AppColors.textHint,
          fontWeight: FontWeight.w800,
        ),
        const SizedBox(width: 5),
        AppText.bodyXs('Units', color: AppColors.textSecondary),
      ],
    );
  }
}
