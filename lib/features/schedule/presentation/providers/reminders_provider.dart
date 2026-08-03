import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/device_timezone.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/reminders_remote_datasource.dart';
import '../../data/models/reminder_schedule_model.dart';

const _uuid = Uuid();

// ── State ─────────────────────────────────────────────────────────────────────

class RemindersState {
  const RemindersState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ReminderScheduleModel> schedules;
  final bool isLoading;
  final String? error;

  RemindersState copyWith({
    List<ReminderScheduleModel>? schedules,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      RemindersState(
        schedules: schedules ?? this.schedules,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier(this._ds, this._queue, this._ref)
      : super(const RemindersState()) {
    load();
  }

  final RemindersRemoteDataSource _ds;
  final SyncQueue _queue;
  final Ref _ref;

  // greetingName, not displayName: this becomes "Hey <name>, time to take
  // your ..." in the alarm, and displayName's old email fallback made the
  // phone read the user's address aloud.
  String get _userName =>
      _ref.read(authProvider).user?.greetingName ?? 'there';

  /// Fetches schedules from backend and reschedules all local alarms.
  /// Calling this after login / app launch ensures alarms survive reinstalls.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final schedules = await _ds.getSchedules();
      state = state.copyWith(schedules: schedules, isLoading: false);

      // Reschedule every active alarm so reinstalls or new-device logins
      // are automatically covered once the user comes back online.
      await NotificationService.rescheduleAll(
        schedules: schedules,
        userName: _userName,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Creates a schedule.
  ///
  /// **Online**: calls backend immediately, schedules local alarm.
  /// **Offline**: builds a temporary local model, schedules the local alarm
  /// right away (user still gets notified), and queues the create for backend
  /// sync when connectivity returns.
  /// [userMedicineId] links the schedule to an existing cabinet entry — always
  /// prefer it over a bare [medicineName], which makes the backend create a
  /// second, catalog-less UserMedicine alongside the one the user picked.
  /// [times] carries every HH:mm of the schedule; [time] is the single-dose
  /// shorthand.
  Future<ReminderScheduleModel> createSchedule({
    required String medicineName,
    String? userMedicineId,
    String? time,
    List<String>? times,
    required String unit,
    required String foodTiming,
    required String scheduleType,
    num quantity = 1,
    String reminderType = 'MEDICINE',
    int preNotifyMinutes = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final slots = times ?? (time != null ? [time] : const <String>[]);
    assert(slots.isNotEmpty || scheduleType == 'PRN',
        'a non-PRN schedule needs at least one dose time');

    final isOnline = _ref.read(isOnlineProvider);
    // Device clock's IANA zone (no permission needed) — the backend anchors
    // reminder fire times and dose days to this.
    final timezone = await DeviceTimezone.get();
    final doseTimes = [
      for (final t in slots)
        {
          'scheduledTime': t,
          'quantity': quantity,
          'unit': unit,
          'foodTiming': foodTiming.toUpperCase(),
        }
    ];

    late ReminderScheduleModel schedule;

    AppLogger.i('Reminder create → medicine:*** online:$isOnline tz:$timezone', tag: 'Reminder');
    if (isOnline) {
      // reminderType stays app-local (display/alarm category); the backend has
      // no field for it, so it is not part of the payload.
      schedule = await _ds.createSchedule(
        userMedicineId: userMedicineId,
        // Sending both would be redundant — the backend resolves the id first.
        medicineName: userMedicineId == null ? medicineName : null,
        doseTimes: doseTimes,
        scheduleType: scheduleType,
        timezone: timezone,
        preNotifyMinutes: preNotifyMinutes,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      // Build a temporary local schedule with a client-generated UUID.
      // The sync engine will create the real backend record and reload.
      final tempId = _uuid.v4();
      schedule = ReminderScheduleModel(
        id: tempId,
        userMedicineId: userMedicineId,
        medicineName: medicineName,
        reminderType: reminderType,
        scheduleType: scheduleType,
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
        doseTimes: [
          for (final t in slots)
            ReminderDoseTime(
              id: _uuid.v4(),
              scheduledTime: t,
              unit: unit,
              foodTiming: foodTiming.toUpperCase(),
            ),
        ],
        preNotifyMinutes: preNotifyMinutes,
      );

      // Enqueue for backend sync when connectivity returns — same canonical
      // payload the online path sends.
      await _queue.enqueue(SyncOperation.create(
        feature: 'reminders',
        action: 'create_schedule',
        payload: buildCreateSchedulePayload(
          userMedicineId: userMedicineId,
          medicineName: userMedicineId == null ? medicineName : null,
          doseTimes: doseTimes,
          scheduleType: scheduleType,
          timezone: timezone,
          preNotifyMinutes: preNotifyMinutes,
          startDate: startDate,
          endDate: endDate,
        ),
      ));
    }

    state = state.copyWith(schedules: [schedule, ...state.schedules]);
    AppLogger.i('Reminder created ✓ → id:${schedule.id}', tag: 'Reminder');

    // Schedule local voice alarm regardless of online/offline status.
    await NotificationService.scheduleReminderAlarms(
      schedule: schedule,
      userName: _userName,
    );

    return schedule;
  }

  /// Edits an existing schedule.
  ///
  /// [doseTimes] is the full list for the schedule. An entry carrying an `id`
  /// updates that row in place and keeps its adherence history; an entry
  /// without one is created; any existing id left out is deleted, which
  /// cascades its DoseLogs away. Fields are per dose time — a schedule can
  /// hold doses with different amounts, so a single shared unit/quantity
  /// would silently rewrite the ones the user did not touch.
  Future<void> updateSchedule({
    required String id,
    required List<DoseTimeEdit> doseTimes,
    required String scheduleType,
    DateTime? endDate,
    bool clearEndDate = false,
  }) async {
    AppLogger.i('Reminder update → id:$id times:${doseTimes.length}',
        tag: 'Reminder');
    // Capture the CURRENT dose-time ids before the edit: the server may drop
    // or renumber them, and cancelling by the post-edit ids would leave the
    // old alarms armed at their previous times.
    final previousDoseIds = state.schedules
            .firstWhereOrNull((s) => s.id == id)
            ?.doseTimes
            .map((d) => d.id)
            .toList() ??
        const <String>[];
    final timezone = await DeviceTimezone.get();

    final updated = await _ds.updateSchedule(
      id,
      doseTimes: [for (final d in doseTimes) d.toJson()],
      scheduleType: scheduleType,
      timezone: timezone,
      endDate: endDate,
      clearEndDate: clearEndDate,
    );

    state = state.copyWith(
      schedules:
          state.schedules.map((s) => s.id == id ? updated : s).toList(),
    );

    // The old alarms point at the previous times; cancel before rescheduling
    // so a moved dose doesn't leave a stale alarm behind.
    await NotificationService.cancelReminderAlarms(
      id,
      {...previousDoseIds, ...updated.doseTimes.map((d) => d.id)}.toList(),
    );
    await NotificationService.scheduleReminderAlarms(
      schedule: updated,
      userName: _userName,
    );
    AppLogger.i('Reminder updated ✓ → id:$id', tag: 'Reminder');
  }

  Future<void> toggleSchedule(String id) async {
    final schedule = state.schedules.firstWhereOrNull((s) => s.id == id);
    if (schedule == null) return;
    final newActive = !schedule.isActive;
    AppLogger.i('Reminder toggle → id:$id active:$newActive', tag: 'Reminder');
    state = state.copyWith(
      schedules: state.schedules
          .map((s) => s.id == id ? s.copyWith(isActive: newActive) : s)
          .toList(),
    );
    try {
      await _ds.toggleSchedule(id, isActive: newActive);
      AppLogger.i('Reminder toggled ✓', tag: 'Reminder');
    } on Exception catch (e, s) {
      AppLogger.e('Reminder toggle failed', tag: 'Reminder', error: e, stack: s);
      await load();
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id) async {
    AppLogger.i('Reminder delete → id:$id', tag: 'Reminder');
    final schedule = state.schedules.firstWhereOrNull((s) => s.id == id);
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != id).toList(),
    );
    try {
      await _ds.deleteSchedule(id);
      if (schedule != null) {
        await NotificationService.cancelReminderAlarms(
          id,
          schedule.doseTimes.map((d) => d.id).toList(),
        );
      }
      AppLogger.i('Reminder deleted ✓', tag: 'Reminder');
    } on Exception catch (e, s) {
      AppLogger.e('Reminder delete failed', tag: 'Reminder', error: e, stack: s);
      await load();
      rethrow;
    }
  }
}

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _remindersDsProvider = Provider<RemindersRemoteDataSource>(
  (ref) => RemindersRemoteDataSource(ref.read(dioProvider)),
);

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  ref.watch(authTokenProvider);
  return RemindersNotifier(
    ref.read(_remindersDsProvider),
    ref.read(syncQueueProvider),
    ref,
  );
});
