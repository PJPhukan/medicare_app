import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/data/country_codes.dart';

// ─── Reusable phone field: country picker + number input ─────────────────────

class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.label,
    this.hint = 'Phone number',
    this.error,
    this.initialCountry,
    this.onCountryChanged,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final String? error;
  final CountryCode? initialCountry;
  final ValueChanged<CountryCode>? onCountryChanged;
  final ValueChanged<String>? onChanged;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late CountryCode _country;

  @override
  void initState() {
    super.initState();
    _country = widget.initialCountry ?? kDefaultCountry;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: secondaryColor, letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CountryCodePicker(
              selected: _country,
              onSelected: (c) {
                setState(() => _country = c);
                widget.onCountryChanged?.call(c);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  onChanged: widget.onChanged,
                  style: GoogleFonts.inter(fontSize: 15, color: textColor),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.inter(fontSize: 15, color: hintColor),
                    filled: true,
                    fillColor: bgInput,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: widget.error != null ? AppColors.error : borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: widget.error != null ? AppColors.error : AppColors.teal,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.error!,
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Chip that shows the selected country and opens the picker on tap ─────────
class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgColor = isDark ? AppColors.dark700 : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(selected.code,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                )),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: selected,
        onSelected: (c) {
          Navigator.pop(context);
          onSelected(c);
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected, required this.onSelected});
  final CountryCode selected;
  final ValueChanged<CountryCode> onSelected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<CountryCode> _filtered = kCountryCodes;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = kCountryCodes
          .where((c) =>
              c.label.toLowerCase().contains(query) ||
              c.code.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.dark800 : Colors.white;
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dark600 : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(AppStrings.selectCountry,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  )),
            ),
            const SizedBox(height: 14),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                decoration: InputDecoration(
                  hintText: AppStrings.searchCountryHint,
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: hintColor),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: hintColor),
                  filled: true,
                  fillColor: isDark ? AppColors.dark700 : const Color(0xFFF8FAFC),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Divider(color: borderColor, height: 1),

            // List
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _filtered.length,
                itemExtent: 56,
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final isSelected = c.region == widget.selected.region;
                  return InkWell(
                    onTap: () => widget.onSelected(c),
                    child: Container(
                      color: isSelected
                          ? AppColors.teal.withValues(alpha: 0.06)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(c.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(c.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.teal : textPrimary,
                                )),
                          ),
                          Text(c.code,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.teal : textSecondary,
                              )),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_rounded, size: 16, color: AppColors.teal),
                          ],
                        ],
                      ),
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
