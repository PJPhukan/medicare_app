import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../texts/app_text.dart';

/// Toggle switch with optional label and description.
class AppToggleSwitchInput extends StatelessWidget {
  const AppToggleSwitchInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.enabled = true,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final String? description;
  final bool enabled;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.teal;

    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  AppText.bodyMd(
                    label!,
                    color: enabled ? null : AppColors.textHint,
                  ),
                if (description != null)
                  AppText.bodyXs(
                    description!,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: color,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.textHint.withValues(alpha: 0.3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
