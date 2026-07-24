import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

// ─── Base text field ──────────────────────────────────────────────────────────

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.fillColor,
    this.borderRadius,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  /// When true and [maxLength] is set, shows the character counter.
  final bool showCounter;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // setState is technically redundant here because Flutter always rebuilds
    // after didUpdateWidget, but it makes the intent explicit for reviewers.
    if (oldWidget.obscureText != widget.obscureText) {
      setState(() => _obscure = widget.obscureText);
    }
  }

  BorderRadius get _radius => widget.borderRadius ?? AppBorderRadius.lgAll;

  // #5 — single helper instead of six identical OutlineInputBorder literals
  OutlineInputBorder _border(BuildContext context, {Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: _radius,
        borderSide: BorderSide(color: color ?? context.borderCol, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // #4 — use AppText instead of raw Text
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: _obscure ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          style: AppTypography.bodyMd.copyWith(color: context.primaryText),
          cursorColor: AppColors.teal,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.fillColor ?? context.inputBg,
            prefixIcon: widget.prefix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: IconTheme(
                      data: const IconThemeData(size: 18, color: AppColors.textHint),
                      child: widget.prefix!,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            // #3 — IconButton for proper ripple + accessibility; #7 — tooltip on eye icon
            suffixIcon: widget.obscureText
                ? IconButton(
                    // Tooltip describes what the button *will do*, not current state.
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                  )
                : widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: IconTheme(
                          data: const IconThemeData(size: 18, color: AppColors.textHint),
                          child: widget.suffix!,
                        ),
                      )
                    : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            // #5 — _border() helper
            border:            _border(context),
            enabledBorder:     _border(context),
            focusedBorder:     _border(context, color: AppColors.teal, width: 1.5),
            errorBorder:       _border(context, color: AppColors.error),
            focusedErrorBorder: _border(context, color: AppColors.error, width: 1.5),
            disabledBorder:    _border(context, color: context.borderCol.withValues(alpha: 0.5)),
            // #8 — configurable counter
            counterText: widget.showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}

// ─── Text area ────────────────────────────────────────────────────────────────

class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final bool showCounter;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }
}
