import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_border_radius.dart';

/// Styled scrollable tab bar with pill indicator.
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.isScrollable = true,
    this.indicatorColor,
    this.padding,
  });

  final List<AppTab> tabs;
  final TabController controller;
  final bool isScrollable;
  final Color? indicatorColor;
  final EdgeInsetsGeometry? padding;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final c = indicatorColor ?? AppColors.teal;
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      indicator: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
      labelColor: c,
      unselectedLabelColor: AppColors.textHint,
      labelStyle: AppTypography.labelMd,
      unselectedLabelStyle: AppTypography.labelMd,
      dividerColor: Colors.transparent,
      padding: padding,
      tabs: tabs.map((t) => Tab(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (t.icon != null) ...[
              Icon(t.icon, size: 14),
              const SizedBox(width: 5),
            ],
            Text(t.label),
            if (t.badge != null && t.badge! > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: AppBorderRadius.pill,
                ),
                child: Text(
                  '${t.badge}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textInverse),
                ),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }
}

class AppTab {
  const AppTab({required this.label, this.icon, this.badge});
  final String label;
  final IconData? icon;
  final int? badge;
}
