import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Tappable time input that opens the system time picker.
class AppTimePickerInput extends StatefulWidget {
  const AppTimePickerInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.initialTime,
    this.onChanged,
    this.enabled = true,
    this.use24HourFormat = false,
  });

  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onChanged;
  final bool enabled;
  final bool use24HourFormat;

  @override
  State<AppTimePickerInput> createState() => _AppTimePickerInputState();
}

class _AppTimePickerInputState extends State<AppTimePickerInput> {
  TimeOfDay? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTime;
  }

  String _format(TimeOfDay t) {
    if (widget.use24HourFormat) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min  = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _pick() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selected ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError
        ? AppColors.error
        : (isDark ? context.borderCol : const Color(0xFFE2E8F0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: widget.enabled ? _pick : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? context.inputBg : Colors.white,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selected != null
                        ? _format(_selected!)
                        : (widget.hint ?? 'Select time'),
                    style: AppTypography.bodyMd.copyWith(
                      color: _selected != null
                          ? context.primaryText
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: Text(widget.error!,
                style: AppTypography.bodyXs.copyWith(color: AppColors.error))),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          Text(widget.helper!,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }
}
