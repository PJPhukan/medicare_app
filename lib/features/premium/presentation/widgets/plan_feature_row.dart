import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/texts/app_text.dart';

class PlanFeatureRow extends StatelessWidget {
  const PlanFeatureRow({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.bold = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 11, color: iconColor),
            ),

            const SizedBox(width: 8),
            
            Expanded(
              child: AppText.bodySm(
                label,
                color: bold ? null : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      );
}
