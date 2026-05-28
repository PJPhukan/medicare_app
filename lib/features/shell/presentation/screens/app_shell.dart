import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../support/presentation/screens/support_screen.dart';
import '../../../professional_profile/presentation/screens/pro_hub_screen.dart';
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
  'notes':         _SlugMeta(outlineIcon: Icons.sticky_note_2_outlined, filledIcon: Icons.sticky_note_2_rounded, color: AppColors.amber, section: 'People & Care'),
  'settings':      _SlugMeta(outlineIcon: Icons.settings_outlined, filledIcon: Icons.settings_rounded, color: AppColors.textSecondary, section: 'People & Care'),
  'profile':       _SlugMeta(outlineIcon: Icons.person_outline_rounded, filledIcon: Icons.person_rounded, color: AppColors.blue, section: 'Overview'),
  'pro-profile':   _SlugMeta(outlineIcon: Icons.badge_outlined, filledIcon: Icons.badge_rounded, color: AppColors.purple, section: 'My Professional'),
  'connections':   _SlugMeta(outlineIcon: Icons.group_outlined, filledIcon: Icons.group_rounded, color: AppColors.blue, section: 'My Professional'),
  'help':          _SlugMeta(outlineIcon: Icons.help_outline_rounded, filledIcon: Icons.help_rounded, color: AppColors.blue, section: 'Help & Support'),
  'support':       _SlugMeta(outlineIcon: Icons.headset_mic_outlined, filledIcon: Icons.headset_mic_rounded, color: AppColors.teal, section: 'Help & Support'),
  'feedback':      _SlugMeta(outlineIcon: Icons.rate_review_outlined, filledIcon: Icons.rate_review_rounded, color: AppColors.green, section: 'Help & Support'),
  'privacy':       _SlugMeta(outlineIcon: Icons.privacy_tip_outlined, filledIcon: Icons.privacy_tip_rounded, color: AppColors.textSecondary, section: 'Help & Support'),
};

// Push screens by slug — null means tab-switch only or special action
Widget? _pushScreenForSlug(String slug) => switch (slug) {
  'home'          => const DashboardScreen(),
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
  'notes'         => const NotesScreen(),
  'settings'      => const SettingsScreen(),
  'profile'       => const ProfileScreen(),
  'pro-profile'   => const ProHubScreen(),
  'connections'   => const ConnectionsScreen(),
  'help'          => const SupportScreen(),
  'support'       => const SupportScreen(),
  'privacy'       => const SupportScreen(),
  _               => null,
};

// Sidebar section order and danger flags
const _sectionOrder = [
  'Overview', 'Health', 'Emergency', 'People & Care', 'My Professional', 'Help & Support',
];
const _dangerSections = {'Emergency'};

// Fallback CORE tabs when backend is unavailable
const _fallbackSlugs = ['home', 'medicines', 'vitals', 'professionals', 'messages'];
const _fallbackLabels = [
  AppStrings.tabHome, AppStrings.tabMedicines, AppStrings.tabVitals,
  AppStrings.tabProfessionals, AppStrings.tabMessages,
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

  void _switchTab(int index) {
    appShellKey.currentState?.closeDrawer();
    setState(() {
      _index = index;
      _navVisible = true;
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
    return _screenCache.putIfAbsent(slug, () => _pushScreenForSlug(slug) ?? const SizedBox.shrink());
  }

  List<_CoreTab> _buildCoreTabs(List<TabConfigModel> tabs) {
    final core = tabs
        .where((t) => t.isActive && t.tabType == 'CORE' && _slugMeta.containsKey(t.slug))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (core.isEmpty) return _fallbackCoreTabs();
    return core.map((t) => _CoreTab(
      slug: t.slug,
      label: t.label,
      meta: _slugMeta[t.slug]!,
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
        meta: _slugMeta[slug]!,
        screen: _screenFor(slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final tabsAsync = ref.watch(tabsProvider);

    final coreTabs = tabsAsync.when(
      data: _buildCoreTabs,
      loading: _fallbackCoreTabs,
      error: (_, __) => _fallbackCoreTabs(),
    );

    final safeIndex = _index.clamp(0, coreTabs.length - 1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        key: appShellKey,
        resizeToAvoidBottomInset: false,
        drawer: _AppSidebar(
          onSwitchTab: _switchTab,
          coreSlugs: coreTabs.map((t) => t.slug).toList(),
          allTabs: tabsAsync.valueOrNull ?? [],
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: IndexedStack(
                    index: safeIndex,
                    children: coreTabs.map((t) => t.screen).toList(),
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
                          setState(() { _index = i; _navVisible = true; });
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 68 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF131920).withValues(alpha: 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(top: BorderSide(color: Color(0xFF1F2D3F), width: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, -4)),
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
                                            active ? AppColors.teal : AppColors.textHint,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : Icon(
                                          active ? tab.meta.filledIcon : tab.meta.outlineIcon,
                                          size: 22,
                                          color: active ? AppColors.teal : AppColors.textHint,
                                        ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: 0,
                                    color: active ? AppColors.teal : AppColors.textHint,
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

  const _AppSidebar({
    required this.onSwitchTab,
    required this.coreSlugs,
    required this.allTabs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final bg = isDark ? context.bg : Colors.white;
    final border = isDark ? context.borderCol : const Color(0xFFE2E8F0);

    // Group all active tabs by section
    final grouped = <String, List<TabConfigModel>>{};
    for (final tab in allTabs) {
      if (!tab.isActive || !tab.allowView) continue;
      final meta = _slugMeta[tab.slug];
      if (meta == null) continue;
      grouped.putIfAbsent(meta.section, () => []).add(tab);
    }

    // Sort tabs within each section by sortOrder
    for (final list in grouped.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return Drawer(
      width: 280,
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Brand header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.favorite_rounded, size: 18, color: AppColors.teal),
                  ),
                  const SizedBox(width: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: 'Medi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: isDark ? context.primaryText : const Color(0xFF1A202C)),
                    ),
                    const TextSpan(
                      text: 'Forze',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal),
                    ),
                  ])),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded, size: 20,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                  ),
                ],
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
                          final meta = _slugMeta[tab.slug]!;
                          final coreIdx = coreSlugs.indexOf(tab.slug);
                          return _SidebarItem(
                            icon: meta.filledIcon,
                            svgIcon: tab.iconSvg,
                            label: tab.label,
                            color: meta.color,
                            onTap: () {
                              if (coreIdx >= 0) {
                                onSwitchTab(coreIdx);
                              } else if (tab.slug == 'feedback') {
                                Scaffold.of(context).closeDrawer();
                                showFeedbackSheet(context);
                              } else {
                                final screen = _pushScreenForSlug(tab.slug);
                                if (screen != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
                                }
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
                  Navigator.pop(context);
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
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(AppStrings.cancel,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(authProvider.notifier).logout();
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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: labelColor),
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.svgIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSvg = svgIcon != null && svgIcon!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.mdAll,
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppBorderRadius.smAll,
              ),
              child: hasSvg
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: SvgPicture.string(
                        svgIcon!,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    )
                  : Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0,
                    color: isDark ? context.primaryText : const Color(0xFF1A202C)),
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
  const _ThemeToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _position;
  late final Animation<Color?> _trackBg;
  late final Animation<Color?> _trackBorder;
  late final Animation<Color?> _thumb;

  static const _offTrack  = Color(0xFF1A2332);
  static const _onTrack   = Color(0x2E4D9EFF);
  static const _offBorder = Color(0xFF1F2D3F);
  static const _onBorder  = AppColors.blue;
  static const _offThumb  = Color(0xFF2A3A4E);
  static const _onThumb   = AppColors.blue;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.value ? 1.0 : 0.0,
    );
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _position    = curved;
    _trackBg     = ColorTween(begin: _offTrack,  end: _onTrack).animate(curved);
    _trackBorder = ColorTween(begin: _offBorder, end: _onBorder).animate(curved);
    _thumb       = ColorTween(begin: _offThumb,  end: _onThumb).animate(curved);
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
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          width: 46, height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: _trackBg.value,
            border: Border.all(color: _trackBorder.value!, width: 1.5),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _position.value * thumbTravel,
                top: 0, bottom: 0,
                child: Center(
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(color: _thumb.value, shape: BoxShape.circle),
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
        ),
      ),
    );
  }
}
