import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Single-select dropdown backed by a bottom sheet option list.
class AppDropdownInput<T> extends StatefulWidget {
  const AppDropdownInput({
    super.key,
    required this.options,
    required this.labels,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.enabled = true,
    this.leadingIcons,
  });

  final List<T> options;
  final List<String> labels;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final bool enabled;

  /// Optional icon per option, parallel to [options].
  final List<IconData?>? leadingIcons;

  @override
  State<AppDropdownInput<T>> createState() => _AppDropdownInputState<T>();
}

class _AppDropdownInputState<T> extends State<AppDropdownInput<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  String get _displayLabel {
    if (_selected == null) return widget.hint ?? 'Select…';
    final idx = widget.options.indexOf(_selected as T);
    return idx >= 0 ? widget.labels[idx] : (widget.hint ?? 'Select…');
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DropdownSheet<T>(
        options: widget.options,
        labels: widget.labels,
        selected: _selected,
        leadingIcons: widget.leadingIcons,
        onSelect: (v) {
          setState(() => _selected = v);
          widget.onChanged?.call(v);
        },
      ),
    );
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
          Text(widget.label!,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: widget.enabled ? _openSheet : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? context.inputBg : Colors.white,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayLabel,
                    style: AppTypography.bodyMd.copyWith(
                      color: _selected != null
                          ? context.primaryText
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: widget.enabled
                      ? AppColors.textSecondary
                      : AppColors.textHint,
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

class _DropdownSheet<T> extends StatelessWidget {
  const _DropdownSheet({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelect,
    this.leadingIcons,
  });

  final List<T> options;
  final List<String> labels;
  final T? selected;
  final ValueChanged<T> onSelect;
  final List<IconData?>? leadingIcons;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? context.cardBg : Colors.white;
    final border  = isDark ? context.borderCol : const Color(0xFFE2E8F0);
    final bottom  = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: border,
              borderRadius: AppBorderRadius.pill,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: border),
            itemBuilder: (_, i) {
              final isSelected = options[i] == selected;
              return ListTile(
                onTap: () {
                  onSelect(options[i]);
                  Navigator.pop(context);
                },
                leading: leadingIcons != null && leadingIcons![i] != null
                    ? Icon(leadingIcons![i],
                        size: 18,
                        color: isSelected
                            ? AppColors.teal
                            : AppColors.textSecondary)
                    : null,
                title: Text(labels[i],
                    style: AppTypography.bodyMd.copyWith(
                      color: isSelected ? AppColors.teal : context.primaryText,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 18, color: AppColors.teal)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
