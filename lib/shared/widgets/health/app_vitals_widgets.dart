import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../utils/animated_tap.dart';

// ─── Vital input row ──────────────────────────────────────────────────────────

class VitalInputRow extends StatelessWidget {
  const VitalInputRow({
    super.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.controller,
    this.color,
    this.secondaryController,
    this.secondaryLabel,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final String unit;
  final IconData icon;
  final TextEditingController controller;
  final Color? color;
  final TextEditingController? secondaryController;
  final String? secondaryLabel;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.blue;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.lgAll,
              ),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelSm),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
                          style: AppTypography.h3.copyWith(color: c),
                          validator: validator,
                          cursorColor: c,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: context.inputBg,
                            border: OutlineInputBorder(
                              borderRadius: AppBorderRadius.mdAll,
                              borderSide: BorderSide(color: context.borderCol),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppBorderRadius.mdAll,
                              borderSide: BorderSide(color: context.borderCol),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppBorderRadius.mdAll,
                              borderSide: BorderSide(color: c, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      if (secondaryController != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/', style: AppTypography.h3.copyWith(color: AppColors.textHint)),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: secondaryController,
                            keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
                            style: AppTypography.h3.copyWith(color: c),
                            cursorColor: c,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: secondaryLabel,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              filled: true,
                              fillColor: context.inputBg,
                              border: OutlineInputBorder(
                                borderRadius: AppBorderRadius.mdAll,
                                borderSide: BorderSide(color: context.borderCol),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.mdAll,
                                borderSide: BorderSide(color: context.borderCol),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppBorderRadius.mdAll,
                                borderSide: BorderSide(color: c, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(unit, style: AppTypography.labelSm.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vital history row ────────────────────────────────────────────────────────

class VitalHistoryRow extends StatelessWidget {
  const VitalHistoryRow({
    super.key,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.color,
    this.status,
    this.onTap,
  });

  final String value;
  final String unit;
  final String timestamp;
  final Color? color;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.blue;
    return AnimatedTap(
      onTap: onTap,
      borderRadius: AppBorderRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(timestamp, style: AppTypography.bodySm),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTypography.labelMd.copyWith(color: c),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Text(status!, style: AppTypography.labelXs.copyWith(color: AppColors.textHint)),
            ],
          ],
        ),
      ),
    );
  }
}
