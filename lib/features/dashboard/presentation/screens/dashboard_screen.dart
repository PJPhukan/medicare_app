import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/time_format.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/widgets.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../professionals/presentation/providers/pro_profile_provider.dart';
import '../../../vitals/data/models/vital_reading_model.dart' as vrm;

({
  String name,
  String timestamp,
  List<
      ({
        String label,
        String value,
        String unit,
        Color color,
        List<double> points
      })> chips,
})? _latestVital(List<vrm.VitalReading> readings) {
  if (readings.isEmpty) return null;
  final sorted = List<vrm.VitalReading>.from(readings)
    ..sort((a, b) => b.measuredAtDate.compareTo(a.measuredAtDate));
  final latest = sorted.first;
  final history = sorted
      .where((r) => r.vitalConfigId == latest.vitalConfigId)
      .toList()
      .reversed
      .toList();
  final chips = latest.values.take(3).map((v) {
    final color = hexToColor(v.input.color);
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
  final isToday = DateFormatter.isSameDay(m, now);
  final timeStr = formatTime12hDt(m);
  final ts = isToday ? 'Today, $timeStr' : '${m.month}/${m.day}, $timeStr';
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

  void _markDose(String id, DoseStatus s) {
    final apiStatus = s == DoseStatus.taken
        ? 'TAKEN'
        : s == DoseStatus.skipped
            ? 'SKIPPED'
            : 'PENDING';
    ref.read(dashboardProvider.notifier).markDose(id, apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isLoading = state.isLoading;
    final stats = state.stats;
    final isFirstLoad = isLoading && stats == null;
    final user = ref.watch(authProvider.select((s) => s.user));
    final isVerifiedPro = ref.watch(
        proProfileProvider.select((s) => s.profile?.isVerified ?? false));
    final doses = state.doses.map(toLocalDose).toList();
    final totalDoseCount = stats?.todayDoseCount ?? doses.length;
    final takenCount = stats?.takenCount ??
        doses.where((d) => d.status == DoseStatus.taken).length;
    final adherence = stats != null
        ? stats.adherencePercent.round()
        : totalDoseCount == 0
            ? 100
            : ((takenCount / totalDoseCount) * 100).round();

    ref.listen<String?>(dashboardProvider.select((s) => s.error), (prev, next) {
      if (next != null && ref.read(dashboardProvider).stats == null) {
        AppSnackbar.show(
          context,
          message: AppStrings.dashboardLoadFailed,
          type: AppSnackbarType.error,
          actionLabel: 'Retry',
          onAction: () => ref.read(dashboardProvider.notifier).load(),
          duration: const Duration(seconds: 2),
        );
      }
    });

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [
            // ── Greeting app bar ─────────────────────────────────────────────
            AppSliverAppBar(
              config: AppBarConfig(
                title:
                    '$_greeting, ${user?.greetingName ?? AppStrings.there} 👋',
                subtitle: AppStrings.todayOverview,
                actions: [
                  NotifBell(count: stats?.unreadNotifications ?? 0),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.settings),
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
            ),

            // ── Promo banners ────────────────────────────────────────────────
            if (isFirstLoad || state.banners.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 18),
                  child: Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 0.98,
                      child: isFirstLoad
                          ? const BannerCarouselSkeleton()
                          : BannerCarousel(banners: state.banners),
                    ),
                  ),
                ),
              ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).padding.bottom + 68 + 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Hero adherence card ──────────────────────────────────
                  HeroAdherenceCard(
                    percent: adherence,
                    taken: takenCount,
                    total: totalDoseCount,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 10),

                  // ── Supporting stats ─────────────────────────────────────

                  Row(children: [
                    Expanded(
                        child: DashboardStatCard(
                      icon: Icons.medication_rounded,
                      value: '$totalDoseCount',
                      label: AppStrings.dosesLabel,
                      color: AppColors.blue,
                      subLabel: '$takenCount ${AppStrings.dosesTakenSuffix}',
                      isLoading: isLoading,
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: DashboardStatCard(
                      icon: Icons.inventory_2_outlined,
                      value: '${stats?.lowStockCount ?? 0}',
                      label: AppStrings.lowStock,
                      color: AppColors.amber,
                      subLabel: AppStrings.medicines,
                      isLoading: isLoading,
                    )),
                  ]),
                  const SizedBox(height: 24),

                  // ── Today's medicines ────────────────────────────────────
                  AppSectionHeaderText(
                    title: AppStrings.todayMedicines,
                    subtitle: '$takenCount/$totalDoseCount ${AppStrings.taken}',
                    padding: EdgeInsets.zero,
                    actionLabel: AppStrings.viewAll,
                    onAction: () => switchToTab('medicines'),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    AppCard(
                      child: AppSkeleton(
                        child: Column(
                          children: List.generate(
                              4,
                              (_) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
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
                      child: AppEmptyStateText(
                        compact: true,
                        // icon: Icons.medication_outlined,
                        title: AppStrings.noDosesToday,
                        subtitle: AppStrings.noDosesTodayHint,
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final d in doses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DoseRow(
                              dose: d,
                              onTake: () => _markDose(d.id, DoseStatus.taken),
                              onSkip: () => _markDose(d.id, DoseStatus.skipped),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // ── Recent vitals ────────────────────────────────────────
                  AppSectionHeaderText(
                    title: AppStrings.recentVitals,
                    padding: EdgeInsets.zero,
                    actionLabel: AppStrings.viewAll,
                    onAction: () => switchToTab('vitals'),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    AppCard(
                      child: AppSkeleton(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                                width: 120,
                                height: 14,
                                borderRadius: BorderRadius.circular(6)),
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(
                                  child: SkeletonBox(
                                      height: 80,
                                      borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: SkeletonBox(
                                      height: 80,
                                      borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: SkeletonBox(
                                      height: 80,
                                      borderRadius: BorderRadius.circular(8))),
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
                          child: AppEmptyStateText(
                            compact: true,
                            icon: Icons.monitor_heart_outlined,
                            title: AppStrings.noVitalsYet,
                            subtitle: AppStrings.noVitalsYetHint,
                            accentColor: AppColors.blue,
                          ),
                        );
                      }
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monitor_heart_outlined,
                                    size: 16, color: AppColors.blue),
                                const SizedBox(width: 6),
                                AppText.bodySm(vital.name,
                                    fontWeight: FontWeight.w600,
                                    color: context.secondaryText),
                                const Spacer(),
                                AppText.bodyXs(vital.timestamp,
                                    color: context.secondaryText),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                for (int i = 0;
                                    i < vital.chips.length;
                                    i++) ...[
                                  if (i > 0) const SizedBox(width: 10),
                                  VitalChip(
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
                  AppSectionHeaderText(
                    title: AppStrings.quickActions,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      QuickAction(
                        icon: Icons.medication_outlined,
                        label: AppStrings.addMedicine,
                        subtitle: AppStrings.addMedicineHint,
                        color: AppColors.teal,
                        onTap: () => switchToTab('medicines'),
                      ),
                      QuickAction(
                        icon: Icons.monitor_heart_outlined,
                        label: AppStrings.addVital,
                        subtitle: AppStrings.addVitalHint,
                        color: AppColors.blue,
                        onTap: () => switchToTab('vitals'),
                      ),
                      QuickAction(
                        icon: Icons.alarm_add_rounded,
                        label: AppStrings.addDose,
                        subtitle: AppStrings.addDoseHint,
                        color: AppColors.amber,
                        onTap: () => switchToTab('schedule'),
                      ),
                      QuickAction(
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
