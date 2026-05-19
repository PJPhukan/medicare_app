import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'app_navigation.dart';

// ─── Permission model ─────────────────────────────────────────────────────────

class NavPermissions {
  const NavPermissions({required this.allowed});
  final Set<String> allowed;

  bool can(String permission) => allowed.contains(permission) || allowed.contains('*');

  static const all = NavPermissions(allowed: {'*'});
  static const guest = NavPermissions(allowed: {'home', 'professionals'});
  static const patient = NavPermissions(allowed: {
    'home', 'medicines', 'vitals', 'schedule', 'professionals',
    'messages', 'notifications', 'profile', 'community', 'insights',
    'alerts', 'notes', 'emergency', 'support',
  });
  static const professionalUser = NavPermissions(allowed: {
    'home', 'medicines', 'vitals', 'schedule', 'professionals',
    'professional_profile', 'connections', 'messages', 'notifications',
    'profile', 'community', 'insights', 'alerts', 'patients', 'reports',
    'notes', 'emergency', 'support',
  });
  static const caretaker = NavPermissions(allowed: {
    'home', 'patients', 'caretakers', 'schedule', 'messages',
    'notifications', 'profile', 'support',
  });
}

// ─── Provider (replace with real auth state in feature code) ─────────────────

final navPermissionsProvider = Provider<NavPermissions>((ref) {
  return NavPermissions.patient;
});

// ─── Permission-filtered nav builder ─────────────────────────────────────────

class PermissionNavBuilder extends ConsumerWidget {
  const PermissionNavBuilder({
    super.key,
    required this.allItems,
    required this.currentIndex,
    required this.onTap,
    this.useRail = false,
  });

  final List<NavItem> allItems;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool useRail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(navPermissionsProvider);
    final visible = allItems
        .where((item) => item.requiredPermission == null || perms.can(item.requiredPermission!))
        .toList();

    // Remap currentIndex to visible list
    final visibleIds = visible.map((e) => e.id).toList();
    final allId = currentIndex < allItems.length ? allItems[currentIndex].id : null;
    final mappedIndex = allId != null ? visibleIds.indexOf(allId).clamp(0, visible.length - 1) : 0;

    if (useRail) {
      return AppNavigationRail(
        items: visible,
        currentIndex: mappedIndex,
        onTap: (i) {
          final selectedId = visible[i].id;
          final originalIdx = allItems.indexWhere((e) => e.id == selectedId);
          onTap(originalIdx >= 0 ? originalIdx : i);
        },
      );
    }

    return AppBottomNav(
      items: visible,
      currentIndex: mappedIndex,
      onTap: (i) {
        final selectedId = visible[i].id;
        final originalIdx = allItems.indexWhere((e) => e.id == selectedId);
        onTap(originalIdx >= 0 ? originalIdx : i);
      },
    );
  }
}

// ─── App-level nav items (edit to match your routes) ─────────────────────────

const appNavItems = [
  NavItem(
    id: 'home',
    label: AppStrings.tabHome,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    route: '/',
  ),
  NavItem(
    id: 'medicines',
    label: AppStrings.tabMedicines,
    icon: Icons.medication_outlined,
    selectedIcon: Icons.medication_rounded,
    route: '/medicines',
    requiredPermission: 'medicines',
  ),
  NavItem(
    id: 'vitals',
    label: AppStrings.tabVitals,
    icon: Icons.favorite_outline_rounded,
    selectedIcon: Icons.favorite_rounded,
    route: '/vitals',
    requiredPermission: 'vitals',
  ),
  NavItem(
    id: 'professionals',
    label: AppStrings.tabProfessionals,
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
    route: '/professionals',
    requiredPermission: 'professionals',
  ),
  NavItem(
    id: 'profile',
    label: AppStrings.tabProfile,
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    route: '/profile',
    requiredPermission: 'profile',
  ),
];

// ─── Scaffold shell with adaptive nav ────────────────────────────────────────

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child, required this.currentRoute});
  final Widget child;
  final String currentRoute;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int get _currentIndex {
    final idx = appNavItems.indexWhere((e) => e.route == widget.currentRoute);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.dark900,
        body: Row(
          children: [
            PermissionNavBuilder(
              allItems: appNavItems,
              currentIndex: _currentIndex,
              onTap: _onTap,
              useRail: true,
            ),
            const VerticalDivider(width: 1, color: AppColors.dark600),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.dark900,
      body: widget.child,
      bottomNavigationBar: PermissionNavBuilder(
        allItems: appNavItems,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    if (index < appNavItems.length) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        appNavItems[index].route,
        (route) => false,
      );
    }
  }
}
