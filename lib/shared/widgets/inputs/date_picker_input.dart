import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

/// Tappable date input that opens the system date picker.
class AppDatePickerInput extends StatefulWidget {
  const AppDatePickerInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.enabled = true,
    this.displayFormat,
  });

  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final bool enabled;

  /// Custom format function. Defaults to "DD MMM YYYY".
  final String Function(DateTime)? displayFormat;

  @override
  State<AppDatePickerInput> createState() => _AppDatePickerInputState();
}

class _AppDatePickerInputState extends State<AppDatePickerInput> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  void didUpdateWidget(AppDatePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      setState(() => _selected = widget.initialDate);
    }
  }

  String _format(DateTime d) {
    if (widget.displayFormat != null) return widget.displayFormat!(d);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
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
                    Icons.calendar_today_rounded,
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
                          : (widget.hint ?? 'Select date'),
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
