import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

/// Numeric input with optional min / max clamping, unit suffix, and
/// increment / decrement arrow buttons.
class AppNumberInput extends StatefulWidget {
  const AppNumberInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.unit,
    this.error,
    this.helper,
    this.onChanged,
    this.min,
    this.max,
    this.decimalPlaces = 0,
    this.showSteppers = false,
    this.step = 1,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;

  /// Unit label shown as a suffix (e.g. 'kg', 'mg', 'mmHg').
  final String? unit;
  final String? error;
  final String? helper;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final int decimalPlaces;

  /// Shows +/- stepper buttons inside the field.
  final bool showSteppers;
  final num step;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<AppNumberInput> createState() => _AppNumberInputState();
}

class _AppNumberInputState extends State<AppNumberInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
  }

  num get _current => num.tryParse(_ctrl.text) ?? (widget.min ?? 0);

  void _step(num delta) {
    final next = (_current + delta)
        .clamp(widget.min ?? -double.infinity, widget.max ?? double.infinity);
    final formatted = widget.decimalPlaces == 0
        ? next.toInt().toString()
        : next.toStringAsFixed(widget.decimalPlaces);
    _ctrl.text = formatted;
    _ctrl.selection = TextSelection.collapsed(offset: formatted.length);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

    final formatter = widget.decimalPlaces > 0
        ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        : FilteringTextInputFormatter.digitsOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              if (widget.showSteppers)
                _StepBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => _step(-widget.step),
                  enabled: widget.enabled,
                  border: borderCol,
                  isLeft: true,
                ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: widget.decimalPlaces > 0),
                  textInputAction: widget.textInputAction,
                  inputFormatters: [formatter],
                  textAlign: widget.showSteppers ? TextAlign.center : TextAlign.start,
                  onChanged: (v) {
                    final n = num.tryParse(v);
                    if (n != null) widget.onChanged?.call(n);
                  },
                  style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? '0',
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                    suffix: widget.unit != null
                        ? AppText.bodySm(widget.unit!,
                            color: AppColors.textSecondary)
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  ),
                ),
              ),
              if (widget.showSteppers)
                _StepBtn(
                  icon: Icons.add_rounded,
                  onTap: () => _step(widget.step),
                  enabled: widget.enabled,
                  border: borderCol,
                  isLeft: false,
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
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

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.border,
    required this.isLeft,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color border;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: double.infinity,
        decoration: BoxDecoration(
          border: isLeft
              ? Border(right: BorderSide(color: border))
              : Border(left: BorderSide(color: border)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.teal : AppColors.textHint,
        ),
      ),
    );
  }
}
