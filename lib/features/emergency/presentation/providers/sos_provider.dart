import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/sos_native_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import 'emergency_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum SosPhase { idle, triggering, active }

class SosState {
  const SosState({
    this.phase = SosPhase.idle,
    this.sosId,
    this.triggeredAt,
    this.alarmPlaying = false,
    this.smsResults = const {},
    this.notifiedContacts = const [],
    this.smsUnavailableReason,
    this.backendSynced = false,
    this.cancelled = false,
  });

  final SosPhase phase;

  /// Backend SosLog id — null while offline (trigger still works locally).
  final String? sosId;
  final DateTime? triggeredAt;
  final bool alarmPlaying;

  /// phone → "sent" | `failed:<reason>` from the native SMS send.
  final Map<String, String> smsResults;
  final List<EmergencyContactEntity> notifiedContacts;

  /// Non-null when SMS could not even be attempted (no SIM / permission denied).
  final String? smsUnavailableReason;
  final bool backendSynced;
  final bool cancelled;

  SosState copyWith({
    SosPhase? phase,
    String? sosId,
    DateTime? triggeredAt,
    bool? alarmPlaying,
    Map<String, String>? smsResults,
    List<EmergencyContactEntity>? notifiedContacts,
    String? smsUnavailableReason,
    bool? backendSynced,
    bool? cancelled,
  }) =>
      SosState(
        phase: phase ?? this.phase,
        sosId: sosId ?? this.sosId,
        triggeredAt: triggeredAt ?? this.triggeredAt,
        alarmPlaying: alarmPlaying ?? this.alarmPlaying,
        smsResults: smsResults ?? this.smsResults,
        notifiedContacts: notifiedContacts ?? this.notifiedContacts,
        smsUnavailableReason: smsUnavailableReason ?? this.smsUnavailableReason,
        backendSynced: backendSynced ?? this.backendSynced,
        cancelled: cancelled ?? this.cancelled,
      );

  /// Full cancel (false-alarm notice) is locked for the first 5 s so panic
  /// tapping right after a trigger can't silently retract the alert.
  static const cancelLock = Duration(seconds: 5);

  bool get canCancel =>
      phase == SosPhase.active &&
      !cancelled &&
      triggeredAt != null &&
      DateTime.now().difference(triggeredAt!) >= cancelLock;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SosNotifier extends StateNotifier<SosState> {
  SosNotifier(this._ref, this._native) : super(const SosState());

  final Ref _ref;
  final SosNativeService _native;

  String get _patientName =>
      _ref.read(authProvider).user?.name ?? 'A Curalee patient';

  /// Fires the SOS: local alarm + native SMS to every contact + backend log
  /// (which fans out FCM). Alarm and SMS have no network dependency; the
  /// backend call is best-effort and failure never blocks the local alert.
  Future<void> trigger() async {
    if (state.phase == SosPhase.active || state.phase == SosPhase.triggering) {
      return; // debounce rapid re-triggers
    }
    final contacts = _ref.read(emergencyProvider).contacts;
    state = SosState(
      phase: SosPhase.triggering,
      triggeredAt: DateTime.now(),
      notifiedContacts: contacts,
    );

    // 1. Alarm first — fully local, must sound no matter what else fails.
    final alarmOk = await _native.startAlarm();
    state = state.copyWith(phase: SosPhase.active, alarmPlaying: alarmOk);

    // 2. Location — best effort, only if already granted; never prompts here.
    final position = await _currentPositionOrNull();

    // 3. Native SMS to all contacts (raw cellular, no data needed).
    await _sendTriggerSms(contacts, position);

    // 4. Backend log + FCM fan-out (needs network; tolerate offline).
    try {
      final sosId = await _ref.read(emergencyRepositoryProvider).triggerSos(
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
      if (!mounted) return;
      state = state.copyWith(sosId: sosId, backendSynced: sosId != null);
    } catch (e) {
      AppLogger.e('SOS backend sync failed (offline?)', tag: 'SOS', error: e);
    }
  }

  Future<void> _sendTriggerSms(
    List<EmergencyContactEntity> contacts,
    Position? position,
  ) async {
    if (contacts.isEmpty) {
      state = state.copyWith(smsUnavailableReason: 'No emergency contacts saved');
      return;
    }
    final reason = await _smsBlockedReason();
    if (reason != null) {
      state = state.copyWith(smsUnavailableReason: reason);
      return;
    }

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final location = position != null
        ? ' Location: https://maps.google.com/?q=${position.latitude},${position.longitude}.'
        : '';
    final message =
        '$_patientName has triggered an SOS alert via Curalee at $time.$location'
        ' Please check on them immediately.';

    final results = await _native.sendSms(
      phones: contacts.map((c) => c.phone).toList(),
      message: message,
    );
    if (!mounted) return;
    state = state.copyWith(smsResults: results);
  }

  /// Stops only the siren. Deliberately does NOT cancel the alert —
  /// silencing the noise must never silently retract the call for help.
  Future<void> stopAlarm() async {
    await _native.stopAlarm();
    if (!mounted) return;
    state = state.copyWith(alarmPlaying: false);
  }

  /// Full "false alarm" cancel: follow-up SMS to everyone we texted, and
  /// backend cancel (false-alarm push to contacts who are app users).
  Future<void> cancel() async {
    if (!state.canCancel) return;
    state = state.copyWith(cancelled: true);
    await stopAlarm();

    final message =
        "$_patientName's SOS alert was a false alarm / has been cancelled.";

    final sentPhones = state.smsResults.entries
        .where((e) => e.value == 'sent')
        .map((e) => e.key)
        .toList();
    if (sentPhones.isNotEmpty && await _smsBlockedReason() == null) {
      await _native.sendSms(phones: sentPhones, message: message);
    }

    final sosId = state.sosId;
    if (sosId != null) {
      try {
        await _ref.read(emergencyRepositoryProvider).cancelSos(sosId);
      } catch (e) {
        AppLogger.e('SOS cancel sync failed', tag: 'SOS', error: e);
      }
    }
  }

  /// Back to idle. Alarm is stopped defensively in case it is still sounding.
  Future<void> dismiss() async {
    await _native.stopAlarm();
    if (!mounted) return;
    state = const SosState();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns null when SMS can be attempted, else a human-readable blocker.
  Future<String?> _smsBlockedReason() async {
    if (!await _native.hasSmsSupport()) {
      return 'This device cannot send SMS (no SIM or no cellular support)';
    }
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      // Ideally granted during setup; last-ditch prompt at trigger time.
      status = await Permission.sms.request();
    }
    if (!status.isGranted) return 'SMS permission not granted';
    return null;
  }

  Future<Position?> _currentPositionOrNull() async {
    try {
      final permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) return null;
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (_) {
      return null; // degrade gracefully — SMS just omits the location link
    }
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>(
  (ref) => SosNotifier(ref, const SosNativeService()),
);
