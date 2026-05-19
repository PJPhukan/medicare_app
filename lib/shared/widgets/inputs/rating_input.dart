import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Star rating input. Supports half-star and full-star modes.
class AppRatingInput extends StatefulWidget {
  const AppRatingInput({
    super.key,
    this.label,
    this.initialValue = 0,
    this.maxStars = 5,
    this.onChanged,
    this.enabled = true,
    this.allowHalf = false,
    this.starSize = 32,
    this.color,
  });

  final String? label;
  final double initialValue;
  final int maxStars;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final bool allowHalf;
  final double starSize;
  final Color? color;

  @override
  State<AppRatingInput> createState() => _AppRatingInputState();
}

class _AppRatingInputState extends State<AppRatingInput> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _onTap(int starIndex, double localX, double starWidth) {
    if (!widget.enabled) return;
    double newVal;
    if (widget.allowHalf && localX < starWidth / 2) {
      newVal = starIndex + 0.5;
    } else {
      newVal = (starIndex + 1).toDouble();
    }
    setState(() => _value = newVal);
    widget.onChanged?.call(_value);
  }

  IconData _iconFor(int i) {
    if (_value >= i + 1) return Icons.star_rounded;
    if (widget.allowHalf && _value >= i + 0.5) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.amber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxStars, (i) {
            return GestureDetector(
              onTapDown: (d) =>
                  _onTap(i, d.localPosition.dx, widget.starSize),
              child: Icon(
                _iconFor(i),
                size: widget.starSize,
                color: _value > i
                    ? color
                    : color.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
