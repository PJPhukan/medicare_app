import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../medicines/presentation/screens/medicines_screen.dart';
import '../../../vitals/presentation/screens/vitals_screen.dart';
import '../../../schedule/presentation/screens/schedule_screen.dart';
import '../../../professionals/presentation/screens/professionals_screen.dart';
import '../../../message/presentation/screens/message_screen.dart';
import '../../../insights/presentation/screens/insights_screen.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../notes/presentation/screens/notes_screen.dart';
import '../../../profile/presentation/screens/settings_screen.dart';
import '../../../connections/presentation/screens/connections_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../emergency/presentation/screens/emergency_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../patients/presentation/screens/patients_screen.dart';
import '../../../caretakers/presentation/screens/caretakers_screen.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../support/presentation/screens/support_screen.dart';
import '../../../professional_profile/presentation/screens/pro_hub_screen.dart';
import '../../../professional_profile/presentation/providers/pro_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/bottom_sheets/feedback_sheet.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/tabs_provider.dart';
import '../../data/models/tab_config_model.dart';

// ─── Client-side slug registry ────────────────────────────────────────────────

class _SlugMeta {
  final IconData outlineIcon;
  final IconData filledIcon;
  final Color color;
  final String section;

  const _SlugMeta({
    required this.outlineIcon,
    required this.filledIcon,
    required this.color,
    required this.section,
  });
}

const _slugMeta = <String, _SlugMeta>{
  'home':          _SlugMeta(outlineIcon: Icons.home_outlined, filledIcon: Icons.home_rounded, color: AppColors.teal, section: 'Overview'),
  'dashboard':     _SlugMeta(outlineIcon: Icons.home_outlined, filledIcon: Icons.home_rounded, color: AppColors.teal, section: 'Overview'),
  'medicines':     _SlugMeta(outlineIcon: Icons.medication_outlined, filledIcon: Icons.medication_rounded, color: AppColors.green, section: 'Overview'),
  'vitals':        _SlugMeta(outlineIcon: Icons.monitor_heart_outlined, filledIcon: Icons.monitor_heart_rounded, color: AppColors.red, section: 'Health'),
  'professionals': _SlugMeta(outlineIcon: Icons.people_outline_rounded, filledIcon: Icons.people_rounded, color: AppColors.teal, section: 'Health'),
  'messages':      _SlugMeta(outlineIcon: Icons.chat_bubble_outline_rounded, filledIcon: Icons.chat_bubble_rounded, color: AppColors.green, section: 'People & Care'),
  'reminders':     _SlugMeta(outlineIcon: Icons.alarm_outlined, filledIcon: Icons.alarm_rounded, color: AppColors.amber, section: 'Overview'),
  'schedule':      _SlugMeta(outlineIcon: Icons.calendar_today_outlined, filledIcon: Icons.calendar_today_rounded, color: AppColors.blue, section: 'Health'),
  'reports':       _SlugMeta(outlineIcon: Icons.description_outlined, filledIcon: Icons.description_rounded, color: AppColors.purple, section: 'Health'),
  'insights':      _SlugMeta(outlineIcon: Icons.insights_outlined, filledIcon: Icons.insights_rounded, color: AppColors.purple, section: 'Health'),
  'alerts':        _SlugMeta(outlineIcon: Icons.notifications_outlined, filledIcon: Icons.notifications_active_rounded, color: AppColors.red, section: 'Health'),
  'emergency':     _SlugMeta(outlineIcon: Icons.emergency_outlined, filledIcon: Icons.emergency_rounded, color: AppColors.red, section: 'Emergency'),
  'patients':      _SlugMeta(outlineIcon: Icons.people_alt_outlined, filledIcon: Icons.people_alt_rounded, color: AppColors.teal, section: 'People & Care'),
  'caretakers':    _SlugMeta(outlineIcon: Icons.supervisor_account_outlined, filledIcon: Icons.supervisor_account_rounded, color: AppColors.blue, section: 'People & Care'),
  'community':     _SlugMeta(outlineIcon: Icons.groups_outlined, filledIcon: Icons.groups_rounded, color: AppColors.green, section: 'People & Care'),
  'notes':         _SlugMeta(outlineIcon: Icons.sticky_note_2_outlined, filledIcon: Icons.sticky_note_2_rounded, color: AppColors.amber, section: 'People & Care'),
  'settings':      _SlugMeta(outlineIcon: Icons.settings_outlined, filledIcon: Icons.settings_rounded, color: AppColors.textSecondary, section: 'People & Care'),
  'profile':       _SlugMeta(outlineIcon: Icons.person_outline_rounded, filledIcon: Icons.person_rounded, color: AppColors.blue, section: 'Overview'),
  'pro-profile':   _SlugMeta(outlineIcon: Icons.badge_outlined, filledIcon: Icons.badge_rounded, color: AppColors.purple, section: 'My Professional'),
  'professional-profile': _SlugMeta(outlineIcon: Icons.badge_outlined, filledIcon: Icons.badge_rounded, color: AppColors.purple, section: 'My Professional'),
  'connections':   _SlugMeta(outlineIcon: Icons.group_outlined, filledIcon: Icons.group_rounded, color: AppColors.blue, section: 'My Professional'),
  '/professionals/connections': _SlugMeta(outlineIcon: Icons.group_outlined, filledIcon: Icons.group_rounded, color: AppColors.blue, section: 'My Professional'),
  'help':          _SlugMeta(outlineIcon: Icons.help_outline_rounded, filledIcon: Icons.help_rounded, color: AppColors.blue, section: 'Help & Support'),
  'support':       _SlugMeta(outlineIcon: Icons.headset_mic_outlined, filledIcon: Icons.headset_mic_rounded, color: AppColors.teal, section: 'Help & Support'),
  'feedback':      _SlugMeta(outlineIcon: Icons.rate_review_outlined, filledIcon: Icons.rate_review_rounded, color: AppColors.green, section: 'Help & Support'),
  'privacy':       _SlugMeta(outlineIcon: Icons.privacy_tip_outlined, filledIcon: Icons.privacy_tip_rounded, color: AppColors.textSecondary, section: 'Help & Support'),
};

// Push screens by slug — null means tab-switch only or special action
Widget? _pushScreenForSlug(String slug) => switch (slug) {
  'home'          => const DashboardScreen(),
  'dashboard'     => const DashboardScreen(),
  'medicines'     => const MedicinesScreen(),
  'vitals'        => const VitalsScreen(),
  'professionals' => const ProfessionalsScreen(),
  'messages'      => const MessageScreen(),
  'reminders'     => const RemindersScreen(),
  'schedule'      => const ScheduleScreen(),
  'reports'       => const ReportsScreen(),
  'insights'      => const InsightsScreen(),
  'alerts'        => const AlertsScreen(),
  'emergency'     => const EmergencyScreen(),
  'patients'      => const PatientsScreen(),
  'caretakers'    => const CaretakersScreen(),
  'community'     => const CommunityScreen(),
  'notes'         => const NotesScreen(),
  'settings'      => const SettingsScreen(),
  'profile'       => const ProfileScreen(),
  'pro-profile'   => const ProHubScreen(),
  'professional-profile' => const ProHubScreen(),
  'connections'   => const ConnectionsScreen(),
  '/professionals/connections' => const ConnectionsScreen(),
  'help'          => const SupportScreen(),
  'support'       => const SupportScreen(),
  'privacy'       => const SupportScreen(),
  _               => null,
};

// Tab configs sometimes carry a leading '/' on the slug and sometimes don't
// (easy to forget when configuring in admin). Resolve slugs tolerantly so a
// missing or extra leading slash never silently hides a tab.
String _stripSlash(String s) => s.startsWith('/') ? s.substring(1) : s;

// Map sidebar-only slugs to go_router routes (tabs handled separately)
String? _slugToRoute(String slug) => switch (_stripSlash(slug)) {
  'profile'                              => AppRoutes.profile,
  'settings'                             => AppRoutes.settings,
  'pro-profile' || 'professional-profile' => AppRoutes.settingsProHub,
  'connections'                          => AppRoutes.professionalsConnections,
  'help' || 'support' || 'privacy'       => AppRoutes.support,
  _                                      => null,
};

_SlugMeta? _metaForSlug(String slug) =>
    _slugMeta[slug] ??
    _slugMeta[_stripSlash(slug)] ??
    _slugMeta['/${_stripSlash(slug)}'];

Widget? _resolveScreen(String slug) =>
    _pushScreenForSlug(slug) ??
    _pushScreenForSlug(_stripSlash(slug)) ??
    _pushScreenForSlug('/${_stripSlash(slug)}');

bool _isProGatedSlug(String slug) =>
    _proGatedSlugs.contains(slug) ||
    _proGatedSlugs.contains(_stripSlash(slug)) ||
    _proGatedSlugs.contains('/${_stripSlash(slug)}');

// Sidebar section order and danger flags
const _sectionOrder = [
  'Overview', 'Health', 'Emergency', 'People & Care', 'My Professional', 'Help & Support',
];
const _dangerSections = {'Emergency'};

// Professional working tabs — shown only to VERIFIED professionals. The
// pro-profile hub itself is intentionally NOT here, so anyone can open it to
// apply or check their application status.
const _proGatedSlugs = {
  'connections',
  '/professionals/connections',
  'professional-requests',
  'professional-my-requests',
  '/professionals/requests',
};

bool _isProGated(String slug, String tabType) =>
    tabType == 'ROLE_ONLY' || _isProGatedSlug(slug);

// Fallback CORE tabs when backend is unavailable
const _fallbackSlugs = ['home', 'medicines', 'vitals', 'professionals', 'settings'];
const _fallbackLabels = [
  AppStrings.tabHome, AppStrings.tabMedicines, AppStrings.tabVitals,
  AppStrings.tabProfessionals, AppStrings.tabSettings,
];

// ─── Active core tab ──────────────────────────────────────────────────────────

class _CoreTab {
  final String slug;
  final String label;
  final _SlugMeta meta;
  final Widget screen;
  final String? svgIcon;

  const _CoreTab({
    required this.slug,
    required this.label,
    required this.meta,
    required this.screen,
    this.svgIcon,
  });
}

// ─── AppShell ─────────────────────────────────────────────────────────────────

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;
  bool _navVisible = true;
  // Cache screen instances so they survive tab list rebuilds
  final _screenCache = <String, Widget>{};
  List<_CoreTab> _coreTabs = [];
  // Track which tabs the user has actually visited, so each screen's initState
  // (and any side-effects like location prompts) only runs on first visit —
  // not eagerly at app launch.
  final _activatedIndices = <int>{0};

  @override
  void initState() {
    super.initState();
    registerTabSwitcher(_switchBySlug);
  }

  @override
  void dispose() {
    unregisterTabSwitcher();
    super.dispose();
  }

  void _switchBySlug(String slug) {
    final i = _coreTabs.indexWhere((t) => _stripSlash(t.slug) == _stripSlash(slug));
    if (i >= 0) {
      _switchTab(i);
    } else {
      final ctx = appShellKey.currentContext;
      if (ctx == null) return;
      final route = _slugToRoute(slug);
      if (route != null) ctx.push(route);
    }
  }

  void _switchTab(int index) {
    appShellKey.currentState?.closeDrawer();
    setState(() {
      _index = index;
      _navVisible = true;
      _activatedIndices.add(index);
    });
    AppLogger.i('Tab switch → $index', tag: 'Shell');
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 4 && _navVisible) { setState(() => _navVisible = false); }
      else if (delta < -4 && !_navVisible) { setState(() => _navVisible = true); }
    } else if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0 && !_navVisible) {
        setState(() => _navVisible = true);
      }
    }
    return false;
  }

  Widget _screenFor(String slug) {
    return _screenCache.putIfAbsent(slug, () => _resolveScreen(slug) ?? const _ComingSoonScreen());
  }

  List<_CoreTab> _buildCoreTabs(List<TabConfigModel> tabs, bool isVerifiedPro) {
    final navTabs = tabs
        .where((t) =>
            t.isActive &&
            t.allowView &&
            t.showInBottomNav &&
            _metaForSlug(t.slug) != null &&
            // Professional-only tabs appear only once the pro is verified.
            (!_isProGated(t.slug, t.tabType) || isVerifiedPro))
        .toList()
      ..sort((a, b) {
        final n = a.navOrder.compareTo(b.navOrder);
        return n != 0 ? n : a.sortOrder.compareTo(b.sortOrder);
      });
    final capped = navTabs.take(7).toList();
    if (capped.isEmpty) return _fallbackCoreTabs();
    return capped.map((t) => _CoreTab(
      slug: t.slug,
      label: t.label,
      meta: _metaForSlug(t.slug)!,
      screen: _screenFor(t.slug),
      svgIcon: t.iconSvg,
    )).toList();
  }

  List<_CoreTab> _fallbackCoreTabs() {
    return List.generate(_fallbackSlugs.length, (i) {
      final slug = _fallbackSlugs[i];
      return _CoreTab(
        slug: slug,
        label: _fallbackLabels[i],
        meta: _metaForSlug(slug)!,
        screen: _screenFor(slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final tabsAsync = ref.watch(tabsProvider);
    // Verified professionals get their role-only tabs; rebuild when this changes.
    final isVerifiedPro = ref.watch(proProfileProvider).profile?.isVerified ?? false;

    _coreTabs = tabsAsync.when(
      data: (tabs) => _buildCoreTabs(tabs, isVerifiedPro),
      loading: _fallbackCoreTabs,
      error: (_, __) => _fallbackCoreTabs(),
    );

    final coreTabs = _coreTabs;
    final safeIndex = _index.clamp(0, coreTabs.length - 1);
    _activatedIndices.add(safeIndex);

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() { _index = 0; _navVisible = true; });
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        key: appShellKey,
        resizeToAvoidBottomInset: false,
        drawer: _AppSidebar(
          onSwitchTab: _switchTab,
          coreSlugs: coreTabs.map((t) => t.slug).toList(),
          allTabs: tabsAsync.valueOrNull ?? [],
          activeSlug: coreTabs.isNotEmpty ? coreTabs[safeIndex].slug : null,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () { if (!_navVisible) setState(() => _navVisible = true); },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: IndexedStack(
                        index: safeIndex,
                        children: List.generate(coreTabs.length, (i) {
                          // Lazily build each tab's screen only after its first
                          // visit; keep it alive afterwards so state persists.
                          return _activatedIndices.contains(i)
                              ? coreTabs[i].screen
                              : const SizedBox.shrink();
                        }),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: AnimatedSlide(
                    offset: _navVisible ? Offset.zero : const Offset(0, 2.0),
                    duration: Duration(milliseconds: _navVisible ? 380 : 280),
                    curve: _navVisible ? Curves.easeOutCubic : Curves.easeInQuart,
                    child: AnimatedOpacity(
                      opacity: _navVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: _navVisible ? 300 : 200),
                      child: _BottomNav(
                        selectedIndex: safeIndex,
                        bottomPadding: bottomInset,
                        items: coreTabs,
                        onTap: (i) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _index = i;
                            _navVisible = true;
                            _activatedIndices.add(i);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Floating glass bottom nav ────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;
  final List<_CoreTab> items;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.bottomPadding,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? const Color(0xFF131920).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.94);
    final navBorderColor = isDark ? const Color(0xFF1F2D3F) : const Color(0xFFE2E8F0);
    final inactiveColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 68 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: navBorderColor, width: 0.5)),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 24, offset: const Offset(0, -4)),
              BoxShadow(color: AppColors.teal.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -2)),
            ],
          ),
          child: LayoutBuilder(
            builder: (_, box) {
              final count = items.length;
              if (count == 0) return const SizedBox.shrink();
              final slotW = box.maxWidth / count;
              final lineW = slotW * 0.55;
              final coneW = slotW * 0.85;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: slotW * selectedIndex + (slotW - coneW) / 2,
                    top: 0, width: coneW, height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [AppColors.teal.withValues(alpha: 0.18), Colors.transparent],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: slotW * selectedIndex + (slotW - lineW) / 2,
                    top: 0, width: lineW, height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          AppColors.teal.withValues(alpha: 0.90),
                          Colors.transparent,
                        ]),
                        boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.65), blurRadius: 12, spreadRadius: 2)],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(count, (i) {
                      final active = i == selectedIndex;
                      final tab = items[i];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: 68,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  key: ValueKey('nav_${i}_$active'),
                                  tween: Tween(begin: 0.75, end: 1.0),
                                  duration: const Duration(milliseconds: 360),
                                  curve: Curves.easeOutBack,
                                  builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                                  child: tab.svgIcon != null && tab.svgIcon!.isNotEmpty
                                      ? SvgPicture.string(
                                          tab.svgIcon!,
                                          width: 22,
                                          height: 22,
                                          colorFilter: ColorFilter.mode(
                                            active ? AppColors.teal : inactiveColor,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : Icon(
                                          active ? tab.meta.filledIcon : tab.meta.outlineIcon,
                                          size: 22,
                                          color: active ? AppColors.teal : inactiveColor,
                                        ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: 0,
                                    color: active ? AppColors.teal : inactiveColor,
                                  ),
                                  child: Text(tab.label),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _AppSidebar extends ConsumerWidget {
  final void Function(int) onSwitchTab;
  final List<String> coreSlugs;
  final List<TabConfigModel> allTabs;
  final String? activeSlug;

  const _AppSidebar({
    required this.onSwitchTab,
    required this.coreSlugs,
    required this.allTabs,
    this.activeSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final bg = isDark ? context.bg : Colors.white;
    final border = isDark ? context.borderCol : const Color(0xFFE2E8F0);

    final isVerifiedPro = ref.watch(proProfileProvider).profile?.isVerified ?? false;

    // Group all active tabs by section
    final grouped = <String, List<TabConfigModel>>{};
    for (final tab in allTabs) {
      if (!tab.isActive || !tab.allowView) continue;
      // Professional-only tabs appear only once the pro is verified.
      if (_isProGated(tab.slug, tab.tabType) && !isVerifiedPro) continue;
      final meta = _metaForSlug(tab.slug);
      if (meta == null) continue;
      grouped.putIfAbsent(meta.section, () => []).add(tab);
    }

    // Sort tabs within each section by sortOrder
    for (final list in grouped.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Brand header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
              child: Image.asset(
                isDark
                    ? 'assets/images/logo_text_dark.png'
                    : 'assets/images/logo_text_light.png',
                height: 32,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),

            // ── Nav items (backend-driven) ────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  for (final section in _sectionOrder)
                    if (grouped.containsKey(section))
                      _SidebarSection(
                        label: section,
                        isDark: isDark,
                        border: border,
                        isDanger: _dangerSections.contains(section),
                        items: grouped[section]!.map((tab) {
                          final meta = _metaForSlug(tab.slug)!;
                          final coreIdx = coreSlugs.indexOf(tab.slug);
                          return _SidebarItem(
                            icon: meta.filledIcon,
                            svgIcon: tab.iconSvg,
                            label: tab.label,
                            color: meta.color,
                            isActive: tab.slug == activeSlug,
                            onTap: () {
                              if (coreIdx >= 0) {
                                onSwitchTab(coreIdx);
                              } else if (_stripSlash(tab.slug) == 'feedback') {
                                Scaffold.of(context).closeDrawer();
                                showFeedbackSheet(context);
                              } else {
                                Scaffold.of(context).closeDrawer();
                                final route = _slugToRoute(tab.slug);
                                if (route != null) context.push(route);
                              }
                            },
                          );
                        }).toList(),
                      ),
                ],
              ),
            ),

            // ── Theme toggle ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.10),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 16, color: AppColors.blue),
                ),
                title: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0,
                      color: isDark ? context.primaryText : const Color(0xFF1A202C)),
                ),
                trailing: _ThemeToggle(
                  value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && isDark),
                  isDark: isDark,
                  onChanged: (on) {
                    ref.read(themeModeProvider.notifier).state =
                        on ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
            ),

            // ── Sign out ──────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.10),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: const Icon(Icons.logout_rounded, size: 16, color: AppColors.red),
                ),
                title: const Text('Sign Out',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0, color: AppColors.red)),
                onTap: () {
                  // Capture the notifier before closing the drawer — the drawer's
                  // animation disposes this ConsumerWidget's ref, making a late
                  // ref.read() on it silently fail inside the dialog callback.
                  final authNotifier = ref.read(authProvider.notifier);
                  Scaffold.of(context).closeDrawer();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: isDark ? context.cardBg : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                      title: AppText.h3('Sign Out'),
                      content: AppText.bodyMd('Are you sure you want to sign out?',
                          color: AppColors.textSecondary),
                      actions: [
                        TextButton(
                          onPressed: () => ctx.pop(),
                          child: const Text(AppStrings.cancel,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            ctx.pop();
                            authNotifier.logout();
                          },
                          child: const Text('Sign Out',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.red)),
                        ),
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

// ─── Sidebar section ──────────────────────────────────────────────────────────

class _SidebarSection extends StatelessWidget {
  final String label;
  final List<_SidebarItem> items;
  final bool isDark;
  final Color border;
  final bool isDanger;

  const _SidebarSection({
    required this.label,
    required this.items,
    required this.isDark,
    required this.border,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDanger
        ? AppColors.red.withValues(alpha: 0.8)
        : (isDark ? AppColors.textHint : const Color(0xFF94A3B8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
          child: Row(
            children: [
              if (isDanger) ...[
                Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.red.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: labelColor),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }
}

// ─── Sidebar item ─────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? svgIcon;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.svgIcon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSvg = svgIcon != null && svgIcon!.isNotEmpty;
    final iconBg = isActive
        ? color.withValues(alpha: 0.14)
        : (isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF1F5F9));
    final iconColor = isActive
        ? color
        : (isDark ? AppColors.textHint : const Color(0xFF94A3B8));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.mdAll,
          color: isActive
              ? color.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppBorderRadius.smAll,
              ),
              child: hasSvg
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: SvgPicture.string(
                        svgIcon!,
                        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                    )
                  : Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0,
                  color: isActive
                      ? color
                      : (isDark ? context.primaryText : const Color(0xFF1A202C)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Smooth animated theme toggle ────────────────────────────────────────────

class _ThemeToggle extends StatefulWidget {
  const _ThemeToggle({required this.value, required this.isDark, required this.onChanged});
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.value ? 1.0 : 0.0,
    );
    _position = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void didUpdateWidget(_ThemeToggle old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const thumbTravel = 22.0;
    final isDark = widget.isDark;

    // Off/on colors per theme
    final offTrack  = isDark ? const Color(0xFF1A2332) : const Color(0xFFF1F5F9);
    final onTrack   = isDark ? const Color(0x2E4D9EFF) : const Color(0xFFDBEAFE);
    final offBorder = isDark ? const Color(0xFF1F2D3F) : const Color(0xFFCBD5E1);
    final onBorder  = AppColors.blue;
    final offThumb  = isDark ? const Color(0xFF2A3A4E) : const Color(0xFF94A3B8);
    const onThumb   = AppColors.blue;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _position.value;
          return Container(
            width: 46, height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Color.lerp(offTrack, onTrack, t),
              border: Border.all(color: Color.lerp(offBorder, onBorder, t)!, width: 1.5),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: t * thumbTravel,
                  top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: Color.lerp(offThumb, onThumb, t),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          widget.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          key: ValueKey(widget.value),
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Coming soon placeholder ──────────────────────────────────────────────────

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.lgAll,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 34,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature is on its way.\nCheck back soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 28),
                if (context.canPop())
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: const BorderSide(color: AppColors.teal, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdAll),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
