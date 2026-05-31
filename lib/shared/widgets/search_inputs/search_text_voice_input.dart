import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../voice_search/voice_search_modal.dart';

/// Pill-shaped search input with an integrated voice search modal.
/// Tapping the mic automatically opens [VoiceSearchModal] — no external
/// STT wiring needed. The modal result populates [controller] and calls
/// [onChanged] automatically.
class AppSearchTextVoiceInput extends StatefulWidget {
  const AppSearchTextVoiceInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
    this.backgroundColor,
    this.borderColor,
    this.micColor,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? micColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppSearchTextVoiceInput> createState() =>
      _AppSearchTextVoiceInputState();
}

class _AppSearchTextVoiceInputState extends State<AppSearchTextVoiceInput> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(_onTextChange);
  }

  void _onTextChange() {
    final has = _ctrl.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChange);
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  void _openVoiceModal() {
    VoiceSearchModal.show(
      context,
      onSearch: (query) {
        _ctrl.text = query;
        _ctrl.selection = TextSelection.fromPosition(
          TextPosition(offset: query.length),
        );
        widget.onChanged?.call(query);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final micColor = widget.micColor ?? AppColors.teal;
    final bg = widget.backgroundColor ?? context.inputBg;
    final borderCol = widget.borderColor ?? context.borderCol;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          // ── Search icon ────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),

          // ── Text field ─────────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: widget.textStyle ??
                  AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search…',
                hintStyle: widget.hintStyle ??
                    AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              ),
            ),
          ),

          // ── Clear button ───────────────────────────────────────────────────
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // ── Mic button ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: widget.enabled ? _openVoiceModal : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: micColor.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.mic_rounded, size: 18, color: micColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
