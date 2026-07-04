import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

/// Text input that converts entries into removable chips on submit / comma.
class AppChipTagInput extends StatefulWidget {
  const AppChipTagInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.initialTags = const [],
    this.onChanged,
    this.enabled = true,
    this.color,
    this.maxTags,
  });

  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final List<String> initialTags;
  final ValueChanged<List<String>>? onChanged;
  final bool enabled;
  final Color? color;
  final int? maxTags;

  @override
  State<AppChipTagInput> createState() => _AppChipTagInputState();
}

class _AppChipTagInputState extends State<AppChipTagInput> {
  late final TextEditingController _ctrl;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _tags = List.from(widget.initialTags);
  }

  @override
  void didUpdateWidget(AppChipTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTags != widget.initialTags) {
      setState(() => _tags = List.from(widget.initialTags));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _atMax => widget.maxTags != null && _tags.length >= widget.maxTags!;

  void _add(String raw) {
    // Strip only the trailing comma that triggered the add, not commas mid-text.
    final trimmed = raw.trim().endsWith(',')
        ? raw.trim().substring(0, raw.trim().length - 1).trim()
        : raw.trim();
    if (trimmed.isEmpty) return;
    if (_tags.contains(trimmed) || _atMax) {
      _ctrl.clear();
      return;
    }
    setState(() => _tags.add(trimmed));
    _ctrl.clear();
    widget.onChanged?.call(List.from(_tags));
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged?.call(List.from(_tags));
  }

  @override
  Widget build(BuildContext context) {
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;
    final chipColor = widget.color ?? AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                            color: chipColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.bodySm(tag,
                              color: chipColor,
                              fontWeight: FontWeight.w500),
                          const SizedBox(width: 2),
                          InkWell(
                            onTap: widget.enabled ? () => _remove(tag) : null,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.close_rounded,
                                  size: 14, color: chipColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              if (_tags.isNotEmpty) const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                enabled: widget.enabled && !_atMax,
                onSubmitted: _add,
                onChanged: (v) {
                  if (v.endsWith(',')) _add(v);
                },
                style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Type and press Enter…',
                  hintStyle:
                      AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
