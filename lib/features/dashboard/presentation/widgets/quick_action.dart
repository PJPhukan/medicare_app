import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Quick action button ──────────────────────────────────────────────────────

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final String   subtitle;
  final Color    color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      effectColor: color,
      padding: EdgeInsets.zero,
      child: AppListTile(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: Colors.transparent,
        leading: AppContainer.tinted(
          color: color,
          borderRadius: AppBorderRadius.smAll,
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: color),
        ),
        title: label,
        subtitle: subtitle,
        trailing: Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_rounded, size: 12, color: color),
        ),
      ),
    );
  }
}

// ─── Banner carousel ──────────────────────────────────────────────────────────
