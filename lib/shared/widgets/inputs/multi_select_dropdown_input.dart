import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Multi-select dropdown backed by a checkable bottom sheet list.
class AppMultiSelectDropdownInput<T> extends StatefulWidget {
  const AppMultiSelectDropdownInput({
    super.key,
    required this.options,
    required this.labels,
    this.selected = const [],
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.enabled = true,
    this.color,
  });

  final List<T> options;
  final List<String> labels;
  final List<T> selected;
  final ValueChanged<List<T>>? onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final bool enabled;
  final Color? color;

  @override
  State<AppMultiSelectDropdownInput<T>> createState() =>
      _AppMultiSelectDropdownInputState<T>();
}

class _AppMultiSelectDropdownInputState<T>
    extends State<AppMultiSelectDropdownInput<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  String get _displayLabel {
    if (_selected.isEmpty) return widget.hint ?? 'Select…';
    if (_selected.length == 1) {
      final idx = widget.options.indexOf(_selected.first);
      return idx >= 0 ? widget.labels[idx] : '1 selected';
    }
    return '${_selected.length} selected';
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiSelectSheet<T>(
        options: widget.options,
        labels: widget.labels,
        selected: List.from(_selected),
        color: widget.color ?? AppColors.teal,
        onApply: (list) {
          setState(() => _selected = list);
          widget.onChanged?.call(list);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

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
              color: context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayLabel,
                    style: AppTypography.bodyMd.copyWith(
                      color: _selected.isNotEmpty
                          ? context.primaryText
                          : AppColors.textHint,
                    ),
                  ),
                ),
                if (_selected.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (widget.color ?? AppColors.teal)
                          .withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.pill,
                    ),
                    child: Text('${_selected.length}',
                        style: AppTypography.bodyXs.copyWith(
                            color: widget.color ?? AppColors.teal,
                            fontWeight: FontWeight.w600)),
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

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onApply,
    required this.color,
  });

  final List<T> options;
  final List<String> labels;
  final List<T> selected;
  final ValueChanged<List<T>> onApply;
  final Color color;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late List<T> _temp;

  @override
  void initState() {
    super.initState();
    _temp = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final bg      = context.cardBg;
    final border  = context.borderCol;
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
            decoration: BoxDecoration(color: border,
                borderRadius: AppBorderRadius.pill),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Select Options',
                      style: AppTypography.h3.copyWith(fontSize: 17)),
                ),
                TextButton(
                  onPressed: () => setState(() => _temp.clear()),
                  child: Text('Clear',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.options.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: border),
              itemBuilder: (_, i) {
                final isSelected = _temp.contains(widget.options[i]);
                return ListTile(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _temp.remove(widget.options[i]);
                    } else {
                      _temp.add(widget.options[i]);
                    }
                  }),
                  title: Text(widget.labels[i],
                      style: AppTypography.bodyMd.copyWith(
                        color: isSelected
                            ? widget.color
                            : context.primaryText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      )),
                  trailing: isSelected
                      ? Icon(Icons.check_box_rounded,
                          color: widget.color, size: 20)
                      : Icon(Icons.check_box_outline_blank_rounded,
                          color: AppColors.textSecondary, size: 20),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.mdAll),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  widget.onApply(_temp);
                  Navigator.pop(context);
                },
                child: Text('Apply (${_temp.length})'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
