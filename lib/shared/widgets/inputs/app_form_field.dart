import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

// ─── Dropdown ────────────────────────────────────────────────────────────────

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.prefix,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTypography.labelMd.copyWith(color: context.primaryText)),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          items: items,
          hint: hint != null ? Text(hint!, style: AppTypography.bodyMd.copyWith(color: AppColors.textHint)) : null,
          icon: const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.textHint),
          dropdownColor: context.inputBg,
          style: AppTypography.bodyMd.copyWith(color: context.primaryText),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.inputBg,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: IconTheme(
                      data: const IconThemeData(size: 18, color: AppColors.textHint),
                      child: prefix!,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            border: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: BorderSide(color: context.borderCol)),
            enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: BorderSide(color: context.borderCol)),
            focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.error)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

// ─── Switch row ───────────────────────────────────────────────────────────────

class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.color,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.labelMd.copyWith(color: context.primaryText)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!,
                      style: AppTypography.bodySm
                          .copyWith(color: context.secondaryText)),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color ?? AppColors.teal,
        ),
      ],
    );
  }
}

// ─── Checkbox row ─────────────────────────────────────────────────────────────

class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppBorderRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: value, onChanged: onChanged),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTypography.labelMd
                            .copyWith(color: context.primaryText)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle!,
                            style: AppTypography.bodySm
                                .copyWith(color: context.secondaryText)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date picker field ───────────────────────────────────────────────────────

class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.day}/${value!.month}/${value!.year}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMd.copyWith(color: context.primaryText)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(
                color: errorText != null ? AppColors.error : context.borderCol,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textHint),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    display ?? (hint ?? 'Select date'),
                    style: AppTypography.bodyMd.copyWith(
                      color: display != null ? context.primaryText : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText!, style: AppTypography.caption.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}

// ─── Time picker field ───────────────────────────────────────────────────────

class AppTimePickerField extends StatelessWidget {
  const AppTimePickerField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.hint,
    this.errorText,
  });

  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  final String? hint;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final display = value?.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMd.copyWith(color: context.primaryText)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(
                color: errorText != null ? AppColors.error : context.borderCol,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textHint),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    display ?? (hint ?? 'Select time'),
                    style: AppTypography.bodyMd.copyWith(
                      color: display != null ? context.primaryText : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText!, style: AppTypography.caption.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}
