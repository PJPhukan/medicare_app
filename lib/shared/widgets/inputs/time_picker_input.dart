import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

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

  @override
  void didUpdateWidget(AppTimePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      setState(() => _selected = widget.initialTime);
    }
  }

  String _format(TimeOfDay t) {
    if (widget.use24HourFormat) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    final hour   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min    = t.minute.toString().padLeft(2, '0');
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
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 6),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? _pick : null,
            borderRadius: AppBorderRadius.mdAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: widget.enabled
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText.bodyMd(
                      _selected != null
                          ? _format(_selected!)
                          : (widget.hint ?? 'Select time'),
                      color: _selected != null
                          ? (widget.enabled ? null : AppColors.textSecondary)
                          : AppColors.textHint,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: AppText.error(widget.error!)),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          AppText.hint(widget.helper!),
        ],
      ],
    );
  }
}
