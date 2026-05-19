import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Single checkbox with label and optional description text.
class AppCheckboxInput extends StatelessWidget {
  const AppCheckboxInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.enabled = true,
    this.color,
    this.error,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final String? description;
  final bool enabled;
  final Color? color;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.teal;
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: enabled ? () => onChanged(!value) : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  activeColor: activeColor,
                  side: BorderSide(
                    color: hasError
                        ? AppColors.error
                        : (value ? activeColor : AppColors.textSecondary),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.xsAll),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label!,
                          style: AppTypography.bodyMd.copyWith(
                            color: enabled
                                ? null
                                : AppColors.textHint,
                          )),
                      if (description != null)
                        Text(description!,
                            style: AppTypography.bodyXs
                                .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(error!,
                  style: AppTypography.bodyXs
                      .copyWith(color: AppColors.error)),
            ),
          ]),
        ],
      ],
    );
  }
}

/// A group of checkboxes from a list of options.
class AppCheckboxGroupInput<T> extends StatelessWidget {
  const AppCheckboxGroupInput({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.color,
    this.error,
  });

  final List<T> options;
  final List<String> labels;
  final List<T> selected;
  final ValueChanged<List<T>> onChanged;
  final String? label;
  final bool enabled;
  final Color? color;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 8),
        ],
        ...List.generate(options.length, (i) {
          final opt = options[i];
          final isSelected = selected.contains(opt);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCheckboxInput(
              value: isSelected,
              label: labels[i],
              enabled: enabled,
              color: color,
              onChanged: (v) {
                final next = List<T>.from(selected);
                if (v) {
                  next.add(opt);
                } else {
                  next.remove(opt);
                }
                onChanged(next);
              },
            ),
          );
        }),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(error!,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.error)),
            ),
          ]),
        ],
      ],
    );
  }
}
