import 'dart:collection';
import 'package:app_medicare/core/constants/app_strings.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';
import '../search_inputs/search_text_input.dart';
import '../buttons/app_button.dart';

/// Multi-select dropdown backed by a searchable bottom-sheet checklist.
///
/// Set [searchable] to add a search bar in the sheet.
/// Set [customItemFactory] to allow the user to add items not in [options];
/// for a `String` list pass `customItemFactory: (s) => s`.
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
    this.searchable = false,
    this.searchHint = 'Search…',
    this.customItemFactory,
  }) : assert(
          options.length == labels.length,
          'options and labels must have the same length',
        );

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

  /// When true, shows a search bar at the top of the bottom sheet.
  final bool searchable;
  final String searchHint;

  /// When provided, shows an "Add [query]" row when search has no match.
  /// Converts the typed string into a T. For String lists: `(s) => s`.
  final T Function(String)? customItemFactory;

  @override
  State<AppMultiSelectDropdownInput<T>> createState() =>
      _AppMultiSelectDropdownInputState<T>();
}

class _AppMultiSelectDropdownInputState<T>
    extends State<AppMultiSelectDropdownInput<T>> {
  // LinkedHashSet preserves insertion order while preventing duplicates.
  late LinkedHashSet<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = LinkedHashSet.of(widget.selected);
  }

  @override
  void didUpdateWidget(AppMultiSelectDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reference equality misses parent mutations — listEquals detects value changes.
    if (!listEquals(oldWidget.selected, widget.selected)) {
      setState(() => _selected = LinkedHashSet.of(widget.selected));
    }
  }

  String _labelFor(T option) {
    final idx = widget.options.indexOf(option);
    return idx >= 0 ? widget.labels[idx] : option.toString();
  }

  String get _displayLabel {
    if (_selected.isEmpty) return widget.hint ?? 'Select…';
    // Show item names for ≤2 selections; fall back to count beyond that.
    if (_selected.length <= 2) return _selected.map(_labelFor).join(', ');
    return '${_selected.length} selected';
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MultiSelectSheet<T>(
        options: widget.options,
        labels: widget.labels,
        selected: _selected.toList(),
        color: widget.color ?? AppColors.teal,
        searchable: widget.searchable,
        searchHint: widget.searchHint,
        customItemFactory: widget.customItemFactory,
        onApply: (list) {
          setState(() => _selected = LinkedHashSet.of(list));
          widget.onChanged?.call(list);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError    = widget.error != null && widget.error!.isNotEmpty;
    final borderCol   = hasError ? AppColors.error : context.borderCol;
    final accentColor = widget.color ?? AppColors.teal;

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
                      color: _selected.isEmpty ? AppColors.textHint : null,
                    ),
                  ),
                  if (_selected.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.pill,
                      ),
                      child: AppText.bodyXs(
                        '${_selected.length}',
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

// ─── Bottom sheet ─────────────────────────────────────────────────────────────

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onApply,
    required this.color,
    required this.searchable,
    required this.searchHint,
    this.customItemFactory,
  });

  final List<T> options;
  final List<String> labels;
  final List<T> selected;
  final ValueChanged<List<T>> onApply;
  final Color color;
  final bool searchable;
  final String searchHint;
  final T Function(String)? customItemFactory;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  // Set prevents duplicates; LinkedHashSet preserves insertion order.
  late LinkedHashSet<T> _temp;
  late List<T> _customOptions;

  // O(1) label lookup — built once in initState, updated on custom-add.
  late Map<T, String> _labelMap;

  String _query = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _temp = LinkedHashSet.of(widget.selected);
    _searchCtrl = TextEditingController();
    _labelMap = {
      for (var i = 0; i < widget.options.length; i++)
        widget.options[i]: widget.labels[i],
    };
    _customOptions =
        _temp.where((t) => !widget.options.contains(t)).toList();
    // Seed the label map with any pre-existing custom items.
    for (final t in _customOptions) {
      _labelMap.putIfAbsent(t, () => t.toString());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // O(1) — map lookup vs O(n) indexOf previously.
  String _labelFor(T option) => _labelMap[option] ?? option.toString();

  List<T> get _allOptions => [...widget.options, ..._customOptions];

  /// Selected items float to the top.
  List<T> get _sorted {
    final all = _allOptions;
    return [
      ...all.where(_temp.contains),
      ...all.where((o) => !_temp.contains(o)),
    ];
  }

  List<T> get _filtered {
    if (_query.isEmpty) return _sorted;
    final q = _query.toLowerCase();
    return _sorted
        .where((o) => _labelFor(o).toLowerCase().contains(q))
        .toList();
  }

  bool get _showAddCustom {
    if (widget.customItemFactory == null || _query.trim().isEmpty) return false;
    final q = _query.trim().toLowerCase();
    return !_allOptions.any((o) => _labelFor(o).toLowerCase() == q);
  }

  void _toggle(T value) {
    setState(() {
      if (_temp.contains(value)) {
        _temp.remove(value);
      } else {
        _temp.add(value);
      }
    });
  }

  void _addCustom() {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    final newItem = widget.customItemFactory!(trimmed);
    setState(() {
      if (!_allOptions.contains(newItem)) {
        _customOptions.add(newItem);
        _labelMap[newItem] = trimmed;
      }
      _temp.add(newItem);
      _query = '';
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg             = context.cardBg;
    final border         = context.borderCol;
    final bottomPad      = MediaQuery.paddingOf(context).bottom;
    final keyboardInset  = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight   = MediaQuery.sizeOf(context).height;
    final statusBar      = MediaQuery.paddingOf(context).top;
    final spaceAboveKeyboard = screenHeight - keyboardInset - statusBar;
    final maxSheetHeight = spaceAboveKeyboard * 0.65;
    final filtered       = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: bottomPad + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: border,
                borderRadius: AppBorderRadius.pill,
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(child: AppText.h3(AppStrings.selectOptions)),
                  if (_temp.isNotEmpty)
                    AppButton(
                      label: AppStrings.clearAll,
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () => setState(() => _temp.clear()),
                    ),
                ],
              ),
            ),

            // Search bar
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: AppSearchTextInput(
                  controller: _searchCtrl,
                  hint: widget.searchHint,
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
              ),

            // List
            Flexible(
              child: filtered.isEmpty && !_showAddCustom
                  ? Center(
                      child: AppText.bodySm(
                        AppStrings.noresults,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      // +1 for the "Add custom" row when visible
                      itemCount: filtered.length + (_showAddCustom ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: border),
                      itemBuilder: (_, i) {
                        // First row is "Add [query]" when visible
                        if (_showAddCustom && i == 0) {
                          return ListTile(
                            onTap: _addCustom,
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.12),
                                borderRadius: AppBorderRadius.smAll,
                              ),
                              child: Icon(Icons.add_rounded,
                                  size: 16, color: widget.color),
                            ),
                            title: Text.rich(
                              TextSpan(
                                text: '${AppStrings.add}  ',
                                style: AppTypography.bodyMd,
                                children: [
                                  TextSpan(
                                    text: '"${_query.trim()}"',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final item       = filtered[_showAddCustom ? i - 1 : i];
                        final isSelected = _temp.contains(item);
                        return ListTile(
                          onTap: () => _toggle(item),
                          title: AppText.bodyMd(
                            _labelFor(item),
                            color: isSelected ? widget.color : null,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_box_rounded,
                                  color: widget.color, size: 20)
                              : Icon(Icons.check_box_outline_blank_rounded,
                                  color: AppColors.textSecondary, size: 20),
                        );
                      },
                    ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AppButton(
                label: _temp.isEmpty
                    ? AppStrings.done
                    : '${AppStrings.apply} (${_temp.length})',
                isFullWidth: true,
                size: AppButtonSize.lg,
                color: widget.color,
                onPressed: () {
                  widget.onApply(_temp.toList());
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
