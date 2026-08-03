import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/graphs/graphs.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../../schedule/data/models/reminder_schedule_model.dart';
import '../../../schedule/presentation/providers/reminders_provider.dart';
import '../../../schedule/presentation/widgets/add_dose_sheet.dart';
import '../../../schedule/presentation/widgets/schedule_row.dart';
import '../providers/medicines_provider.dart';
import 'add_stock_sheet.dart';
import 'dose_time_card.dart';
import 'reassign_patient_sheet.dart';
import 'medicine_status.dart';

/// Opens the full detail sheet for one cabinet entry.
Future<void> showMedicineDetailSheet(
  BuildContext context,
  UserMedicineEntity medicine,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MedicineDetailSheet(medicine: medicine),
  );
}

/// Tabbed detail view. Uses [DraggableScrollableSheet] rather than
/// [AppBottomSheet] because the tab bar needs a fixed header above a
/// full-height scrolling body, which the shared sheet's single scroll view
/// can't express.
class MedicineDetailSheet extends ConsumerStatefulWidget {
  const MedicineDetailSheet({super.key, required this.medicine});

  final UserMedicineEntity medicine;

  @override
  ConsumerState<MedicineDetailSheet> createState() =>
      _MedicineDetailSheetState();
}

class _MedicineDetailSheetState extends ConsumerState<MedicineDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _confirmRemove() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.removeMedicineTitle,
      message: AppStrings.removeMedicineDesc,
      confirmLabel: AppStrings.remove,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    context.pop();
    try {
      await ref
          .read(medicinesProvider.notifier)
          .deleteMedicine(widget.medicine.id);
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.medicineDeleted);
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-read the entry from the provider each build: editing the schedule
    // refetches the cabinet, and the widget's copy is a snapshot from the
    // moment the sheet opened. Falls back to that snapshot if the entry is
    // gone (mid-delete, before the sheet closes).
    final m = ref
        .watch(medicinesProvider)
        .medicines
        .cast<UserMedicineEntity>()
        .firstWhere(
          (e) => e.id == widget.medicine.id,
          orElse: () => widget.medicine,
        );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.topXxl,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerCol,
                borderRadius: AppBorderRadius.pill,
              ),
            ),
            const SizedBox(height: 12),
            _Header(medicine: m),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.borderCol)),
              ),
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0),
                labelColor: AppColors.teal,
                // context.secondaryText, not the raw constant — TabBar takes
                // a literal Color, not a Text style AppText could adapt, so
                // every unselected tab label (Description/Side
                // effects/Contraindications/Details) rendered near-invisible
                // in light mode.
                unselectedLabelColor: context.secondaryText,
                indicatorColor: AppColors.teal,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Doses'),
                  Tab(text: 'Description'),
                  Tab(text: 'Side effects'),
                  Tab(text: 'Contraindications'),
                  Tab(text: 'Details'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _DosesTab(
                      medicine: m, controller: ctrl, onRemove: _confirmRemove),
                  _DescriptionTab(medicine: m, controller: ctrl),
                  _ListTab(
                    controller: ctrl,
                    title: 'Side effects',
                    items: m.sideEffects,
                    icon: Icons.healing_rounded,
                    accent: AppColors.amber,
                  ),
                  _ContraindicationsTab(medicine: m, controller: ctrl),
                  _DetailsTab(medicine: m, controller: ctrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.medicine});

  final UserMedicineEntity medicine;

  @override
  Widget build(BuildContext context) {
    final color = medicine.status.color;
    final subtitle = [medicine.genericName, medicine.strength]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppListTile(
            padding: EdgeInsets.zero,
            leading:
                MedicineTypeIcon(type: medicine.form, size: 52, color: color),
            title: medicine.displayName,
            subtitle: subtitle.isEmpty ? null : subtitle,
            trailing: MedicineStatusBadge(medicine.status),
          ),
          if (medicine.isShared) ...[
            const SizedBox(height: 12),
            _NoteCard(
              icon: medicine.isSharedMaster
                  ? Icons.share_rounded
                  : Icons.person_add_rounded,
              color: color,
              message: medicine.isSharedMaster
                  ? 'Shared bottle — stock is split with other patients.'
                  : 'Stock is managed by your caretaker.',
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Doses ───────────────────────────────────────────────────────────────────

/// Everything about *this user's* use of the medicine, and the only tab that
/// writes: who it is for, the recurring schedules, and the stock.
///
/// Reads schedules from [remindersProvider] rather than the entity's embedded
/// `doseSchedules` — that snapshot comes from `/medicines/me` and carries no
/// schedule ids, which toggling and deleting both need.
class _DosesTab extends ConsumerWidget {
  const _DosesTab({
    required this.medicine,
    required this.controller,
    required this.onRemove,
  });

  final UserMedicineEntity medicine;
  final ScrollController controller;
  final VoidCallback onRemove;

  Future<void> _addSchedule(BuildContext context, WidgetRef ref) async {
    final input =
        await showAddDoseSheet(context, medicineName: medicine.displayName);
    if (input == null || !context.mounted) return;
    final dose = parseDoseAmount(input.unit);
    try {
      await ref.read(remindersProvider.notifier).createSchedule(
            // Linking by id keeps the reminder on this cabinet entry instead
            // of spawning a second, catalog-less one from the name.
            userMedicineId: medicine.id,
            medicineName: medicine.displayName,
            time: input.time,
            quantity: dose.quantity ?? 1,
            unit: dose.unit ?? input.unit,
            foodTiming: switch (input.foodTiming) {
              DoseFoodTiming.before => 'BEFORE',
              DoseFoodTiming.with_ => 'WITH',
              DoseFoodTiming.after => 'AFTER',
            },
            scheduleType: _toApiScheduleType(input.repeat),
            endDate: input.endDate,
          );
      if (!context.mounted) return;
      AppSnackbar.success(context, AppStrings.doseAdded);
      // The cabinet cards render dose times from /medicines/me, a different
      // endpoint, so they need a refetch to catch up.
      await ref.read(medicinesProvider.notifier).load();
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.toString());
    }
  }

  /// Opens the edit sheet for ONE dose time.
  ///
  /// The PATCH replaces the schedule's dose-time list, so the untouched times
  /// must be sent back with their ids or the server would treat them as
  /// removed — and removing a dose time cascades its DoseLog history away.
  Future<void> _editDose(
    BuildContext context,
    WidgetRef ref,
    ReminderScheduleModel schedule,
    ReminderDoseTime doseTime,
  ) async {
    final input = await showAddDoseSheet(
      context,
      medicineName: medicine.displayName,
      isActive: schedule.isActive,
      onToggleActive: (_) =>
          toggleScheduleWithFeedback(context, ref, schedule.id),
      onDelete: () => _deleteDose(context, ref, schedule, doseTime),
      initial: DoseInput(
        name: medicine.displayName,
        time: doseTime.scheduledTime,
        unit: doseTime.unit ?? '',
        foodTiming: switch (doseTime.foodTiming?.toUpperCase()) {
          'BEFORE' => DoseFoodTiming.before,
          'WITH' => DoseFoodTiming.with_,
          _ => DoseFoodTiming.after,
        },
        repeat: _toAppRepeat(schedule.scheduleType),
        durationDays: schedule.daysRemaining,
      ),
    );
    if (input == null || !context.mounted) return;

    final dose = parseDoseAmount(input.unit);
    // Only the edited row changes; the others go back exactly as they were,
    // so their amounts aren't overwritten with this dose's.
    final edited = [
      for (final dt in schedule.doseTimes)
        dt.id == doseTime.id
            ? DoseTimeEdit.from(dt).copyWith(
                scheduledTime: input.time,
                quantity: dose.quantity ?? 1,
                unit: dose.unit ?? input.unit,
                foodTiming: switch (input.foodTiming) {
                  DoseFoodTiming.before => 'BEFORE',
                  DoseFoodTiming.with_ => 'WITH',
                  DoseFoodTiming.after => 'AFTER',
                },
              )
            : DoseTimeEdit.from(dt),
    ];

    try {
      await ref.read(remindersProvider.notifier).updateSchedule(
            id: schedule.id,
            doseTimes: edited,
            scheduleType: _toApiScheduleType(input.repeat),
            endDate: input.endDate,
            clearEndDate: input.durationDays == null,
          );
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Dose updated');
      await ref.read(medicinesProvider.notifier).load();
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.toString());
    }
  }

  /// Removes one dose time. When it is the schedule's last one the whole
  /// schedule goes instead — the backend rejects a non-PRN schedule with no
  /// dose times, and an empty schedule would be invisible but still stored.
  Future<void> _deleteDose(
    BuildContext context,
    WidgetRef ref,
    ReminderScheduleModel schedule,
    ReminderDoseTime doseTime,
  ) async {
    final isLast = schedule.doseTimes.length <= 1;
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete dose',
      message: isLast
          ? 'This is the only dose in this schedule, so the whole schedule '
              'will be removed. Its history will be deleted too.'
          : 'Remove the ${formatDoseTime(doseTime.scheduledTime)} dose? '
              'Its history will be deleted too.',
      confirmLabel: AppStrings.delete,
      isDanger: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      if (isLast) {
        await ref.read(remindersProvider.notifier).deleteSchedule(schedule.id);
      } else {
        // Send the survivors untouched — omitting the deleted id is what
        // removes it.
        await ref.read(remindersProvider.notifier).updateSchedule(
              id: schedule.id,
              doseTimes: [
                for (final d in schedule.doseTimes)
                  if (d.id != doseTime.id) DoseTimeEdit.from(d),
              ],
              scheduleType:
                  _toApiScheduleType(_toAppRepeat(schedule.scheduleType)),
            );
      }
      if (!context.mounted) return;
      AppSnackbar.info(context, AppStrings.scheduleDeleted);
      await ref.read(medicinesProvider.notifier).load();
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.toString());
    }
  }

  static String _toAppRepeat(String apiType) => switch (apiType) {
        'WEEKDAYS' => AppStrings.repeatWeekdays,
        'WEEKENDS' => AppStrings.repeatWeekends,
        'CUSTOM' => AppStrings.repeatCustom,
        _ => AppStrings.repeatDaily,
      };

  static String _toApiScheduleType(String label) => switch (label) {
        AppStrings.repeatWeekdays => 'WEEKDAYS',
        AppStrings.repeatWeekends => 'WEEKENDS',
        AppStrings.repeatCustom => 'CUSTOM',
        _ => 'DAILY',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);
    final schedules =
        state.schedules.where((s) => s.userMedicineId == medicine.id).toList();
    final stock = medicine.activeStock;
    final color = medicine.status.color;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // ── For whom ──────────────────────────────────────────────────────
        AppSectionHeaderText(
          title: 'For',
          padding: EdgeInsets.zero,
          // Only PERSONAL entries can move: a shared master's audience is its
          // member rows, and a member belongs to its master.
          actionLabel: medicine.isShared ? null : 'Change',
          actionIcon: Icons.edit_rounded,
          onAction: medicine.isShared
              ? null
              : () => showReassignPatientSheet(context, medicine),
        ),
        const SizedBox(height: 8),
        AppInfoLabelText(
          icon: medicine.patientName != null
              ? Icons.people_rounded
              : Icons.person_rounded,
          accentColor: medicine.patientName != null
              ? AppColors.blue
              : AppColors.teal,
          label: 'Taken by',
          value: medicine.forWhom,
        ),
        if (medicine.course case final course?)
          AppInfoLabelText(
            icon: Icons.event_repeat_rounded,
            accentColor: AppColors.teal,
            label: 'Course ends',
            value: switch (course.daysRemaining) {
              0 => 'Ended ${course.endsOn!.toIso8601String().split('T').first}',
              final d => '${course.endsOn!.toIso8601String().split('T').first}'
                  ' · $d days left',
            },
          ),

        // ── Schedules ─────────────────────────────────────────────────────
        const SizedBox(height: 20),
        AppSectionHeaderText(
          title: AppStrings.fullScheduleLabel,
          padding: EdgeInsets.zero,
          actionLabel: AppStrings.addDose,
          actionIcon: Icons.add_rounded,
          onAction: () => _addSchedule(context, ref),
        ),
        const SizedBox(height: 10),
        if (state.isLoading && state.schedules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: AppLoadingSpinner()),
          )
        else if (schedules.isEmpty)
          _NoteCard(
            icon: Icons.info_outline_rounded,
            color: AppColors.purple,
            message:
                medicine.isPrn ? AppStrings.prnNote : AppStrings.noScheduleSet,
          )
        else
          // One card per dose time, not per schedule: "twice daily" is a
          // single schedule holding two times, and collapsing it to one row
          // hid the second dose entirely.
          for (final s in schedules)
            for (final dt in s.doseTimes)
              DoseTimeCard(
                schedule: s,
                doseTime: dt,
                onEdit: () => _editDose(context, ref, s, dt),
              ),

        // ── Stock ─────────────────────────────────────────────────────────
        const SizedBox(height: 20),
        AppSectionHeaderText(
          title: AppStrings.stockTab,
          padding: EdgeInsets.zero,
          // SHARED_MEMBER entries hold no stock of their own — the backend
          // rejects writes and points you at the master.
          actionLabel: medicine.isSharedMember
              ? null
              : (medicine.hasStock ? 'Top up' : 'Add'),
          actionIcon: Icons.add_rounded,
          onAction: medicine.isSharedMember
              ? null
              : () => showAddStockSheet(context, medicine),
        ),
        const SizedBox(height: 10),
        if (stock == null)
          // The section header carries an "Add" action too, but an empty
          // state needs its own obvious button — a header link is easy to
          // miss when the body is just explanatory text.
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 16, color: context.hintText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText.bodySm(medicine.isSharedMember
                          ? 'Stock is tracked on the shared bottle.'
                          : 'No stock recorded yet.'),
                    ),
                  ],
                ),
                if (!medicine.isSharedMember) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    variant: AppButtonVariant.primary,
                    label: 'Add stock',
                    leading: const Icon(Icons.add_rounded, size: 18),
                    isFullWidth: true,
                    onPressed: () => showAddStockSheet(context, medicine),
                  ),
                ],
              ],
            ),
          )
        else ...[
          // Remaining vs. used since the last top-up: both numbers come from
          // the stock history, so the ring never implies a pack size we don't
          // actually know.
          AppDonutChart(
            size: 150,
            centerValue: '${stock.quantity}',
            centerLabel: AppStrings.unitsRemaining,
            segments: [
              AppDonutSegment(
                  label: 'Remaining',
                  value: stock.quantity.toDouble(),
                  color: color),
              if (stock.usedSinceRefill > 0)
                AppDonutSegment(
                    label: 'Used',
                    value: stock.usedSinceRefill.toDouble(),
                    color: context.hintText),
            ],
          ),
          const SizedBox(height: 12),
          if (stock.expiryDate != null)
            AppInfoLabelText(
              icon: Icons.event_busy_rounded,
              label: 'Expires',
              value: stock.expiryDate!.split('T').first,
            ),
          if (stock.minThreshold > 0)
            AppInfoLabelText(
              icon: Icons.notifications_active_outlined,
              label: 'Refill alert at',
              value: '${stock.minThreshold} units',
            ),
          if (stock.trend.length >= 2) ...[
            const SizedBox(height: 12),
            const AppSectionHeaderText(
                title: 'Recent movement', padding: EdgeInsets.zero),
            const SizedBox(height: 10),
            AppSparkline(points: stock.trend, color: color, height: 56),
          ],
        ],

        const SizedBox(height: 28),
        AppButton(
          variant: AppButtonVariant.danger,
          label: AppStrings.remove,
          leading: const Icon(Icons.delete_outline_rounded, size: 18),
          isFullWidth: true,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

// ─── Description ─────────────────────────────────────────────────────────────

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.medicine, required this.controller});

  final UserMedicineEntity medicine;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final usedFor = medicine.primarilyUsedFor;
    final description = medicine.description;

    if (usedFor.isEmpty && description.isEmpty) {
      return _EmptyTab(
        controller: controller,
        icon: Icons.description_outlined,
        title: 'No description available',
      );
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        if (usedFor.isNotEmpty) ...[
          const AppSectionHeaderText(
              title: 'Primarily used for', padding: EdgeInsets.zero),
          const SizedBox(height: 8),
          AppText.bodyMd(usedFor),
          const SizedBox(height: 20),
        ],
        if (description.isNotEmpty) ...[
          const AppSectionHeaderText(
              title: 'Description', padding: EdgeInsets.zero),
          const SizedBox(height: 8),
          AppText.bodyMd(description),
        ],
        const SizedBox(height: 20),
        const _Disclaimer(),
      ],
    );
  }
}

// ─── Contraindications ───────────────────────────────────────────────────────

class _ContraindicationsTab extends StatelessWidget {
  const _ContraindicationsTab(
      {required this.medicine, required this.controller});

  final UserMedicineEntity medicine;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final contra = medicine.contraindications;
    final compositions = medicine.compositions;

    if (contra.isEmpty && compositions.isEmpty) {
      return _EmptyTab(
        controller: controller,
        icon: Icons.block_rounded,
        title: 'No contraindications listed',
      );
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        if (contra.isNotEmpty) ...[
          const AppSectionHeaderText(
              title: 'Contraindications', padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          for (final item in contra)
            _Bullet(text: item, accent: AppColors.red),
          const SizedBox(height: 20),
        ],
        if (compositions.isNotEmpty) ...[
          const AppSectionHeaderText(
              title: 'Compositions', padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          for (final item in compositions)
            _Bullet(text: item, accent: AppColors.teal),
        ],
        const SizedBox(height: 20),
        const _Disclaimer(),
      ],
    );
  }
}

// ─── Details ─────────────────────────────────────────────────────────────────

/// Form, strength, manufacturer and the rest of the catalog's product facts.
class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.medicine, required this.controller});

  final UserMedicineEntity medicine;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.medication_outlined, 'Form', medicine.form),
      (Icons.straighten_rounded, 'Strength', medicine.strength),
      (Icons.science_outlined, 'Generic name', medicine.genericName),
      (Icons.factory_outlined, 'Manufacturer', medicine.manufacturer),
      (Icons.inventory_2_outlined, 'Packing', medicine.packing),
      (Icons.straighten_outlined, 'Unit', medicine.unit),
      (Icons.thermostat_rounded, 'Storage', medicine.storageConditions),
    ].where((r) => r.$3.isNotEmpty).toList();

    if (rows.isEmpty && medicine.drugInteractions.isEmpty) {
      return _EmptyTab(
        controller: controller,
        icon: Icons.info_outline_rounded,
        title: 'No product details available',
      );
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        for (final (icon, label, value) in rows)
          AppInfoLabelText(icon: icon, label: label, value: value),
        if (medicine.drugInteractions.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AppSectionHeaderText(
              title: 'Drug interactions', padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          for (final item in medicine.drugInteractions)
            _Bullet(text: item, accent: AppColors.amber),
        ],
      ],
    );
  }
}

// ─── Generic list tab ────────────────────────────────────────────────────────

class _ListTab extends StatelessWidget {
  const _ListTab({
    required this.controller,
    required this.title,
    required this.items,
    required this.icon,
    required this.accent,
  });

  final ScrollController controller;
  final String title;
  final List<String> items;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyTab(
        controller: controller,
        icon: icon,
        title: 'No ${title.toLowerCase()} listed',
      );
    }
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        AppSectionHeaderText(title: title, padding: EdgeInsets.zero),
        const SizedBox(height: 10),
        for (final item in items) _Bullet(text: item, accent: accent),
        const SizedBox(height: 20),
        const _Disclaimer(),
      ],
    );
  }
}

// ─── Shared bits ─────────────────────────────────────────────────────────────

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          Expanded(child: AppText.bodyMd(text)),
        ],
      ),
    );
  }
}

/// Shown when the catalog carries nothing for this tab. These fields are
/// nullable JSON columns that no importer or admin screen populates yet, so
/// this is the normal state today rather than an error.
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.controller,
    required this.icon,
    required this.title,
  });

  final ScrollController controller;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        AppEmptyState(
          icon: icon,
          title: title,
          subtitle: 'This information has not been added to the catalog yet.',
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) => _NoteCard(
        icon: Icons.warning_amber_rounded,
        color: AppColors.amber,
        message: AppStrings.infoDisclaimer,
      );
}

// ─── Note card ───────────────────────────────────────────────────────────────

/// Tinted one-line explainer. [AppInfoCard] can't serve here — it renders a
/// list of label/value rows, not prose.
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.2),
      effectColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(child: AppText.bodySm(message)),
        ],
      ),
    );
  }
}
