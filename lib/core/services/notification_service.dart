import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../features/schedule/data/models/reminder_schedule_model.dart';
import '../utils/device_timezone.dart';
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

  // Channel settings are IMMUTABLE once Android has created the channel —
  // editing importance or audio usage in code does nothing to an installed
  // app. The id is therefore versioned: bumping it is the only way to ship
  // changed alarm behaviour. v2 moves from a notification chime to the alarm
  // stream.
  static const _channelId = 'dose_alarms_v3';
  static const _channelName = 'Dose Alarms';

  /// Superseded channels, deleted on init so they stop appearing in the app's
  /// notification settings as dead duplicates.
  static const _legacyChannelIds = <String>['dose_reminders', 'dose_alarms_v2'];

  /// The system's default ALARM tone. The channel previously inherited the
  /// default NOTIFICATION tone while declaring USAGE_ALARM — that mismatch
  /// left this device vibrating with no sound, because a notification-type
  /// sound routed through the alarm stream isn't reliably played. This is
  /// Android's Settings.System.DEFAULT_ALARM_ALERT_URI, which resolves to
  /// whatever the user has picked as their alarm tone.
  static const _alarmSoundUri = 'content://settings/system/alarm_alert';

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ── Timezone ──────────────────────────────────────────────────────────────
    tz_data.initializeTimeZones();
    try {
      // DateTime.now().timeZoneName returns the ABBREVIATION ("IST"), not an
      // IANA location, so tz.getLocation threw and every alarm silently fell
      // back to UTC — 5.5 hours off in Asia/Kolkata. DeviceTimezone goes
      // through flutter_timezone, which is what the backend payload already
      // uses, so both sides now agree on the zone.
      final tzName = await DeviceTimezone.get();
      tz.setLocalLocation(tz.getLocation(tzName));
      AppLogger.i('Notification timezone → $tzName', tag: 'Notification');
    } catch (e, st) {
      AppLogger.e('Timezone init failed — alarms will use UTC',
          tag: 'Notification', error: e, stack: st);
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
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Medicine dose alarms',
      // max, not high: high shows a heads-up but still plays at notification
      // volume, which is what made these inaudible when the ringer was low.
      importance: Importance.max,
      playSound: true,
      sound: UriAndroidNotificationSound(_alarmSoundUri),
      enableVibration: true,
      // The whole difference between a chime and an alarm: USAGE_ALARM plays
      // on the alarm stream, at alarm volume, and keeps sounding when the
      // phone is on vibrate-for-notifications.
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ));
    for (final id in _legacyChannelIds) {
      await android?.deleteNotificationChannel(id);
    }

    await _ensurePermissions();

    // ── TTS ───────────────────────────────────────────────────────────────────
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
  }

  /// True when the OS lets us post exact alarms. Android 12+ gates these
  /// behind SCHEDULE_EXACT_ALARM; without it `zonedSchedule` in exact mode
  /// throws, which used to abort the whole schedule-creation call.
  static bool _canUseExactAlarms = true;

  /// Whether the OS currently allows exact alarms. UI can show a "fix this"
  /// prompt when false — inexact delivery can drift by several minutes, which
  /// matters for a dose.
  static bool get canUseExactAlarms => _canUseExactAlarms;

  /// Re-reads the exact-alarm permission without prompting.
  ///
  /// The user can grant it from system settings at any time, and Android gives
  /// no callback when they do — so this is polled on app resume. Returns true
  /// when the answer changed, meaning pending alarms should be rebuilt to move
  /// from inexact to exact delivery.
  static Future<bool> refreshExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    try {
      final now = await android.canScheduleExactNotifications() ?? true;
      final changed = now != _canUseExactAlarms;
      _canUseExactAlarms = now;
      if (changed) {
        AppLogger.i('Exact alarm permission changed → $now',
            tag: 'Notification');
      }
      return changed;
    } catch (e, st) {
      AppLogger.e('Exact alarm permission check failed',
          tag: 'Notification', error: e, stack: st);
      return false;
    }
  }

  /// Opens the system "Alarms & reminders" screen. Android only grants
  /// SCHEDULE_EXACT_ALARM through that screen — there is no in-app dialog.
  static Future<bool> requestExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    try {
      await android.requestExactAlarmsPermission();
      // The call returns as soon as the settings screen opens, so the real
      // answer only arrives once the user comes back.
      return await android.canScheduleExactNotifications() ?? false;
    } catch (e, st) {
      AppLogger.e('Exact alarm permission request failed',
          tag: 'Notification', error: e, stack: st);
      return false;
    }
  }

  static Future<void> _ensurePermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    try {
      // Android 13+ runtime notification permission. Harmless to call when it
      // is already granted, and no longer depends on the user having visited
      // the dashboard (which is where the FCM request lives).
      await android.requestNotificationsPermission();

      _canUseExactAlarms = await android.canScheduleExactNotifications() ?? true;
      if (!_canUseExactAlarms) {
        _canUseExactAlarms =
            await android.requestExactAlarmsPermission() ?? false;
      }
      AppLogger.i('Exact alarms allowed → $_canUseExactAlarms',
          tag: 'Notification');
    } catch (e, st) {
      AppLogger.e('Notification permission setup failed',
          tag: 'Notification', error: e, stack: st);
    }
  }

  /// Fires a dose alarm immediately, through the exact same channel and
  /// notification details a real dose uses.
  ///
  /// Waiting for a scheduled dose to prove whether alarms ring is a slow and
  /// ambiguous test — this makes it one tap, and because it shares the code
  /// path, anything wrong with the real alarm is wrong here too.
  static Future<void> fireTestAlarm() async {
    await init();
    await _schedule(
      id: _testAlarmId,
      message: 'This is a test dose alarm',
      when: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2)),
      repeat: null,
    );
    AppLogger.i('Test alarm scheduled (+2s)', tag: 'Notification');
  }

  static const _testAlarmId = 987654321;

  /// Diagnostics for the notification settings screen: what the OS will
  /// actually let us do right now.
  static Future<Map<String, Object?>> alarmDiagnostics() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return {
      'timezone': tz.local.name,
      'exactAlarms': _canUseExactAlarms,
      'notificationsEnabled': await android?.areNotificationsEnabled(),
      'pending': (await _plugin.pendingNotificationRequests()).length,
    };
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
    AppLogger.i(
      'Scheduling alarms → schedule:${schedule.id} type:${schedule.scheduleType} '
      'active:${schedule.isActive} doses:${schedule.doseTimes.length} '
      'lead:${schedule.preNotifyMinutes}m',
      tag: 'Notification',
    );
    final firstName = userName.split(' ').first;
    final message = 'Hey $firstName, time to take your ${schedule.medicineName}';

    for (final dose in schedule.doseTimes) {
      final parts = dose.scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final lead = Duration(minutes: schedule.preNotifyMinutes);

      final now = tz.TZDateTime.now(tz.local);
      final todaysDose =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      // The recurring alarm always sits at the dose's own lead instant. When
      // today's has passed, roll a whole day — rolling the dose instead and
      // then subtracting the lead (what this used to do) can land the alarm
      // in the past, and `matchDateTimeComponents` would then lock the repeat
      // to the wrong wall-clock time.
      var notifTime = todaysDose.subtract(lead);
      if (notifTime.isBefore(now.add(const Duration(minutes: 1)))) {
        notifTime = notifTime.add(const Duration(days: 1));
      }

      // Repeat handling. `matchDateTimeComponents: dayOfWeekAndTime` repeats
      // on the weekday of the instant it was scheduled for — ONE weekday. So a
      // WEEKDAYS schedule needs five separate alarms, not one; a single alarm
      // rang once a week instead of five times. DAILY and CUSTOM (which the
      // app sends as all seven days) are a plain daily repeat.
      final weekdays = _weekdaysFor(schedule.scheduleType);

      if (weekdays.isEmpty) {
        await _schedule(
          id: _notifId(schedule.id, dose.id),
          message: message,
          when: notifTime,
          repeat: DateTimeComponents.time,
        );
      } else {
        for (final weekday in weekdays) {
          await _schedule(
            id: _notifId(schedule.id, dose.id, weekday: weekday),
            message: message,
            when: _nextOnWeekday(notifTime, weekday, hour, minute, lead),
            repeat: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }

      // Late lead: the window opened before the schedule was created (add a
      // 4:10pm dose at 4:00pm with a 15-minute lead) but the dose itself is
      // still ahead. Without this the first dose passes unannounced. It is a
      // one-off — no `matchDateTimeComponents` — so the recurring alarms above
      // keep owning the repeat.
      if (todaysDose.isAfter(now) && todaysDose.subtract(lead).isBefore(now)) {
        await _schedule(
          id: _catchUpNotifId(schedule.id, dose.id),
          message: message,
          when: now.add(const Duration(seconds: 5)),
          repeat: null,
        );
      }
    }
  }

  /// Weekdays (1=Mon .. 7=Sun) a schedule fires on, or empty when it is a
  /// plain every-day repeat.
  static List<int> _weekdaysFor(String scheduleType) => switch (scheduleType) {
        'WEEKDAYS' => const [1, 2, 3, 4, 5],
        'WEEKENDS' => const [6, 7],
        // DAILY, and CUSTOM — which buildCreateSchedulePayload pins to all
        // seven days — are both every day.
        _ => const [],
      };

  /// First occurrence of [weekday] at or after [from], keeping the wall-clock
  /// time. The time is re-applied on each step rather than adding a fixed
  /// 24-hour duration, so a DST boundary can't drift the alarm by an hour.
  static tz.TZDateTime _nextOnWeekday(
    tz.TZDateTime from,
    int weekday,
    int hour,
    int minute,
    Duration lead,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var day = tz.TZDateTime(tz.local, from.year, from.month, from.day, hour, minute)
        .subtract(lead);
    var guard = 0;
    while ((day.weekday != weekday || !day.isAfter(now)) && guard < 14) {
      final next = day.add(lead).add(const Duration(days: 1));
      day = tz.TZDateTime(tz.local, next.year, next.month, next.day, hour, minute)
          .subtract(lead);
      guard++;
    }
    return day;
  }

  /// Never throws: a failed alarm must not fail the schedule creation that
  /// triggered it. The backend record and the push reminder both still exist,
  /// so surfacing this as a create failure would be misleading.
  static Future<void> _schedule({
    required int id,
    required String message,
    required tz.TZDateTime when,
    required DateTimeComponents? repeat,
  }) async {
    try {
      await _zonedSchedule(id, message, when, repeat);
      AppLogger.i(
        'Alarm set → id:$id at $when repeat:${repeat?.name ?? 'once'} '
        'exact:$_canUseExactAlarms',
        tag: 'Notification',
      );
    } catch (e, st) {
      AppLogger.e('Local alarm scheduling failed → id:$id',
          tag: 'Notification', error: e, stack: st);
    }
  }

  static Future<void> _zonedSchedule(
    int id,
    String message,
    tz.TZDateTime when,
    DateTimeComponents? repeat,
  ) {
    return _plugin.zonedSchedule(
      id,
      'Medicine Reminder',
      message,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Medicine dose alarms',
          importance: Importance.max,
          priority: Priority.max,
          styleInformation: BigTextStyleInformation(message),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          // Set on the notification too, not just the channel: a channel's
          // sound is fixed at creation, so this is what a device honours if
          // it resolved the channel sound differently.
          sound: const UriAndroidNotificationSound(_alarmSoundUri),
          playSound: true,
          // Tells the OS this is an alarm: it survives more aggressive
          // notification grouping and Do Not Disturb alarm exemptions.
          category: AndroidNotificationCategory.alarm,
          // Shows the alarm over the lock screen instead of a silent line in
          // the shade. Requires USE_FULL_SCREEN_INTENT in the manifest.
          fullScreenIntent: true,
          // FLAG_INSISTENT (4) — loops the sound until the user acts, which
          // is what makes it read as an alarm rather than a single chime.
          additionalFlags: Int32List.fromList(<int>[4]),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      // Falling back to inexact keeps reminders working (within a few
      // minutes) when the user declines exact alarms, instead of throwing.
      androidScheduleMode: _canUseExactAlarms
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeat,
      payload: message,
    );
  }

  /// Cancel all alarms for a given schedule (pass the dose IDs).
  static Future<void> cancelReminderAlarms(
    String scheduleId,
    List<String> doseIds,
  ) async {
    for (final doseId in doseIds) {
      await _plugin.cancel(_notifId(scheduleId, doseId));
      await _plugin.cancel(_catchUpNotifId(scheduleId, doseId));
      // Weekday variants are only created for WEEKDAYS/WEEKENDS, but the ids
      // are deterministic and cancelling an absent one is a no-op — cheaper
      // than threading the schedule type in just to cancel precisely.
      for (var weekday = 1; weekday <= 7; weekday++) {
        await _plugin.cancel(_notifId(scheduleId, doseId, weekday: weekday));
      }
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
    AppLogger.i(
      'Rescheduling all → ${schedules.length} schedule(s), '
      '${schedules.where((s) => s.isActive).length} active',
      tag: 'Notification',
    );
    for (final s in schedules) {
      if (!s.isActive) continue;
      await scheduleReminderAlarms(schedule: s, userName: userName);
    }
  }

  /// [weekday] distinguishes the per-weekday alarms a WEEKDAYS/WEEKENDS
  /// schedule needs; without it they would all collide on one id and only the
  /// last would survive.
  static int _notifId(String scheduleId, String doseId, {int? weekday}) =>
      ('$scheduleId$doseId${weekday ?? ''}').hashCode.abs() % 2147483647;

  /// Distinct id for the one-off late-lead reminder, so scheduling it can
  /// never overwrite the recurring alarm for the same dose.
  static int _catchUpNotifId(String scheduleId, String doseId) =>
      ('catchup:$scheduleId$doseId').hashCode.abs() % 2147483647;

}

// Top-level background handler required by flutter_local_notifications.
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse response) {
  // Background isolate: TTS requires a foreground context, so we just log.
  // The notification itself carries the full message text.
}
