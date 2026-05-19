import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/country_codes.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Phone number input with an integrated country code selector.
///
/// Uses the full [kCountryCodes] list (195 countries) sourced from
/// `core/data/country_codes.dart`.
///
/// [onChanged] fires with the combined value: e.g. "+91 9876543210".
/// [onCountryChanged] fires with the ISO region code: e.g. "IN".
///
/// ```dart
/// AppPhoneInput(
///   label: 'Phone number',
///   initialCountryCode: 'IN',
///   onChanged: (full) => _phone = full,
/// )
/// ```
class AppPhoneInput extends StatefulWidget {
  const AppPhoneInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.onChanged,
    this.onCountryChanged,
    this.textInputAction,
    this.initialCountryCode = 'IN',
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;

  /// Fires with the full phone string: dialCode + space + number.
  final ValueChanged<String>? onChanged;

  /// Fires with the ISO region code of the selected country (e.g. "IN").
  final ValueChanged<String>? onCountryChanged;

  final TextInputAction? textInputAction;

  /// ISO region code of the pre-selected country. Defaults to "IN" (India).
  final String initialCountryCode;

  final bool enabled;
  final bool autofocus;

  @override
  State<AppPhoneInput> createState() => _AppPhoneInputState();
}

class _AppPhoneInputState extends State<AppPhoneInput> {
  late CountryCode _selected;
  String _number = '';

  @override
  void initState() {
    super.initState();
    _selected = kCountryCodes.firstWhere(
      (c) => c.region == widget.initialCountryCode,
      orElse: () => kDefaultCountry,
    );
  }

  void _notify() =>
      widget.onChanged?.call('${_selected.code} $_number');

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: _selected,
        onSelect: (c) {
          setState(() => _selected = c);
          widget.onCountryChanged?.call(c.region);
          _notify();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final hasError  = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError
        ? AppColors.error
        : (isDark ? context.borderCol : const Color(0xFFE2E8F0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelSm.copyWith(letterSpacing: 0.2),
          ),
          const SizedBox(height: 6),
        ],

        // ── Field ─────────────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: isDark ? context.inputBg : Colors.white,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              // ── Country selector ───────────────────────────────────────────
              GestureDetector(
                onTap: widget.enabled ? _openPicker : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: borderCol),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selected.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selected.code,
                        style: AppTypography.labelSm.copyWith(
                          color: context.primaryText,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Number field ───────────────────────────────────────────────
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (v) {
                    _number = v;
                    _notify();
                  },
                  style: AppTypography.bodyMd
                      .copyWith(color: context.primaryText),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? '9876543210',
                    hintStyle: AppTypography.bodyMd
                        .copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Error / helper ────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.error!,
                style:
                    AppTypography.bodyXs.copyWith(color: AppColors.error),
              ),
            ),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.helper!,
            style: AppTypography.bodyXs
                .copyWith(color: AppColors.textHint),
          ),
        ],
      ],
    );
  }
}

// ─── Country picker bottom sheet ──────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelect;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
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
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? context.cardBg : Colors.white;
    final border     = isDark ? context.borderCol : const Color(0xFFE2E8F0);
    final bottomPad  = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.78,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: border,
              borderRadius: AppBorderRadius.pill,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Country',
                    style: AppTypography.h3.copyWith(fontSize: 17),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? context.inputBg
                    : const Color(0xFFF1F5F9),
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: border),
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
                      onChanged: (v) =>
                          setState(() => _query = v),
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

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding:
                        EdgeInsets.only(bottom: bottomPad + 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: border),
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final isSelected =
                          c.region == widget.selected.region;
                      return ListTile(
                        onTap: () {
                          widget.onSelect(c);
                          Navigator.pop(context);
                        },
                        leading: Text(
                          c.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
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
                        subtitle: Text(
                          c.region,
                          style: AppTypography.bodyXs.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.code,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.teal,
                              ),
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
