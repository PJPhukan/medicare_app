import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Standard single-line text input with label, hint, error, and icon support.
class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.borderRadius,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasError   = error != null && error!.isNotEmpty;
    final borderCol  = hasError ? AppColors.error : context.borderCol;
    final focusColor = hasError ? AppColors.error : AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? context.inputBg : context.inputBg.withValues(alpha: 0.5),
            borderRadius: borderRadius ?? AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            readOnly: readOnly,
            autofocus: autofocus,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onTap: onTap,
            style: AppTypography.bodyMd.copyWith(
              color: enabled ? context.primaryText : AppColors.textHint,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: AppColors.textSecondary)
                  : null,
              suffixIcon: suffix,
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              focusColor: focusColor,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(error!,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.error)),
            ),
          ]),
        ] else if (helper != null) ...[
          const SizedBox(height: 5),
          Text(helper!, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }
}
