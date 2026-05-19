import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
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
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../../patients/presentation/screens/patients_screen.dart';
import '../../../caretakers/presentation/screens/caretakers_screen.dart';
import '../../../support/presentation/screens/support_screen.dart';
import '../../../professional_profile/presentation/screens/pro_hub_screen.dart';
import '../../../../shared/widgets/feedback_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _navVisible = true;

  void _switchTab(int index) {
    appShellKey.currentState?.closeDrawer();
    setState(() {
      _index = index;
      _navVisible = true;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 4 && _navVisible) {
        setState(() => _navVisible = false);
      } else if (delta < -4 && !_navVisible) {
        setState(() => _navVisible = true);
      }
    } else if (notification is ScrollEndNotification) {
      final px = notification.metrics.pixels;
      if (px <= 0 && !_navVisible) {
        setState(() => _navVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        key: appShellKey,
        resizeToAvoidBottomInset: false,
        drawer: _AppSidebar(onSwitchTab: _switchTab),
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: IndexedStack(
                index: _index,
                children: const [
                  DashboardScreen(),
                  MedicinesScreen(),
                  VitalsScreen(),
                  ProfessionalsScreen(),
                  MessageScreen(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: _navVisible ? Offset.zero : const Offset(0, 2.0),
                duration: Duration(milliseconds: _navVisible ? 380 : 280),
                curve: _navVisible ? Curves.easeOutCubic : Curves.easeInQuart,
                child: AnimatedOpacity(
                  opacity: _navVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: _navVisible ? 300 : 200),
                  child: _BottomNav(
                    selectedIndex: _index,
                    bottomPadding: bottomInset,
                    onTap: (i) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _index = i;
                        _navVisible = true;
                      });
                    },
                  ),
                ),
              ),
            ),
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

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  // Schedule removed — still in sidebar; these 5 are daily-use essentials.
  static const _items = [
    (Icons.home_outlined,              Icons.home_rounded,          AppStrings.tabHome),
    (Icons.medication_outlined,         Icons.medication_rounded,    AppStrings.tabMedicines),
    (Icons.monitor_heart_outlined,      Icons.monitor_heart_rounded, AppStrings.tabVitals),
    (Icons.people_outline_rounded,      Icons.people_rounded,        AppStrings.tabProfessionals),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded,   AppStrings.tabMessages),
  ];

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
            border: const Border(
              top: BorderSide(color: Color(0xFF1F2D3F), width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (_, box) {
              final count = _items.length;
              final slotW = box.maxWidth / count;
              final lineW = slotW * 0.55;
              final coneW = slotW * 0.85;

              return Stack(
                children: [
                  // Soft teal gradient cone from top edge downward
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: slotW * selectedIndex + (slotW - coneW) / 2,
                    top: 0,
                    width: coneW,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.teal.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // Thin teal strip at the very top
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: slotW * selectedIndex + (slotW - lineW) / 2,
                    top: 0,
                    width: lineW,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.teal.withValues(alpha: 0.90),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.65),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nav items
                  Row(
                    children: List.generate(count, (i) {
                      final active = i == selectedIndex;
                      final item = _items[i];
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
                                  builder: (_, scale, child) =>
                                      Transform.scale(scale: scale, child: child),
                                  child: Icon(
                                    active ? item.$2 : item.$1,
                                    size: 22,
                                    color: active
                                        ? AppColors.teal
                                        : AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: AppTypography.labelXs.copyWith(
                                    fontSize: 10,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    letterSpacing: 0,
                                    color: active
                                        ? AppColors.teal
                                        : AppColors.textHint,
                                  ),
                                  child: Text(item.$3),
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
  const _AppSidebar({required this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final bg = isDark ? context.bg : Colors.white;
    final border = isDark ? context.borderCol : const Color(0xFFE2E8F0);

    return Drawer(
      width: 280,
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Brand header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        size: 18, color: AppColors.teal),
                  ),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Medi',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? context.primaryText
                                : const Color(0xFF1A202C),
                          ),
                        ),
                        TextSpan(
                          text: 'Forze',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            // ── Nav items ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  // ── Overview ──────────────────────────────────────────────
                  _SidebarSection(
                    label: 'Overview',
                    isDark: isDark,
                    border: border,
                    items: [
                      _SidebarItem(
                        icon: Icons.home_rounded,
                        label: AppStrings.tabHome,
                        color: AppColors.teal,
                        onTap: () => onSwitchTab(0),
                      ),
                      _SidebarItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        color: AppColors.blue,
                        onTap: () => _push(context, const ProfileScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.medication_rounded,
                        label: AppStrings.tabMedicines,
                        color: AppColors.green,
                        onTap: () => onSwitchTab(1),
                      ),
                      _SidebarItem(
                        icon: Icons.alarm_rounded,
                        label: 'Reminders',
                        color: AppColors.amber,
                        onTap: () => _push(context, const RemindersScreen()),
                      ),
                    ],
                  ),

                  // ── Health ────────────────────────────────────────────────
                  _SidebarSection(
                    label: 'Health',
                    isDark: isDark,
                    border: border,
                    items: [
                      _SidebarItem(
                        icon: Icons.calendar_today_rounded,
                        label: AppStrings.tabSchedule,
                        color: AppColors.blue,
                        onTap: () => _push(context, const ScheduleScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.monitor_heart_rounded,
                        label: AppStrings.tabVitals,
                        color: AppColors.red,
                        onTap: () => onSwitchTab(2),
                      ),
                      _SidebarItem(
                        icon: Icons.description_rounded,
                        label: 'Reports',
                        color: AppColors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.folder_open_rounded,
                        label: 'Documents',
                        color: AppColors.amber,
                        onTap: () => _push(context, const DocumentsScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.event_rounded,
                        label: 'Appointments',
                        color: AppColors.teal,
                        onTap: () => _push(context, const ScheduleScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Prescriptions',
                        color: AppColors.green,
                        onTap: () => _push(context, const PrescriptionsScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.insights_rounded,
                        label: AppStrings.tabInsights,
                        color: AppColors.purple,
                        onTap: () => _push(context, const InsightsScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.people_rounded,
                        label: AppStrings.tabProfessionals,
                        color: AppColors.teal,
                        onTap: () => onSwitchTab(3),
                      ),
                      _SidebarItem(
                        icon: Icons.notifications_active_rounded,
                        label: AppStrings.tabAlerts,
                        color: AppColors.red,
                        badge: 2,
                        onTap: () => _push(context, const AlertsScreen()),
                      ),
                    ],
                  ),

                  // ── Emergency ─────────────────────────────────────────────
                  _SidebarSection(
                    label: 'Emergency',
                    isDark: isDark,
                    border: border,
                    isDanger: true,
                    items: [
                      _SidebarItem(
                        icon: Icons.emergency_rounded,
                        label: 'Emergency',
                        color: AppColors.red,
                        onTap: () => _push(context, const EmergencyScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.contact_emergency_rounded,
                        label: 'Emergency Contacts',
                        color: AppColors.red,
                        onTap: () => _push(context, const EmergencyScreen()),
                      ),
                    ],
                  ),

                  // ── People & Care ─────────────────────────────────────────
                  _SidebarSection(
                    label: 'People & Care',
                    isDark: isDark,
                    border: border,
                    items: [
                      _SidebarItem(
                        icon: Icons.people_alt_rounded,
                        label: 'Patients',
                        color: AppColors.teal,
                        onTap: () => _push(context, const PatientsScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.supervisor_account_rounded,
                        label: 'Caretakers',
                        color: AppColors.blue,
                        onTap: () => _push(context, const CaretakersScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.sticky_note_2_rounded,
                        label: AppStrings.myNotes,
                        color: AppColors.amber,
                        onTap: () => _push(context, const NotesScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.chat_bubble_rounded,
                        label: AppStrings.tabMessages,
                        color: AppColors.green,
                        onTap: () => onSwitchTab(4),
                      ),
                      _SidebarItem(
                        icon: Icons.settings_rounded,
                        label: AppStrings.settings,
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                        onTap: () => _push(context, const SettingsScreen()),
                      ),
                    ],
                  ),

                  // ── My Professional ───────────────────────────────────────
                  _SidebarSection(
                    label: 'My Professional',
                    isDark: isDark,
                    border: border,
                    items: [
                      _SidebarItem(
                        icon: Icons.badge_rounded,
                        label: 'Professional Profile',
                        color: AppColors.purple,
                        onTap: () => _push(context, const ProHubScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.group_rounded,
                        label: 'Connections',
                        color: AppColors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionsScreen()));
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.person_add_rounded,
                        label: 'Requests',
                        color: AppColors.teal,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionsScreen()));
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.send_rounded,
                        label: 'My Requests',
                        color: AppColors.amber,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionsScreen()));
                        },
                      ),
                    ],
                  ),

                  // ── Help & Support ────────────────────────────────────────
                  _SidebarSection(
                    label: 'Help & Support',
                    isDark: isDark,
                    border: border,
                    items: [
                      _SidebarItem(
                        icon: Icons.help_rounded,
                        label: 'Help',
                        color: AppColors.blue,
                        onTap: () => _push(context, const SupportScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.headset_mic_rounded,
                        label: 'Support',
                        color: AppColors.teal,
                        onTap: () => _push(context, const SupportScreen()),
                      ),
                      _SidebarItem(
                        icon: Icons.rate_review_rounded,
                        label: 'Feedback',
                        color: AppColors.green,
                        onTap: () {
                          Scaffold.of(context).closeDrawer();
                          showFeedbackSheet(context);
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.privacy_tip_rounded,
                        label: 'Privacy',
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                        onTap: () => _push(context, const SupportScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Theme toggle ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: border))),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.10),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 16,
                    color: AppColors.blue,
                  ),
                ),
                title: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: AppTypography.labelMd.copyWith(
                    color: isDark
                        ? context.primaryText
                        : const Color(0xFF1A202C),
                    letterSpacing: 0,
                  ),
                ),
                trailing: _ThemeToggle(
                  value: themeMode == ThemeMode.dark ||
                      (themeMode == ThemeMode.system && isDark),
                  onChanged: (on) {
                    ref.read(themeModeProvider.notifier).state =
                        on ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
            ),

            // ── Sign out ──────────────────────────────────────────────────────
            Container(
              decoration:
                  BoxDecoration(border: Border(top: BorderSide(color: border))),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.10),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: const Icon(Icons.logout_rounded,
                      size: 16, color: AppColors.red),
                ),
                title: Text('Sign Out',
                    style: AppTypography.labelMd.copyWith(
                        color: AppColors.red, letterSpacing: 0)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor:
                          isDark ? context.cardBg : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.lgAll),
                      title: Text('Sign Out', style: AppTypography.h3),
                      content: Text('Are you sure you want to sign out?',
                          style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(AppStrings.cancel,
                              style: AppTypography.buttonMd
                                  .copyWith(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Sign Out',
                              style: AppTypography.buttonMd
                                  .copyWith(color: AppColors.red)),
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

  void _push(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
                Icon(Icons.warning_amber_rounded,
                    size: 11, color: AppColors.red.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
              ],
              Text(
                label.toUpperCase(),
                style: AppTypography.overline.copyWith(
                  color: labelColor,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
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
  final int? badge;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppBorderRadius.smAll,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: isDark
                      ? context.primaryText
                      : const Color(0xFF1A202C),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (badge != null && badge! > 0)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badge',
                  style: AppTypography.labelXs.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

  // Fixed colors so the toggle itself doesn't snap when theme rebuilds
  static const _offTrack   = Color(0xFF1A2332); // dark700 equivalent
  static const _onTrack    = Color(0x2E4D9EFF); // blue 18%
  static const _offBorder  = Color(0xFF1F2D3F); // dark600
  static const _onBorder   = AppColors.blue;
  static const _offThumb   = Color(0xFF2A3A4E); // dark500
  static const _onThumb    = AppColors.blue;

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
    // thumb travels: track(46) - padding(3×2) - thumb(18) = 22 px
    const thumbTravel = 22.0;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          width: 46,
          height: 26,
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
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _thumb.value,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        widget.value
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
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
