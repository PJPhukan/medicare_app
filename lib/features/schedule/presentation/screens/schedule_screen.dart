import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/reminder_schedule_model.dart';
import '../models/presentation_dose.dart';
import '../providers/reminders_provider.dart';
import '../providers/schedule_provider.dart';
import '../utils/dose_mapper.dart';
import '../widgets/add_dose_sheet.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/manage_schedules_sheet.dart';
import '../widgets/schedule_date_strip.dart';
import '../widgets/schedule_group_section.dart';
import '../widgets/schedule_row.dart';
import '../widgets/schedule_summary_chips.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, this.standalone = false});

  /// True when pushed as its own route (e.g. the `/schedule` fallback used
  /// when the tab isn't currently in the bottom nav) rather than shown as a
  /// core tab inside [AppShell]. Embedded, the default "menu" leading opens
  /// the shell's drawer correctly; standalone, that same Scaffold sits
  /// underneath this pushed route so the drawer would open invisibly — use
  /// a back button instead.
  final bool standalone;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).load();
    });
  }

  void _onDateSelected(DateTime date) {
    if (DateFormatter.isSameDay(_selectedDate, date)) return;
    setState(() => _selectedDate = date);
    ref.read(scheduleProvider.notifier).load(date: date);
  }

  void _onMonthChanged(DateTime visibleMonth) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    setState(() => _selectedDate = firstDay);
    ref.read(scheduleProvider.notifier).load(date: firstDay);
  }

  Future<void> _markDose(String doseTimeId, DoseStatus status) async {
    final statusStr = status == DoseStatus.taken ? 'TAKEN' : 'SKIPPED';
    
    if (status == DoseStatus.taken) {
      CelebrationOverlay.show(context);
    }

    try {
      await ref.read(scheduleProvider.notifier).markDose(doseTimeId, statusStr);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not update dose: ${e.toString()}');
    }
  }

  Future<void> _openAddDose() async {
    final input = await showAddDoseSheet(context);
    if (input == null || !mounted) return;

    final dose = parseDoseAmount(input.unit);
    try {
      await ref.read(remindersProvider.notifier).createSchedule(
            medicineName: input.name,
            time: input.time,
            unit: dose.unit ?? input.unit,
            quantity: dose.quantity ?? 1,
            foodTiming: switch (input.foodTiming) {
              DoseFoodTiming.before => 'BEFORE',
              DoseFoodTiming.with_ => 'WITH',
              DoseFoodTiming.after => 'AFTER',
            },
            scheduleType: apiScheduleType(input.repeat),
            endDate: input.endDate,
          );
      if (!mounted) return;
      await ref.read(scheduleProvider.notifier).load(date: _selectedDate);
      if (mounted) AppSnackbar.success(context, AppStrings.doseAdded);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Could not add dose: ${e.toString()}');
      }
    }
  }

  void _openManageSchedules() {
    showManageSchedulesSheet(context);
  }

  String _fmtSelectedDateHeader(DateTime d) {
    if (DateFormatter.isSameDay(d, DateTime.now())) return 'Today';
    return DateFormatter.weekdayMonthDay(d);
  }

  @override
  Widget build(BuildContext context) {
    // Single provider watch as single source of truth
    final scheduleState = ref.watch(scheduleProvider);
    final textColor = context.primaryText;
    final secondaryColor = context.secondaryText;

    // Convert domain doses to presentation doses
    final doses = scheduleState.doses.map((d) => d.toPresentation()).toList();

    // Group doses by time group
    final groupedDoses = <DoseTimeGroup, List<PresentationDose>>{
      for (final g in DoseTimeGroup.values) g: [],
    };
    for (final d in doses) {
      groupedDoses[d.group]?.add(d);
    }

    final totalCount = doses.length;
    final takenCount = doses.where((d) => d.status == DoseStatus.taken).length;
    final skippedCount = doses.where((d) => d.status == DoseStatus.skipped).length;

    final failedToLoad =
        scheduleState.error != null && !scheduleState.isLoading && doses.isEmpty;

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(scheduleProvider.notifier).load(date: _selectedDate),
        child: CustomScrollView(
          slivers: [
            // AppBar
            AppSliverAppBar(
              config: AppBarConfig(
                title: AppStrings.schedule,
                subtitle: "Manage your medication schedule",
                leading: widget.standalone ? AppBarLeading.back : AppBarLeading.menu,
                actions: [
                  AppIconButton(
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 20,
                    size: 36,
                    color: textColor,
                    borderColor: context.borderCol,
                    backgroundColor: context.cardBg,
                    borderRadius: AppBorderRadius.mdAll,
                    onPressed: _openManageSchedules,
                    tooltip: 'Manage schedules',
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    icon: const Icon(Icons.add_rounded),
                    iconSize: 20,
                    size: 36,
                    color: Colors.white,
                    backgroundColor: AppColors.teal,
                    borderColor: AppColors.teal,
                    borderRadius: AppBorderRadius.mdAll,
                    onPressed: _openAddDose,
                    tooltip: AppStrings.addDose,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Date Strip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: ScheduleDateStrip(
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateSelected,
                  onMonthChanged: _onMonthChanged,
                ),
              ),
            ),

            // Offline / Sync warning banner if offline
            if (scheduleState.isOffline)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: OfflineBanner(),
                ),
              ),

            // Summary chips
            SliverToBoxAdapter(
              child: ScheduleSummaryChips(
                totalCount: totalCount,
                takenCount: takenCount,
                skippedCount: skippedCount,
              ),
            ),

            // Dose List Body
            if (failedToLoad)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.calendar_today_rounded,
                    title: 'Could not load schedule',
                    subtitle: scheduleState.error,
                    actionLabel: 'Retry',
                    action: () =>
                        ref.read(scheduleProvider.notifier).load(date: _selectedDate),
                  ),
                ),
              )
            else if (scheduleState.isLoading && doses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppCardSkeleton(height: 70),
                      SizedBox(height: 12),
                      AppCardSkeleton(height: 70),
                      SizedBox(height: 12),
                      AppCardSkeleton(height: 70),
                    ],
                  ),
                ),
              )
            else if (doses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: AppEmptyStateText(
                    icon: Icons.calendar_today_rounded,
                    title: 'No doses scheduled',
                    subtitle: 'No doses scheduled for this date.',
                    actionLabel: AppStrings.addDose,
                    onAction: _openAddDose,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  for (final group in DoseTimeGroup.values)
                    if ((groupedDoses[group] ?? []).isNotEmpty)
                      ScheduleGroupSection(
                        group: group,
                        doses: groupedDoses[group]!,
                        onMark: (id, status) => _markDose(id, status),
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                      ),
                  const SizedBox(height: 32),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
