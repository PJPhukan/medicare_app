import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Password input with show / hide toggle.
class AppPasswordInput extends StatefulWidget {
  const AppPasswordInput({
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
    this.focusNode,
    this.textInputAction,
    this.showStrengthIndicator = false,
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
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  /// When true, shows a password strength bar below the field.
  final bool showStrengthIndicator;

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _obscure = true;
  String _value = '';

  int get _strength {
    if (_value.length < 6) return 0;
    int s = 0;
    if (_value.length >= 8) s++;
    if (_value.contains(RegExp(r'[A-Z]'))) s++;
    if (_value.contains(RegExp(r'[0-9]'))) s++;
    if (_value.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  Color get _strengthColor => switch (_strength) {
        0 || 1 => AppColors.error,
        2      => AppColors.amber,
        3      => AppColors.blue,
        _      => AppColors.green,
      };

  String get _strengthLabel => switch (_strength) {
        0 || 1 => 'Weak',
        2      => 'Fair',
        3      => 'Good',
        _      => 'Strong',
      };

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
            obscureText: _obscure,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
            onSubmitted: widget.onSubmitted,
            style: AppTypography.bodyMd.copyWith(color: context.primaryText),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Enter password',
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
        if (widget.showStrengthIndicator && _value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppBorderRadius.pill,
                child: LinearProgressIndicator(
                  value: (_strength + 1) / 5,
                  minHeight: 4,
                  backgroundColor: _strengthColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(_strengthColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(_strengthLabel,
                style: AppTypography.bodyXs.copyWith(
                  color: _strengthColor, fontWeight: FontWeight.w600,
                )),
          ]),
        ],
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(widget.error!,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.error)),
            ),
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
