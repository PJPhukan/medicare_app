import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../texts/app_text.dart';

/// Tappable date-of-birth field that opens Flutter's date picker.
class AppDobPicker extends StatelessWidget {
  const AppDobPicker({
    super.key,
    required this.date,
    required this.onChanged,
    this.label,
    this.hint = 'Select date of birth',
    this.error,
    this.helper,
    this.enabled = true,
  });

  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String hint;
  final String? error;
  final String? helper;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasError   = error != null && error!.isNotEmpty;
    final borderCol  = hasError ? AppColors.error : context.borderCol;
    final displayText = date != null
        ? DateFormat('dd MMM yyyy').format(date!)
        : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          AppText.labelMd(label!),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: AppBorderRadius.mdAll,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: enabled
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText.bodyMd(
                    displayText,
                    color: date != null
                        ? (enabled ? null : AppColors.textSecondary)
                        : AppColors.textHint,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: enabled
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: AppText.error(error!)),
          ]),
        ] else if (helper != null) ...[
          const SizedBox(height: 5),
          AppText.hint(helper!),
        ],
      ],
    );
  }
}
