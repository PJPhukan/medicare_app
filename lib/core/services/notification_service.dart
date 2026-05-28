import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../features/reminders/data/models/reminder_schedule_model.dart';
import '../utils/logger.dart';

/// Handles local notification scheduling and TTS voice alerts for dose reminders.
///
/// Architecture:
///   • [flutter_local_notifications] + zonedSchedule  → shows a persistent alarm
///     notification at preNotifyMinutes before each dose time.
///   • [flutter_tts] → speaks "Hey [name], time to take your [medicine]"
///     when the notification is tapped OR when [speak] is called directly.
///
/// Call [init] once from main() before runApp.
/// Call [scheduleReminderAlarms] after creating a reminder schedule.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static final _tts = FlutterTts();
  static bool _initialized = false;

  static const _channelId = 'dose_reminders';
  static const _channelName = 'Dose Reminders';

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ── Timezone ──────────────────────────────────────────────────────────────
    tz_data.initializeTimeZones();
    try {
      // On Android, timeZoneName returns a valid tz database name (e.g. "Asia/Kolkata").
      final tzName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback: keep UTC. Alarms still fire but may be offset by DST.
    }

    // ── Local notifications ───────────────────────────────────────────────────
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Pre-dose medicine reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));

    // ── TTS ───────────────────────────────────────────────────────────────────
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
  }

  /// Speak a message aloud via TTS (used when app is in foreground).
  static Future<void> speak(String message) => _tts.speak(message);

  static void _onNotificationTapped(NotificationResponse response) {
    AppLogger.i('Notification tapped → id:${response.id}', tag: 'Notification');
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _tts.speak(payload);
    }
  }

  /// Schedule local alarm notifications for every dose time in [schedule].
  ///
  /// Fires [schedule.preNotifyMinutes] before each dose.
  /// TTS message: "Hey [firstName], time to take your [medicineName]"
  static Future<void> scheduleReminderAlarms({
    required ReminderScheduleModel schedule,
    required String userName,
  }) async {
    await init();
    final firstName = userName.split(' ').first;
    final message = 'Hey $firstName, time to take your ${schedule.medicineName}';
    final repeat = _matchFor(schedule.scheduleType);

    for (final dose in schedule.doseTimes) {
      final parts = dose.scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Compute next occurrence of this dose time in local timezone
      final now = tz.TZDateTime.now(tz.local);
      var doseTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (doseTime.isBefore(now.add(const Duration(minutes: 1)))) {
        doseTime = doseTime.add(const Duration(days: 1));
      }
      final notifTime = doseTime.subtract(Duration(minutes: schedule.preNotifyMinutes));

      await _plugin.zonedSchedule(
        _notifId(schedule.id, dose.id),
        'Medicine Reminder',
        message,
        notifTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Pre-dose medicine reminders',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(message),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeat,
        payload: message,
      );
    }
  }

  /// Cancel all alarms for a given schedule (pass the dose IDs).
  static Future<void> cancelReminderAlarms(
    String scheduleId,
    List<String> doseIds,
  ) async {
    for (final doseId in doseIds) {
      await _plugin.cancel(_notifId(scheduleId, doseId));
    }
  }

  /// Cancel every pending local notification and reschedule from [schedules].
  /// Call after login / app launch to survive reinstalls.
  static Future<void> rescheduleAll({
    required List<ReminderScheduleModel> schedules,
    required String userName,
  }) async {
    await init();
    await _plugin.cancelAll();
    for (final s in schedules) {
      if (!s.isActive) continue;
      await scheduleReminderAlarms(schedule: s, userName: userName);
    }
  }

  static int _notifId(String scheduleId, String doseId) =>
      (scheduleId + doseId).hashCode.abs() % 2147483647;

  static DateTimeComponents? _matchFor(String scheduleType) => switch (scheduleType) {
        'DAILY' => DateTimeComponents.time,
        'WEEKDAYS' => DateTimeComponents.dayOfWeekAndTime,
        'WEEKENDS' => DateTimeComponents.dayOfWeekAndTime,
        _ => null, // CUSTOM → one-shot
      };
}

// Top-level background handler required by flutter_local_notifications.
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse response) {
  // Background isolate: TTS requires a foreground context, so we just log.
  // The notification itself carries the full message text.
}
