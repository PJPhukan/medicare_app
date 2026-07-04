import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../texts/app_text.dart';

/// Compact +/- counter with a large value display in the centre.
class AppCounterInput extends StatefulWidget {
  const AppCounterInput({
    super.key,
    this.label,
    this.initialValue = 0,
    this.min,
    this.max,
    this.step = 1,
    this.onChanged,
    this.enabled = true,
    this.color,
  });

  final String? label;
  final int initialValue;
  final int? min;
  final int? max;
  final int step;
  final ValueChanged<int>? onChanged;
  final bool enabled;
  final Color? color;

  @override
  State<AppCounterInput> createState() => _AppCounterInputState();
}

class _AppCounterInputState extends State<AppCounterInput> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _change(int delta) {
    final next = _value + delta;
    if (widget.min != null && next < widget.min!) return;
    if (widget.max != null && next > widget.max!) return;
    setState(() => _value = next);
    widget.onChanged?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.teal;
    final canDec = widget.min == null || _value > widget.min!;
    final canInc = widget.max == null || _value < widget.max!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn(
              icon: Icons.remove_rounded,
              color: color,
              enabled: widget.enabled && canDec,
              onTap: () => _change(-widget.step),
            ),
            const SizedBox(width: 4),
            Container(
              constraints: const BoxConstraints(minWidth: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: color.withValues(alpha: 0.3)),
                borderRadius: AppBorderRadius.smAll,
              ),
              child: AppText.h3(
                '$_value',
                color: color,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            _Btn(
              icon: Icons.add_rounded,
              color: color,
              enabled: widget.enabled && canInc,
              onTap: () => _change(widget.step),
            ),
          ],
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = enabled ? color : color.withValues(alpha: 0.1);
    final iconColor = enabled ? Colors.white : color.withValues(alpha: 0.4);
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: bgColor,
        borderRadius: AppBorderRadius.smAll,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppBorderRadius.smAll,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
