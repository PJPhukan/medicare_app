import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final trimmed = raw.trim().replaceAll(',', '');
    if (trimmed.isEmpty) return;
    if (_tags.contains(trimmed)) {
      _ctrl.clear();
      return;
    }
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) return;
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
          Text(widget.label!,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
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
                          Text(tag,
                              style: AppTypography.bodySm.copyWith(
                                  color: chipColor,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.enabled ? () => _remove(tag) : null,
                            child: Icon(Icons.close_rounded,
                                size: 14, color: chipColor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              if (_tags.isNotEmpty) const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                enabled: widget.enabled,
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
