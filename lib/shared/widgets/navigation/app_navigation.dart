import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/extensions/context_extensions.dart';
import '../badges/app_badge.dart';

// ─── Nav item model ───────────────────────────────────────────────────────────

class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.badge = 0,
    this.requiredPermission,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final int badge;
  final String? requiredPermission;
}

// ─── Bottom nav bar ───────────────────────────────────────────────────────────

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = i == currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: item,
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void didUpdateWidget(_NavBarItem old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final c = AppColors.teal;

    return GestureDetector(
      onTap: () {
        _ctrl.forward().then((_) => _ctrl.reverse());
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppNotificationDot(
              count: widget.item.badge,
              child: AnimatedSwitcher(
                duration: AppAnimations.fast,
                child: Icon(
                  selected ? widget.item.selectedIcon : widget.item.icon,
                  key: ValueKey(selected),
                  size: 22,
                  color: selected ? c : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppTypography.labelXs.copyWith(
                color: selected ? c : AppColors.textHint,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Navigation rail (tablet) ─────────────────────────────────────────────────

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.header,
    this.extended = false,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? header;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      backgroundColor: context.cardBg,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      indicatorColor: AppColors.teal20,
      selectedIconTheme: const IconThemeData(color: AppColors.teal),
      unselectedIconTheme: const IconThemeData(color: AppColors.textHint),
      selectedLabelTextStyle: AppTypography.labelSm.copyWith(color: AppColors.teal),
      unselectedLabelTextStyle:
          AppTypography.labelSm.copyWith(color: context.secondaryText),
      leading: header,
      destinations: items.map((item) => NavigationRailDestination(
        icon: AppNotificationDot(count: item.badge, child: Icon(item.icon)),
        selectedIcon: AppNotificationDot(count: item.badge, child: Icon(item.selectedIcon)),
        label: Text(item.label),
      )).toList(),
    );
  }
}

// ─── Breadcrumb ───────────────────────────────────────────────────────────────

class BreadcrumbItem {
  const BreadcrumbItem({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
}

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key, required this.items});
  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.asMap().entries.expand((e) {
          final isLast = e.key == items.length - 1;
          return [
            GestureDetector(
              onTap: e.value.onTap,
              child: Text(
                e.value.label,
                style: AppTypography.labelSm.copyWith(
                  color: isLast ? context.primaryText : AppColors.textHint,
                ),
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textHint),
              ),
          ];
        }).toList(),
      ),
    );
  }
}
