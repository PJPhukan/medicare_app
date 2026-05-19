import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// URL input with inline format validation indicator.
class AppUrlInput extends StatefulWidget {
  const AppUrlInput({
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
  final bool showValidIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<AppUrlInput> createState() => _AppUrlInputState();
}

class _AppUrlInputState extends State<AppUrlInput> {
  String _value = '';

  static final _urlRx = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    caseSensitive: false,
  );
  bool get _isValid => _value.isNotEmpty && _urlRx.hasMatch(_value);

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError
        ? AppColors.error
        : (isDark ? context.borderCol : const Color(0xFFE2E8F0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? context.inputBg : Colors.white,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.url,
            textInputAction: widget.textInputAction ?? TextInputAction.go,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
            onSubmitted: widget.onSubmitted,
            style: AppTypography.bodyMd.copyWith(color: context.primaryText),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'https://example.com',
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.link_rounded,
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
          Text(widget.helper!,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }
}
