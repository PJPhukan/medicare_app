import '../../../schedule/data/models/today_dose_model.dart' as dash_model;

enum DoseStatus { taken, skipped, missed, pending }

class DashboardDose {
  DashboardDose({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
  });
  final String id;
  final String name;
  final String time;
  DoseStatus status;
}

// ─── Adapters ─────────────────────────────────────────────────────────────────

DashboardDose toLocalDose(dash_model.TodayDose d) => DashboardDose(
      id: d.doseTimeId,
      name: d.medicineName,
      time: d.scheduledTime,
      // MISSED used to fall through to pending (never checked), so an
      // overdue dose kept showing Take/Skip buttons instead of its outcome.
      status: d.isTaken
          ? DoseStatus.taken
          : d.isSkipped
              ? DoseStatus.skipped
              : d.isMissed
                  ? DoseStatus.missed
                  : DoseStatus.pending,
    );

