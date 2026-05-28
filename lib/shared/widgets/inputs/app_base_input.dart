import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Fully-configurable base text field used by every text-based input widget.
///
/// Prefer the named subclasses ([AppTextInput], [AppEmailInput], etc.)
/// for common patterns. Use [AppBaseInput] when you need full control.
///
/// Layout:
///   [label]              ← optional label above the field
///   ┌─────────────────────────────────────┐
///   │ [prefixIcon/prefix] [text] [suffix] │
///   └─────────────────────────────────────┘
///   [error] or [helper]  ← below field
///
/// ```dart
/// AppBaseInput(
///   label: 'Full Name',
///   hint: 'Enter your name',
///   prefixIcon: Icons.person_rounded,
///   controller: _nameCtrl,
///   onChanged: (v) => _name = v,
/// )
/// ```
class AppBaseInput extends StatefulWidget {
  const AppBaseInput({
    super.key,
    this.controller,
    this.focusNode,
    // ── Labels ──────────────────────────────────────────────────────────────
    this.label,
    this.hint,
    this.error,
    this.helper,
    // ── Prefix / suffix ──────────────────────────────────────────────────────
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.onPrefixTap,
    this.onSuffixTap,
    // ── Keyboard & formatting ────────────────────────────────────────────────
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    // ── Callbacks ────────────────────────────────────────────────────────────
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    // ── Behaviour ────────────────────────────────────────────────────────────
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    // ── Styling ──────────────────────────────────────────────────────────────
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.labelStyle,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.filled,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  // Labels
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;

  // Prefix / suffix
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final VoidCallback? onPrefixTap;
  final VoidCallback? onSuffixTap;

  // Keyboard
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  // Callbacks
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;

  // Behaviour
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;

  // Styling
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool? filled;

  bool get _hasError => error != null && error!.isNotEmpty;

  @override
  State<AppBaseInput> createState() => _AppBaseInputState();
}

class _AppBaseInputState extends State<AppBaseInput> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Colour resolution ────────────────────────────────────────────────────
    final bg = widget.backgroundColor ?? context.inputBg;

    final defaultBorder = widget.borderColor ?? context.borderCol;
    final focusedBorder = widget.focusedBorderColor ?? AppColors.teal;
    final errorBorder   = widget.errorBorderColor ?? AppColors.error;

    final activeBorder = widget._hasError
        ? errorBorder
        : (_focused ? focusedBorder : defaultBorder);

    final br = widget.borderRadius ?? AppBorderRadius.mdAll;

    // ── Decoration ───────────────────────────────────────────────────────────
    final fieldDecoration = InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.hintStyle ??
          AppTypography.bodyMd.copyWith(color: AppColors.textHint),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      counterText: widget.showCounter ? null : '',
      // Prefix
      prefixIcon: _buildPrefixIcon(),
      prefix: widget.prefixText != null
          ? Padding(
              padding: const EdgeInsets.only(left: 2, right: 4),
              child: Text(
                widget.prefixText!,
                style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary),
              ),
            )
          : null,
      // Suffix
      suffixIcon: _buildSuffixIcon(),
      suffix: widget.suffixText != null
          ? Padding(
              padding: const EdgeInsets.only(left: 4, right: 2),
              child: Text(
                widget.suffixText!,
                style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary),
              ),
            )
          : null,
    );

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: widget.enabled ? bg : bg.withValues(alpha: 0.5),
        borderRadius: br,
        border: Border.all(color: activeBorder),
        boxShadow: _focused && !widget._hasError
            ? [
                BoxShadow(
                  color: focusedBorder.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: widget.prefix != null || widget.suffix != null
          ? Row(
              children: [
                if (widget.prefix != null) widget.prefix!,
                Expanded(
                  child: _buildTextField(fieldDecoration),
                ),
                if (widget.suffix != null) widget.suffix!,
              ],
            )
          : _buildTextField(fieldDecoration),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                AppTypography.labelSm.copyWith(letterSpacing: 0.2),
          ),
          const SizedBox(height: 6),
        ],

        // ── Field ───────────────────────────────────────────────────────────
        field,

        // ── Error / helper ──────────────────────────────────────────────────
        if (widget._hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(widget.error!,
                  style: AppTypography.bodyXs
                      .copyWith(color: AppColors.error)),
            ),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          Text(widget.helper!,
              style: AppTypography.bodyXs
                  .copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }

  Widget _buildTextField(InputDecoration decoration) {
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: widget.maxLines != 1
          ? TextInputType.multiline
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      style: widget.textStyle ??
          AppTypography.bodyMd.copyWith(color: context.primaryText),
      decoration: decoration,
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;
    final icon = Icon(widget.prefixIcon,
        size: 18, color: _focused ? AppColors.teal : AppColors.textSecondary);
    if (widget.onPrefixTap != null) {
      return GestureDetector(onTap: widget.onPrefixTap, child: icon);
    }
    return icon;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon == null) return null;
    final icon = Icon(widget.suffixIcon,
        size: 18, color: AppColors.textSecondary);
    if (widget.onSuffixTap != null) {
      return GestureDetector(onTap: widget.onSuffixTap, child: icon);
    }
    return icon;
  }
}
