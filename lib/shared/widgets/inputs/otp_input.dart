import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Row of N single-digit boxes for OTP / verification code entry.
class AppOtpInput extends StatefulWidget {
  const AppOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.obscure = false,
    this.color,
    this.error,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscure;
  final Color? color;
  final String? error;

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  late List<TextEditingController> _ctrls;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  String get _value => _ctrls.map((c) => c.text).join();

  void _onKey(int i, String v) {
    if (v.length > 1) {
      // Handle paste
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (var j = 0; j < widget.length && j < digits.length; j++) {
        _ctrls[j].text = digits[j];
      }
      final next = digits.length < widget.length ? digits.length : widget.length - 1;
      _nodes[next].requestFocus();
    } else if (v.isNotEmpty) {
      _ctrls[i].text = v;
      if (i < widget.length - 1) _nodes[i + 1].requestFocus();
    } else {
      _ctrls[i].clear();
      if (i > 0) _nodes[i - 1].requestFocus();
    }
    setState(() {});
    widget.onChanged?.call(_value);
    if (_value.length == widget.length) widget.onCompleted?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final activeCol = widget.color ?? AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            final isFilled = _ctrls[i].text.isNotEmpty;
            final borderCol = hasError
                ? AppColors.error
                : (isFilled
                    ? activeCol
                    : (isDark ? context.borderCol : const Color(0xFFE2E8F0)));

            return SizedBox(
              width: (MediaQuery.sizeOf(context).width -
                      32 -
                      (widget.length - 1) * 8) /
                  widget.length,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? context.inputBg : Colors.white,
                  borderRadius: AppBorderRadius.smAll,
                  border: Border.all(color: borderCol, width: isFilled ? 1.5 : 1),
                ),
                child: TextField(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  enabled: widget.enabled,
                  obscureText: widget.obscure,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTypography.h3.copyWith(color: context.primaryText),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => _onKey(i, v),
                ),
              ),
            );
          }),
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
        ],
      ],
    );
  }
}
