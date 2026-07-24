import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/banner_config.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/graphs/charts.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../professionals/presentation/providers/pro_profile_provider.dart';
import '../../../schedule/data/models/appointment_model.dart' as dash_model;
import '../../../vitals/data/models/vital_reading_model.dart' as vrm;

// ─── Local view models ─────────────────────────────────────────────────────────

enum _DoseStatus { taken, skipped, missed, pending }

class _Dose {
  _Dose({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
  });
  final String id;
  final String name;
  final String time;
  _DoseStatus status;
}

// ─── Adapters ─────────────────────────────────────────────────────────────────

_Dose _toLocalDose(dash_model.TodayDose d) => _Dose(
      id: d.doseTimeId,
      name: d.medicineName,
      time: d.scheduledTime,
      status: d.isTaken
          ? _DoseStatus.taken
          : d.isSkipped
              ? _DoseStatus.skipped
              : _DoseStatus.pending,
    );

Color _dashHexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

({
  String name,
  String timestamp,
  List<({String label, String value, String unit, Color color, List<double> points})>
      chips,
})?
    _latestVital(List<vrm.VitalReading> readings) {
  if (readings.isEmpty) return null;
  final sorted = List<vrm.VitalReading>.from(readings)
    ..sort((a, b) => b.measuredAtDate.compareTo(a.measuredAtDate));
  final latest = sorted.first;
  final history = sorted
      .where((r) => r.vitalConfigId == latest.vitalConfigId)
      .toList()
    ..sort((a, b) => a.measuredAtDate.compareTo(b.measuredAtDate));
  final chips = latest.values.take(3).map((v) {
    final color = _dashHexColor(v.input.color);
    final points = history.map((r) {
      final match = r.values.where((rv) => rv.inputId == v.inputId);
      return match.isEmpty ? v.value : match.first.value;
    }).toList();
    final intV = v.value.toInt();
    final valStr =
        v.value == intV.toDouble() ? '$intV' : v.value.toStringAsFixed(1);
    return (
      label: v.input.label,
      value: valStr,
      unit: v.input.unit,
      color: color,
      points: points,
    );
  }).toList();
  final now = DateTime.now();
  final m = latest.measuredAtDate;
  final isToday =
      m.year == now.year && m.month == now.month && m.day == now.day;
  final hh = m.hour % 12 == 0 ? 12 : m.hour % 12;
  final mm = m.minute.toString().padLeft(2, '0');
  final period = m.hour < 12 ? 'AM' : 'PM';
  final ts = isToday
      ? 'Today, $hh:$mm $period'
      : '${m.month}/${m.day}, $hh:$mm $period';
  return (name: latest.vitalConfig.name, timestamp: ts, chips: chips);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessagingService.requestPermission();
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.goodMorning;
    if (h < 17) return AppStrings.goodAfternoon;
    if (h < 21) return AppStrings.goodEvening;
    return AppStrings.goodNight;
  }

  void _markDose(String id, _DoseStatus s) {
    final apiStatus = s == _DoseStatus.taken
        ? 'TAKEN'
        : s == _DoseStatus.skipped
            ? 'SKIPPED'
            : 'PENDING';
    ref.read(dashboardProvider.notifier).markDose(id, apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(dashboardProvider);
    final isLoading  = state.isLoading;
    final stats      = state.stats;
    final user       = ref.watch(authProvider.select((s) => s.user));
    final isVerifiedPro = ref.watch(proProfileProvider.select((s) => s.profile?.isVerified ?? false));
    final doses      = state.doses.map(_toLocalDose).toList();
    final takenCount = doses.where((d) => d.status == _DoseStatus.taken).length;
    final adherence  = stats != null
        ? stats.adherencePercent.round()
        : doses.isEmpty
            ? 100
            : ((takenCount / doses.length) * 100).round();

    // Show a non-blocking error banner when the dashboard fails to load so the
    // user knows to pull-to-refresh rather than wondering why data is missing.
    if (!isLoading && state.error != null && state.stats == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Dashboard failed to load — pull down to retry'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => ref.read(dashboardProvider.notifier).load(),
          ),
          duration: const Duration(seconds: 6),
        ));
      });
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [

            // ── Greeting app bar ─────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: context.bg,
              pinned: true,
              floating: false,
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              leading: AppIconButton(
                icon: const Icon(Icons.menu_rounded, size: 28),
                onPressed: openAppSidebar,
                tooltip: 'Menu',
                backgroundColor: Colors.transparent,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h3('$_greeting, ${user?.displayName ?? 'there'} 👋'),
                  AppText.bodySm(AppStrings.todayOverview, color: context.secondaryText),
                ],
              ),
              actions: [
                _NotifBell(count: stats?.unreadNotifications ?? 0),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.profile),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AppAvatar(
                      name: user?.displayName ?? '',
                      imageUrl: user?.avatarUrl,
                      isVerified: isVerifiedPro,
                      size: AppAvatarSize.sm,
                    ),
                  ),
                ),
              ],
            ),

            // ── Promo banners ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 18),
                child: Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.98,
                    child: isLoading
                        ? const BannerCarouselSkeleton()
                        : _BannerCarousel(
                            banners: state.banners.isNotEmpty
                                ? state.banners
                                : kFallbackBanners,
                          ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 68 + 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Stat cards ───────────────────────────────────────────
                  Row(children: [
                    Expanded(child: _StatCard(
                      icon: Icons.trending_up_rounded,
                      value: '$adherence%',
                      label: AppStrings.adherenceRate,
                      color: AppColors.teal,
                      subLabel: 'This week',
                      isLoading: isLoading,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      icon: Icons.medication_rounded,
                      value: '${doses.length}',
                      label: 'Doses',
                      color: AppColors.blue,
                      subLabel: '$takenCount taken',
                      isLoading: isLoading,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      icon: Icons.inventory_2_outlined,
                      value: '${stats?.lowStockCount ?? 0}',
                      label: 'Low stock',
                      color: AppColors.amber,
                      subLabel: 'Medicines',
                      isLoading: isLoading,
                    )),
                  ]),
                  const SizedBox(height: 24),

                  // ── Today's medicines ────────────────────────────────────
                  _SectionHeader(
                    title: AppStrings.todayMedicines,
                    subtitle: '$takenCount/${doses.length} ${AppStrings.taken}',
                    onViewAll: () => switchToTab('medicines'),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    AppCard(
                      child: AppSkeleton(
                        child: Column(
                          children: List.generate(4, (_) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AppListTileSkeleton(
                              leadingShape: BoxShape.rectangle,
                              leadingSize: 36,
                              showTrailing: true,
                              padding: EdgeInsets.zero,
                            ),
                          )),
                        ),
                      ),
                    )
                  else if (doses.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: AppText.bodySm(
                            'No medicines scheduled today',
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: List.generate(doses.length, (i) {
                          final d = doses[i];
                          final isLast = i == doses.length - 1;
                          return Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _DoseRow(
                                dose: d,
                                onTake: () => _markDose(d.id, _DoseStatus.taken),
                                onSkip: () => _markDose(d.id, _DoseStatus.skipped),
                              ),
                            ),
                            if (!isLast) Divider(height: 1, color: context.borderCol),
                          ]);
                        }),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ── Recent vitals ────────────────────────────────────────
                  _SectionHeader(title: AppStrings.recentVitals, onViewAll: () => switchToTab('vitals')),
                  const SizedBox(height: 10),
                  if (isLoading)
                    AppCard(
                      child: AppSkeleton(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 120, height: 14, borderRadius: BorderRadius.circular(6)),
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(8))),
                            ]),
                          ],
                        ),
                      ),
                    )
                  else
                    Builder(builder: (context) {
                      final vital = _latestVital(state.recentVitals);
                      if (vital == null) {
                        return AppCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: AppText.bodySm(
                                'No vitals recorded yet',
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        );
                      }
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monitor_heart_outlined, size: 16, color: AppColors.blue),
                                const SizedBox(width: 6),
                                AppText.bodySm(vital.name, fontWeight: FontWeight.w600, color: context.secondaryText),
                                const Spacer(),
                                AppText.bodyXs(vital.timestamp, color: context.secondaryText),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                for (int i = 0; i < vital.chips.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 10),
                                  _VitalChip(
                                    label: vital.chips[i].label,
                                    value: vital.chips[i].value,
                                    unit: vital.chips[i].unit,
                                    color: vital.chips[i].color,
                                    sparkPoints: vital.chips[i].points,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),

                  // ── Quick actions ────────────────────────────────────────
                  _SectionHeader(title: AppStrings.quickActions),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _QuickAction(
                        icon: Icons.medication_outlined,
                        label: AppStrings.addMedicine,
                        subtitle: 'Add to your medicine list',
                        color: AppColors.teal,
                        onTap: () => switchToTab('medicines'),
                      ),
                      _QuickAction(
                        icon: Icons.monitor_heart_outlined,
                        label: AppStrings.addVital,
                        subtitle: 'Record your health',
                        color: AppColors.blue,
                        onTap: () => switchToTab('vitals'),
                      ),
                      _QuickAction(
                        icon: Icons.alarm_add_rounded,
                        label: AppStrings.addDose,
                        subtitle: 'Manage dose schedule',
                        color: AppColors.amber,
                        onTap: () => switchToTab('schedule'),
                      ),
                      _QuickAction(
                        icon: Icons.emergency_outlined,
                        label: AppStrings.sos,
                        subtitle: 'Emergency assistance',
                        color: AppColors.error,
                        onTap: () => switchToTab('emergency'),
                      ),
                    ],
                  ),

                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notification bell ────────────────────────────────────────────────────────

class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          color: context.secondaryText,
          backgroundColor: Colors.transparent,
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        if (count > 0)
          Positioned(
            top: 6, right: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subLabel,
    this.isLoading = false,
  });

  final IconData icon;
  final String   value;
  final String   label;
  final Color    color;
  final String?  subLabel;
  final bool     isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: isLoading
          ? AppSkeleton(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBox(width: 34, height: 34, borderRadius: AppBorderRadius.smAll),
                      const Spacer(),
                      SkeletonBox(width: 44, height: 22, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SkeletonBox(width: 68, height: 10, borderRadius: BorderRadius.circular(5)),
                  const SizedBox(height: 4),
                  SkeletonBox(width: 48, height: 9, borderRadius: BorderRadius.circular(5)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppContainer.tinted(
                      color: color,
                      borderRadius: AppBorderRadius.smAll,
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, size: 17, color: color),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppText.bodyXs(
                  label,
                  color: context.primaryText,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subLabel != null) ...[
                  const SizedBox(height: 1),
                  AppText.bodyXs(
                    subLabel!,
                    color: AppColors.textHint,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
    );
  }
}


// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.onViewAll});
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMd(title, fontWeight: FontWeight.w700),
              if (subtitle != null)
                AppText.bodyXs(subtitle!, color: context.secondaryText),
            ],
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: AppText.bodySm(
              AppStrings.viewAll,
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ─── Dose row ─────────────────────────────────────────────────────────────────

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose, required this.onTake, required this.onSkip});
  final _Dose dose;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (dose.status) {
      _DoseStatus.taken   => (AppColors.green, AppStrings.taken),
      _DoseStatus.skipped => (AppColors.amber, AppStrings.skip),
      _DoseStatus.missed  => (AppColors.error, AppStrings.missed),
      _DoseStatus.pending => (AppColors.textHint, AppStrings.pending),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AppContainer.tinted(
            color: AppColors.teal,
            borderRadius: AppBorderRadius.smAll,
            padding: const EdgeInsets.all(9),
            child: const Icon(Icons.medication_rounded, size: 18, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySm(dose.name, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    AppText.bodyXs(dose.time, color: context.secondaryText),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (dose.status == _DoseStatus.pending) ...[
            _ActionBtn(Icons.check_rounded, AppColors.green, onTake),
            const SizedBox(width: 6),
            _ActionBtn(Icons.close_rounded, AppColors.amber, onSkip),
          ] else
            AppContainer.tinted(
              color: statusColor,
              borderRadius: AppBorderRadius.pill,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: AppText.labelXs(statusLabel, color: statusColor, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(this.icon, this.color, this.onTap);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppContainer.tinted(
        color: color,
        borderRadius: AppBorderRadius.smAll,
        padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

// ─── Vital chip (with sparkline) ──────────────────────────────────────────────

class _VitalChip extends StatelessWidget {
  const _VitalChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.sparkPoints,
  });

  final String       label;
  final String       value;
  final String       unit;
  final Color        color;
  final List<double> sparkPoints;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelXs(label, color: context.secondaryText, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: TextStyle(
                            fontSize: 9,
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            MiniSparkline(
              points: sparkPoints,
              color: color,
              height: 30,
              strokeWidth: 1.5,
              filled: true,
              fillOpacity: 0.22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick action button ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          AppContainer.tinted(
            color: color,
            borderRadius: AppBorderRadius.smAll,
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.bodySm(label, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                AppText.bodyXs(subtitle, color: context.secondaryText, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Banner carousel ──────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.banners});
  final List<DashboardBanner> banners;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _ctrl;
  late final Timer _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl  = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % widget.banners.length;
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 1,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _BannerCard(
                  banner: widget.banners[i],
                  fallback: kFallbackBanners[i % kFallbackBanners.length],
                ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 5),
                width: active ? 20 : 6, height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal
                      : AppColors.teal.withValues(alpha: 0.25),
                  borderRadius: AppBorderRadius.pill,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.fallback});
  final DashboardBanner banner;
  final DashboardBanner fallback;

  @override
  Widget build(BuildContext context) {
    if (banner.isGradient) return _GradientBanner(banner: banner);
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: AppBorderRadius.smAll,
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(
            color: context.inputBg,
            child: const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => _GradientBanner(banner: fallback),
        ),
      ),
    );
  }
}

class _GradientBanner extends StatelessWidget {
  const _GradientBanner({required this.banner});
  final DashboardBanner banner;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: AppBorderRadius.smAll,
        child: Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                banner.gradientStart ?? AppColors.teal.withValues(alpha: 0.8),
                banner.gradientEnd   ?? const Color(0xFF0D2137),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (banner.title != null)
                      AppText.labelMd(
                        banner.title!,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 3),
                      AppText.bodyXs(
                        banner.subtitle!,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
