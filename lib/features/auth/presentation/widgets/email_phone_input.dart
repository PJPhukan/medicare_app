import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/data/country_codes.dart';
import '../../../../../core/theme/app_colors.dart';
import 'phone_input_widget.dart';

// ─── Input type ───────────────────────────────────────────────────────────────

enum EmailPhoneType { unknown, email, phone }

EmailPhoneType _detect(String value) {
  if (value.isEmpty) return EmailPhoneType.unknown;
  if (RegExp(r'[A-Za-z]').hasMatch(value)) return EmailPhoneType.email;
  if (RegExp(r'^[+\d\s()\-]+$').hasMatch(value)) return EmailPhoneType.phone;
  return EmailPhoneType.unknown;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Smart single-field input that auto-detects email vs phone.
///
/// When the user types letters it behaves as a plain email field.
/// When digits / phone chars are detected the country-code picker slides in
/// with an [AnimatedSize] transition.
///
/// Callbacks:
/// - [onChanged]  — raw text value (no dial prefix added here; compose it
///                  with [onTypeChanged] + [onCountryChanged] if needed)
/// - [onTypeChanged]  — fired whenever the detected [EmailPhoneType] changes
/// - [onCountryChanged] — fired when the user picks a different country
///
/// ```dart
/// AppEmailPhoneInput(
///   controller: _idCtrl,
///   label: 'Email or mobile',
///   hint: 'you@email.com or 9876543210',
///   error: _idError,
///   onChanged: (v) => _id = v,
///   onTypeChanged: (t) => setState(() => _type = t),
///   onCountryChanged: (c) => _country = c,
/// )
/// ```
class AppEmailPhoneInput extends StatefulWidget {
  const AppEmailPhoneInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.error,
    this.initialCountry,
    this.onChanged,
    this.onTypeChanged,
    this.onCountryChanged,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? error;

  /// Country shown in the picker on initial render. Defaults to India (+91).
  final CountryCode? initialCountry;

  /// Raw typed value (no dial code injected).
  final ValueChanged<String>? onChanged;

  /// Fires each time the detected type changes (email / phone / unknown).
  final ValueChanged<EmailPhoneType>? onTypeChanged;

  /// Fires when the user selects a different country from the bottom sheet.
  final ValueChanged<CountryCode>? onCountryChanged;

  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;

  @override
  State<AppEmailPhoneInput> createState() => _AppEmailPhoneInputState();
}

class _AppEmailPhoneInputState extends State<AppEmailPhoneInput> {
  late CountryCode _country;
  EmailPhoneType _type = EmailPhoneType.unknown;

  @override
  void initState() {
    super.initState();
    _country = widget.initialCountry ?? kDefaultCountry;
    _type    = _detect(widget.controller.text);
  }

  void _onChanged(String value) {
    final next = _detect(value);
    if (next != _type) {
      setState(() => _type = next);
      widget.onTypeChanged?.call(next);
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final hasError     = widget.error != null && widget.error!.isNotEmpty;
    final textColor    = isDark ? AppColors.textPrimary  : const Color(0xFF1A202C);
    final hintColor    = isDark ? AppColors.textHint     : const Color(0xFF94A3B8);
    final labelColor   = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final bgInput      = isDark ? AppColors.dark700      : Colors.white;
    final borderNormal = isDark ? AppColors.dark600      : const Color(0xFFE2E8F0);
    final borderColor  = hasError ? AppColors.error : borderNormal;
    final isPhone      = _type == EmailPhoneType.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
        ],

        // ── Field row ──────────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country picker — slides in when phone is detected
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: isPhone
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CountryCodePicker(
                        selected: _country,
                        onSelected: (c) {
                          setState(() => _country = c);
                          widget.onCountryChanged?.call(c);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Text field
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.text,
                  textInputAction: widget.textInputAction,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  onChanged: _onChanged,
                  style: GoogleFonts.inter(fontSize: 15, color: textColor),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Email or mobile number',
                    hintStyle:
                        GoogleFonts.inter(fontSize: 15, color: hintColor),
                    filled: true,
                    fillColor: bgInput,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: hasError ? AppColors.error : AppColors.teal,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: borderNormal.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Error ──────────────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 12, color: AppColors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.error!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
