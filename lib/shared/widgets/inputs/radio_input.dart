import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../texts/app_text.dart';

/// A group of radio buttons from a list of options.
class AppRadioInput<T> extends StatelessWidget {
  const AppRadioInput({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.label,
    this.descriptions,
    this.enabled = true,
    this.color,
    this.error,
    this.direction = Axis.vertical,
  });

  final List<T> options;
  final List<String> labels;
  final T? selected;
  final ValueChanged<T> onChanged;
  final String? label;
  final List<String>? descriptions;
  final bool enabled;
  final Color? color;
  final String? error;

  /// Lay options out vertically (default) or horizontally.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.teal;
    final hasError = error != null && error!.isNotEmpty;

    Widget buildItem(int i) {
      final opt = options[i];
      return GestureDetector(
        onTap: enabled ? () => onChanged(opt) : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize:
              direction == Axis.horizontal ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<T>(
                value: opt,
                activeColor: activeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMd(
                    labels[i],
                    color: enabled ? null : AppColors.textHint,
                  ),
                  if (descriptions != null && i < descriptions!.length)
                    AppText.bodyXs(
                      descriptions![i],
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
            if (direction == Axis.horizontal) const SizedBox(width: 16),
          ],
        ),
      );
    }

    final items = List.generate(options.length, buildItem);

    Widget radioContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          AppText.labelMd(label!),
          const SizedBox(height: 8),
        ],
        if (direction == Axis.vertical)
          ...items.map((w) =>
              Padding(padding: const EdgeInsets.only(bottom: 8), child: w))
        else
          Wrap(children: items),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: AppText.error(error!)),
          ]),
        ],
      ],
    );

    return RadioGroup<T>(
      groupValue: selected,
      onChanged: (v) { if (enabled && v != null) onChanged(v); },
      child: radioContent,
    );
  }
}
