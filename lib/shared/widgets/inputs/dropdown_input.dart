import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

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
  })  : assert(
          options.length == labels.length,
          'options and labels must have the same length',
        );

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

  @override
  void didUpdateWidget(AppDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _selected = widget.value);
    }
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
      builder: (context) => _DropdownSheet<T>(
        title: widget.label ?? 'Select',
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
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!, color: context.primaryText),
          const SizedBox(height: 6),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? _openSheet : null,
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
                  Expanded(
                    child: AppText.bodyMd(
                      _displayLabel,
                      color: _selected != null
                          ? context.primaryText
                          : AppColors.textHint,
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

class _DropdownSheet<T> extends StatelessWidget {
  const _DropdownSheet({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelect,
    this.title,
    this.leadingIcons,
  });

  final List<T> options;
  final List<String> labels;
  final T? selected;
  final ValueChanged<T> onSelect;
  final String? title;
  final List<IconData?>? leadingIcons;

  @override
  Widget build(BuildContext context) {
    final bg     = context.cardBg;
    final border = context.borderCol;
    final bottom = MediaQuery.paddingOf(context).bottom;

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
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: border,
              borderRadius: AppBorderRadius.pill,
            ),
          ),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText.h3(title!),
              ),
            ),
          ],
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
                  context.pop();
                },
                leading: leadingIcons != null && leadingIcons![i] != null
                    ? Icon(leadingIcons![i],
                        size: 18,
                        color: isSelected
                            ? AppColors.teal
                            : AppColors.textSecondary)
                    : null,
                title: AppText.bodyMd(
                  labels[i],
                  color: isSelected ? AppColors.teal : context.primaryText,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
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
