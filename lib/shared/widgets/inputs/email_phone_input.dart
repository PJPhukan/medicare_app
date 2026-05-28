import 'package:flutter/material.dart';
import '../../../core/data/country_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../skeleton/skeleton_base.dart';

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
    this.skeleton = false,
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
  final bool skeleton;

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
    if (widget.skeleton) {
      return AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              SkeletonBox(width: 100, height: 11, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 6),
            ],
            SkeletonBox(width: double.infinity, height: 52, borderRadius: BorderRadius.circular(14)),
          ],
        ),
      );
    }

    final hasError    = widget.error != null && widget.error!.isNotEmpty;
    final borderColor = hasError ? AppColors.error : context.borderCol;
    final isPhone     = _type == EmailPhoneType.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSm),
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
                      child: _CountryPickerButton(
                        selected: _country,
                        enabled: widget.enabled,
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
                  style: AppTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Email or mobile number',
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                    filled: true,
                    fillColor: context.inputBg,
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
                          color: context.borderCol.withValues(alpha: 0.5)),
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
                  style: AppTypography.labelSm.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Country picker button ────────────────────────────────────────────────────

class _CountryPickerButton extends StatelessWidget {
  const _CountryPickerButton({
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _openSheet(context) : null,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              selected.code,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountrySheet(
        selected: selected,
        onSelect: (c) {
          onSelected(c);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Country bottom sheet ─────────────────────────────────────────────────────

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.selected, required this.onSelect});

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelect;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CountryCode> get _filtered {
    if (_query.isEmpty) return kCountryCodes;
    final q = _query.toLowerCase();
    return kCountryCodes.where((c) =>
        c.label.toLowerCase().contains(q) ||
        c.code.contains(q) ||
        c.region.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.78,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: context.borderCol,
              borderRadius: AppBorderRadius.pill,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text('Select Country',
                      style: AppTypography.h3.copyWith(fontSize: 17)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.search_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Search country or code…',
                        hintStyle: AppTypography.bodyMd
                            .copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No countries found',
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: bottomPad + 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: context.borderCol),
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final isSelected = c.region == widget.selected.region;
                      return ListTile(
                        onTap: () => widget.onSelect(c),
                        leading: Text(c.flag,
                            style: const TextStyle(fontSize: 22)),
                        title: Text(
                          c.label,
                          style: AppTypography.bodyMd.copyWith(
                            color: isSelected
                                ? AppColors.teal
                                : context.primaryText,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(c.region,
                            style: AppTypography.bodyXs
                                .copyWith(color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.code,
                                style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0)),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_rounded,
                                  size: 16, color: AppColors.teal),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
