import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Email input with inline format validation indicator.
class AppEmailInput extends StatefulWidget {
  const AppEmailInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.showValidIcon = true,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  /// Shows a green checkmark inside the field when the email looks valid.
  final bool showValidIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<AppEmailInput> createState() => _AppEmailInputState();
}

class _AppEmailInputState extends State<AppEmailInput> {
  String _value = '';

  static final _emailRx = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$');
  bool get _isValid => _emailRx.hasMatch(_value);

  @override
  Widget build(BuildContext context) {
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
            onSubmitted: widget.onSubmitted,
            style: AppTypography.bodyMd.copyWith(color: context.primaryText),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'you@example.com',
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.mail_outline_rounded,
                  size: 18, color: AppColors.textSecondary),
              suffixIcon: widget.showValidIcon && _value.isNotEmpty
                  ? Icon(
                      _isValid
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 18,
                      color: _isValid ? AppColors.green : AppColors.error,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: Text(widget.error!,
                style: AppTypography.bodyXs.copyWith(color: AppColors.error))),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          Text(widget.helper!, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }
}
