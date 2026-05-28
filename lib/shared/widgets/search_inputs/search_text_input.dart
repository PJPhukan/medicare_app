import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Pill-shaped search text input with a clear button.
class AppSearchTextInput extends StatefulWidget {
  const AppSearchTextInput({
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
    this.textStyle,
    this.hintStyle,
    this.prefixIcon,
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
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final IconData? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppSearchTextInput> createState() => _AppSearchTextInputState();
}

class _AppSearchTextInputState extends State<AppSearchTextInput> {
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

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? context.inputBg;
    final border = widget.borderColor ?? context.borderCol;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: border),
      ),
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
          prefixIcon: Icon(
            widget.prefixIcon ?? Icons.search_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clear,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}
