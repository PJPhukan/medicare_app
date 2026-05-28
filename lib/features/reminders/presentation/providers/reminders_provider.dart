import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

  String get _userName =>
      _ref.read(authProvider).user?.displayName ?? 'there';

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
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Creates a schedule.
  ///
  /// **Online**: calls backend immediately, schedules local alarm.
  /// **Offline**: builds a temporary local model, schedules the local alarm
  /// right away (user still gets notified), and queues the create for backend
  /// sync when connectivity returns.
  Future<ReminderScheduleModel> createSchedule({
    required String medicineName,
    required String time,
    required String unit,
    required String foodTiming,
    required String scheduleType,
    String reminderType = 'MEDICINE',
    int preNotifyMinutes = 10,
  }) async {
    final isOnline = _ref.read(isOnlineProvider);

    late ReminderScheduleModel schedule;

    AppLogger.i('Reminder create → medicine:*** online:$isOnline', tag: 'Reminder');
    if (isOnline) {
      schedule = await _ds.createSchedule(
        medicineName: medicineName,
        doseTimes: [
          {'scheduledTime': time, 'unit': unit, 'foodTiming': foodTiming}
        ],
        reminderType: reminderType,
        scheduleType: scheduleType,
        preNotifyMinutes: preNotifyMinutes,
      );
    } else {
      // Build a temporary local schedule with a client-generated UUID.
      // The sync engine will create the real backend record and reload.
      final tempId = _uuid.v4();
      schedule = ReminderScheduleModel(
        id: tempId,
        medicineName: medicineName,
        reminderType: reminderType,
        scheduleType: scheduleType,
        doseTimes: [
          ReminderDoseTime(
            id: _uuid.v4(),
            scheduledTime: time,
            unit: unit,
            foodTiming: foodTiming.toUpperCase(),
          ),
        ],
        preNotifyMinutes: preNotifyMinutes,
      );

      // Enqueue for backend sync when connectivity returns.
      await _queue.enqueue(SyncOperation.create(
        feature: 'reminders',
        action: 'create_schedule',
        payload: {
          'medicineName': medicineName,
          'doseTimes': [
            {'scheduledTime': time, 'unit': unit, 'foodTiming': foodTiming}
          ],
          'reminderType': reminderType,
          'scheduleType': scheduleType,
          'preNotifyMinutes': preNotifyMinutes,
        },
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
