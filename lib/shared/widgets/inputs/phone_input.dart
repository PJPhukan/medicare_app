import 'package:app_medicare/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/country_codes.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';
import '../search_inputs/search_text_input.dart';

const double _kFieldHeight = 52.0;
const double _kCountryBtnMinWidth = 90.0;

class AppPhoneInput extends StatefulWidget {
  const AppPhoneInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label = AppStrings.mobileNumber,
    this.hint = AppStrings.mobileHint,
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

  // Major 2 — extracted helper used in both initState and didUpdateWidget
  CountryCode _countryFromRegion(String region) => kCountryCodes.firstWhere(
        (c) => c.region.toUpperCase() == region.toUpperCase(),
        orElse: () => kDefaultCountry,
      );

  @override
  void initState() {
    super.initState();
    _selected = _countryFromRegion(widget.initialCountryCode);
    _number = widget.controller?.text ?? '';
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AppPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCountryCode != widget.initialCountryCode) {
      setState(() => _selected = _countryFromRegion(widget.initialCountryCode));
      _notify();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      setState(() => _number = widget.controller?.text ?? '');
      _notify();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    _number = widget.controller?.text ?? '';
    _notify();
  }

  void _notify() => widget.onChanged?.call(
        _number.isEmpty ? _selected.code : '${_selected.code} $_number',
      );

  OutlineInputBorder _border(BuildContext context, {Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color ?? context.borderCol, width: width),
      );

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
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
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          AppText.labelMd(widget.label!),
          const SizedBox(height: 6),
        ],

        // ── Field ─────────────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Country selector button ────────────────────────────────────
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? _openPicker : null,
                borderRadius: AppBorderRadius.mdAll,
                child: Container(
                  constraints: const BoxConstraints(minHeight: _kFieldHeight, minWidth: _kCountryBtnMinWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selected.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      AppText.labelSm(_selected.code),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── Number field ───────────────────────────────────────────────
            Expanded(
              child: SizedBox(
                height: _kFieldHeight,
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    // Bug 2 fix — no hardcoded length; countries vary (9–13 digits)
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style:
                      AppTypography.bodyMd.copyWith(color: context.primaryText),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTypography.bodyMd
                        .copyWith(color: AppColors.textHint),
                    filled: true,
                    fillColor: context.inputBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    enabledBorder:      _border(context, color: borderCol),
                    focusedBorder:      _border(context,
                        color: hasError ? AppColors.error : AppColors.teal,
                        width: 1.5),
                    errorBorder:        _border(context, color: AppColors.error),
                    focusedErrorBorder: _border(context,
                        color: AppColors.error, width: 1.5),
                    disabledBorder:     _border(context,
                        color: context.borderCol.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Error / helper ────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: AppText.error(widget.error!)),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 5),
          AppText.hint(widget.helper!),
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
    return kCountryCodes
        .where((c) =>
            c.label.toLowerCase().contains(q) ||
            c.code.contains(q) ||
            c.region.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bg            = context.cardBg;
    final border        = context.borderCol;
    final bottomPad     = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight  = MediaQuery.sizeOf(context).height;
    final statusBar     = MediaQuery.paddingOf(context).top;
    final spaceAboveKeyboard = screenHeight - keyboardInset - statusBar;
    final maxSheetHeight = spaceAboveKeyboard * 0.65;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Expanded(child: AppText.h3(AppStrings.selectCountry)),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AppSearchTextInput(
              controller: _searchCtrl,
              hint: AppStrings.searchCountryHint,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: AppText.bodyMd(
                      AppStrings.noCountriesFound,
                      color: AppColors.textSecondary,
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: bottomPad + 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: border),
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final isSelected = c.region == widget.selected.region;
                      return ListTile(
                        onTap: () {
                          widget.onSelect(c);
                          context.pop();
                        },
                        leading: Text(
                          c.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        title: AppText.bodyMd(
                          c.label,
                          color: isSelected ? AppColors.teal : null,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                        subtitle: AppText.bodyXs(
                          c.region,
                          color: AppColors.textSecondary,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.labelSm(
                              c.code,
                              color: AppColors.textSecondary,
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
    ),
    );
  }
}
