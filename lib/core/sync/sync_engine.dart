import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/client.dart';
import '../api/interceptors/cache_interceptor.dart';
import '../constants/api_constants.dart';
import '../local_db/local_cache.dart';
import '../local_db/sync_queue.dart';
import '../network/connectivity_monitor.dart';
import '../utils/logger.dart';
import 'sync_status.dart';

/// Drains the [SyncQueue] whenever the device comes back online.
///
/// The provider factory wires the connectivity listener via [ref.listen];
/// this class owns only the stateless drain logic.
class SyncEngine {
  SyncEngine({
    required Dio dio,
    required SyncQueue queue,
    required LocalCache cache,
    required SyncStateNotifier status,
  })  : _dio = dio,
        _queue = queue,
        _cache = cache,
        _status = status;

  final Dio _dio;
  final SyncQueue _queue;
  final LocalCache _cache;
  final SyncStateNotifier _status;
  bool _running = false;

  // ── Public drain API ─────────────────────────────────────────────────────────

  Future<void> drain() async {
    if (_running) return;
    final ops = _queue.all;
    if (ops.isEmpty) return;

    _running = true;
    _status.setDraining(ops.length);
    AppLogger.i('Sync drain start → ${ops.length} op(s)', tag: 'Sync');

    for (final op in ops) {
      if (op.retryCount >= SyncQueue.maxRetries) {
        AppLogger.w('Sync op dropped (max retries) → ${op.key}', tag: 'Sync');
        await _queue.remove(op.id);
        continue;
      }
      try {
        await _execute(op);
        await _queue.remove(op.id);
        await _invalidate(op);
        AppLogger.i('Sync op ✓ → ${op.key}', tag: 'Sync');
      } on DioException catch (e) {
        AppLogger.e('Sync op failed → ${op.key}', tag: 'Sync', error: e);
        await _queue.updateRetry(op.id);
        _status.setError(e.message ?? 'Sync failed');
      } catch (e) {
        AppLogger.e('Sync op failed → ${op.key}', tag: 'Sync', error: e);
        await _queue.updateRetry(op.id);
        _status.setError(e.toString());
      }
    }

    _running = false;
    _status.setIdle(_queue.length);
    AppLogger.i('Sync drain complete → ${_queue.length} remaining', tag: 'Sync');
  }

  // ── Operation dispatch ───────────────────────────────────────────────────────

  Future<void> _execute(SyncOperation op) async {
    switch (op.key) {
      case 'schedule:mark_dose':
        await _dio.post<void>(
          '${ApiConstants.doseLogs}/${op.payload['doseTimeId']}/mark',
          data: {'status': op.payload['status']},
        );

      case 'vitals:add_reading':
        await _dio.post<void>(
          ApiConstants.myVitals,
          data: {
            'vitalConfigId': op.payload['vitalConfigId'],
            'values': op.payload['values'],
            if (op.payload['notes'] != null) 'notes': op.payload['notes'],
            if (op.payload['measuredAt'] != null)
              'measuredAt': op.payload['measuredAt'],
          },
        );

      case 'medicines:delete_medicine':
        await _dio.delete<void>(
          '${ApiConstants.myMedicines}/${op.payload['id']}',
        );

      case 'reports:delete_report':
        await _dio.delete<void>(
          '${ApiConstants.reports}/${op.payload['id']}',
        );

      case 'reminders:create_schedule':
        await _dio.post<void>(
          ApiConstants.reminderSchedules,
          data: {
            'medicineName': op.payload['medicineName'],
            'doseTimes': op.payload['doseTimes'],
            'reminderType': op.payload['reminderType'],
            'scheduleType': op.payload['scheduleType'],
            'preNotifyMinutes': op.payload['preNotifyMinutes'],
          },
        );
    }
  }

  // ── Cache invalidation ───────────────────────────────────────────────────────

  Future<void> _invalidate(SyncOperation op) async {
    final base = _dio.options.baseUrl;
    final String? path = switch (op.key) {
      'schedule:mark_dose'        => ApiConstants.todayDoses,
      'vitals:add_reading'        => ApiConstants.myVitals,
      'medicines:delete_medicine' => ApiConstants.myMedicines,
      'reports:delete_report'     => ApiConstants.reports,
      'reminders:create_schedule' => ApiConstants.reminderSchedules,
      _                           => null,
    };
    if (path != null) {
      await _cache.remove(CacheInterceptor.keyFor(base, path));
    }
  }
}

// ─── Provider ──────────────────────────────────────────────────────────────────

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    dio:    ref.read(dioProvider),
    queue:  ref.read(syncQueueProvider),
    cache:  ref.read(localCacheProvider),
    status: ref.read(syncStateProvider.notifier),
  );

  // Drain immediately on startup if already online and queue has items.
  if (ref.read(isOnlineProvider) && !ref.read(syncQueueProvider).isEmpty) {
    Future.microtask(engine.drain);
  }

  // Re-drain whenever connectivity is restored (offline → online).
  ref.listen<bool>(isOnlineProvider, (prev, next) {
    if (next && (prev == false || prev == null)) engine.drain();
  });

  return engine;
});
