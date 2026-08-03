import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';

/// How a cabinet entry is presented — derived from the entity, not stored.
enum MedStatus { active, lowStock, prn }

extension MedicineStatusX on UserMedicineEntity {
  MedStatus get status => isPrn
      ? MedStatus.prn
      : isLowStock
          ? MedStatus.lowStock
          : MedStatus.active;
}

extension MedStatusX on MedStatus {
  Color get color => switch (this) {
        MedStatus.active => AppColors.teal,
        MedStatus.lowStock => AppColors.amber,
        MedStatus.prn => AppColors.purple,
      };

  AppBadgeVariant get badgeVariant => switch (this) {
        MedStatus.active => AppBadgeVariant.teal,
        MedStatus.lowStock => AppBadgeVariant.amber,
        MedStatus.prn => AppBadgeVariant.purple,
      };

  String get label => switch (this) {
        MedStatus.active => AppStrings.activeStatus,
        MedStatus.lowStock => AppStrings.lowStockStatus,
        MedStatus.prn => AppStrings.prnLabel,
      };
}

class MedicineStatusBadge extends StatelessWidget {
  const MedicineStatusBadge(this.status, {super.key});

  final MedStatus status;

  @override
  Widget build(BuildContext context) => AppBadge(
        label: status.label,
        variant: status.badgeVariant,
        // AppStrings.lowStockStatus already carries a "⚠" glyph — a leading
        // warning icon would show it twice.
        dot: status == MedStatus.active,
      );
}

/// Pill marking who a cabinet entry involves beyond "just me" — a shared
/// bottle, a caretaker-managed entry, or a personal medicine added for a
/// specific patient profile. Renders nothing for a plain "for myself" entry —
/// the common case needs no explanation.
///
/// Colour follows the same person-based scheme the add-wizard's "Who is this
/// for?" step uses: teal = self (the default, so no badge), blue = a named
/// patient, purple = a shared bottle.
class MedicineScopeBadge extends StatelessWidget {
  const MedicineScopeBadge(this.medicine, {super.key});

  final UserMedicineEntity medicine;

  @override
  Widget build(BuildContext context) {
    if (medicine.isSharedMaster) {
      return const AppBadge(
        label: 'Shared',
        variant: AppBadgeVariant.purple,
        leadingIcon: Icon(Icons.share_rounded),
      );
    }
    if (medicine.isSharedMember) {
      return const AppBadge(
        label: 'Caretaker',
        variant: AppBadgeVariant.purple,
        leadingIcon: Icon(Icons.person_add_rounded),
      );
    }
    // A PERSONAL entry a caretaker added for someone else — scope alone
    // doesn't distinguish this from "for myself", patientName does.
    if (medicine.patientName case final name?) {
      return AppBadge(
        label: name,
        variant: AppBadgeVariant.blue,
        leadingIcon: const Icon(Icons.person_rounded),
      );
    }
    return const SizedBox.shrink();
  }
}

/// One scheduled dose time, tinted by time of day.
///
/// [compact] drops the sun/moon icon and shortens the label ("2 PM" rather
/// than "2:00 PM · ☀") so a full day's doses fit across a grid tile. The tint
/// still carries the day/night distinction.
class DoseTimeBadge extends StatelessWidget {
  const DoseTimeBadge(this.time, {super.key, this.compact = false});

  final String time;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final night = isNightDose(time);
    return AppBadge(
      label: compact ? formatDoseTimeCompact(time) : formatDoseTime(time),
      variant: night ? AppBadgeVariant.purple : AppBadgeVariant.amber,
      leadingIcon: compact
          ? null
          : Icon(night ? Icons.nightlight_round : Icons.wb_sunny_rounded),
    );
  }
}

/// A medicine's dose times as compact chips, or the as-needed/no-schedule
/// note. Wraps rather than a fixed [Row] — a [Wrap] can never overflow the
/// available width; a busy day's worth of chips just runs onto a second
/// line instead of the row clipping or erroring.
///
/// Shared by [MedicineGridCard] and [MedicineListRow] so both surfaces show
/// a day's schedule the same way.
class MedicineDoseTimesWrap extends StatelessWidget {
  const MedicineDoseTimesWrap(this.medicine, {super.key});

  final UserMedicineEntity medicine;

  @override
  Widget build(BuildContext context) {
    if (medicine.isPrn) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: AppBadge(
          label: AppStrings.prnNote,
          variant: AppBadgeVariant.purple,
        ),
      );
    }

    final times = medicine.doseTimes;
    if (times.isEmpty) {
      return Row(
        children: [
          Icon(Icons.schedule_rounded, size: 11, color: context.hintText),
          const SizedBox(width: 5),
          Expanded(
            child: AppText.bodyXs(AppStrings.noScheduleSet,
                color: AppColors.textHint, maxLines: 1),
          ),
        ],
      );
    }

    final left = medicine.courseDaysRemaining;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final t in times) DoseTimeBadge(t, compact: true),
        // A fixed course is the one thing a time chip can't convey: the same
        // "9 AM" means something different on day 1 of 5 than on an
        // open-ended schedule.
        if (left != null)
          AppBadge(
            label: left == 0 ? 'Course ended' : '$left d left',
            variant:
                left == 0 ? AppBadgeVariant.neutral : AppBadgeVariant.teal,
            leadingIcon: const Icon(Icons.event_repeat_rounded),
          ),
      ],
    );
  }
}

// ─── Time formatting ─────────────────────────────────────────────────────────
// Thin aliases over core/utils/time_format.dart, kept so existing call sites
// across this feature don't all need renaming to the shared name.

/// "21:00" → "9:00 PM".
String formatDoseTime(String hhmm) => formatTime12h(hhmm);

/// "14:00" → "2 PM"; "09:30" → "9:30 AM". Drops the ":00" on the hour, which
/// is most doses — the saved width is what lets every dose time fit on a card
/// instead of being truncated to a "+2".
String formatDoseTimeCompact(String hhmm) => formatTime12hCompact(hhmm);

/// "09:00", "21:00" → "9:00 AM · 9:00 PM". Times are stored and sent as 24h;
/// every user-facing surface shows 12h.
String formatDoseTimes(Iterable<String> times) =>
    times.map(formatDoseTime).join(' · ');

/// Evening and night doses read better with a moon than a sun.
bool isNightDose(String hhmm) => isNightTime(hhmm);

/// "WITH" → "With food".
String formatFoodTiming(String raw) => switch (raw.toUpperCase()) {
      'BEFORE' => AppStrings.beforeFood,
      'AFTER' => AppStrings.afterFood,
      'WITH' => AppStrings.withFood,
      'WITHOUT' => 'Without food',
      _ => 'As directed',
    };
