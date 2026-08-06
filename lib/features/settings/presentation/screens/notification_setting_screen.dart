import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../../schedule/presentation/providers/reminders_provider.dart';

class NotificationSettingScreen extends ConsumerStatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  ConsumerState<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends ConsumerState<NotificationSettingScreen> {
  bool _medicine = true;
  bool _appointment = true;
  bool _refill = true;
  bool _water = false;
  bool _vitals = true;

  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _smsMessages = false;
  bool _vibration = true;
  bool _soundAlerts = true;

  bool _quietHoursEnabled = true;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 6, minute: 0);
  bool _allowEmergency = true;

  final String _snoozeMinutes = '10 minutes';
  final String _defaultAlertTone = 'CareDose Default';

  /// Null while the first check is in flight.
  bool? _exactAlarmsAllowed;
  Map<String, Object?>? _diagnostics;

  @override
  void initState() {
    super.initState();
    _checkExactAlarms();
  }

  Future<void> _checkExactAlarms() async {
    await NotificationService.refreshExactAlarmPermission();
    final diagnostics = await NotificationService.alarmDiagnostics();
    if (mounted) {
      setState(() {
        _exactAlarmsAllowed = NotificationService.canUseExactAlarms;
        _diagnostics = diagnostics;
      });
    }
  }

  Future<void> _testAlarm() async {
    await NotificationService.fireTestAlarm();
    if (!mounted) return;
    AppSnackbar.info(context, 'Test alarm will sound in 2 seconds');
  }

  Future<void> _grantExactAlarms() async {
    // Opens the system "Alarms & reminders" screen — Android has no in-app
    // dialog for this permission. The answer only lands once the user returns,
    // so re-check rather than trusting the call's result.
    await NotificationService.requestExactAlarmPermission();
    if (!mounted) return;
    await _checkExactAlarms();
    if (!mounted) return;
    if (NotificationService.canUseExactAlarms) {
      // Pending alarms were built in inexact mode — rebuild them so they move
      // onto exact delivery straight away.
      await ref.read(remindersProvider.notifier).load();
      if (mounted) {
        AppSnackbar.success(context, 'Exact reminders enabled');
      }
    }
  }

  void _save() {
    AppLogger.i('Notification settings saved', tag: 'Notifications');
    AppSnackbar.success(context, 'Reminder settings saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: 'Reminders & Notifications',
                leading: AppBarLeading.back,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => AppSnackbar.info(context, 'Search coming soon'),
                        child: const Icon(Icons.search_rounded, size: 20, color: AppColors.teal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Alarm diagnostics + test ──────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.labelMd('Alarm check'),
                            const SizedBox(height: 8),
                            if (_diagnostics case final d?) ...[
                              AppInfoLabelText(
                                icon: Icons.public_rounded,
                                label: 'Timezone',
                                value: '${d['timezone']}',
                              ),
                              AppInfoLabelText(
                                icon: Icons.alarm_on_rounded,
                                label: 'Exact alarms',
                                value: d['exactAlarms'] == true
                                    ? 'Allowed'
                                    : 'Not allowed',
                              ),
                              AppInfoLabelText(
                                icon: Icons.notifications_active_outlined,
                                label: 'Notifications',
                                value: d['notificationsEnabled'] == false
                                    ? 'Blocked'
                                    : 'Enabled',
                              ),
                              AppInfoLabelText(
                                icon: Icons.pending_actions_rounded,
                                label: 'Scheduled alarms',
                                value: '${d['pending']}',
                              ),
                            ],
                            const SizedBox(height: 12),
                            AppButton(
                              variant: AppButtonVariant.secondary,
                              label: 'Test alarm now',
                              leading: const Icon(Icons.volume_up_rounded,
                                  size: 18),
                              isFullWidth: true,
                              onPressed: _testAlarm,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Exact alarm permission ────────────────────────────
                      if (_exactAlarmsAllowed == false) ...[
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          color: AppColors.amber.withValues(alpha: 0.08),
                          borderColor: AppColors.amber.withValues(alpha: 0.3),
                          effectColor: AppColors.amber,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.alarm_off_rounded,
                                      size: 18, color: AppColors.amber),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppText.labelMd(
                                        'Reminders may arrive late'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AppText.bodySm(
                                'Android is holding your dose alarms in battery-saving mode, '
                                'which can delay them by several minutes. Allow exact alarms '
                                'so they fire on time.',
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                variant: AppButtonVariant.primary,
                                label: 'Allow exact alarms',
                                isFullWidth: true,
                                onPressed: _grantExactAlarms,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── All Reminders Active Status ────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        hasShadow: true,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.teal,
                                      width: 4,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications_active_rounded,
                                      size: 40,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // Claiming "active" while the OS is
                                        // throttling the alarms would be a
                                        // lie the user can act on.
                                        _exactAlarmsAllowed == false
                                            ? 'Reminders are\ndelayed'
                                            : 'All reminders are\nactive',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Next reminder in 1 hour\n25 minutes',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.secondaryText,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.teal.withValues(alpha: 0.1),
                                          borderRadius: AppBorderRadius.pill,
                                        ),
                                        child: Text(
                                          _exactAlarmsAllowed == false
                                              ? 'NEEDS ATTENTION'
                                              : 'ON TRACK',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.teal,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Active Preview ─────────────────────────────────────
                      const Text(
                        'Active Preview',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                size: 20,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time for Paracetamol',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '1 Tablet • 500mg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '8:00 AM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: context.secondaryText,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Completion Rate & Stats ───────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: CircularProgressIndicator(
                                          value: 0.75,
                                          strokeWidth: 6,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.teal,
                                          ),
                                          backgroundColor:
                                              AppColors.teal.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      const Text(
                                        '75%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Completion Rate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Today',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '12',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Completed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '9',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Pending',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '3',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Reminder Categories ────────────────────────────────
                      const Text(
                        'Reminder Categories',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryToggle(
                        'Medicine',
                        'Daily dosage & refill alerts',
                        _medicine,
                        (val) => setState(() => _medicine = val),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryToggle(
                        'Appointment',
                        'Doctor visits & labs',
                        _appointment,
                        (val) => setState(() => _appointment = val),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryToggle(
                        'Refill',
                        'Low stock notifications',
                        _refill,
                        (val) => setState(() => _refill = val),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryToggle(
                        'Water',
                        'Hydration interval reminders',
                        _water,
                        (val) => setState(() => _water = val),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryToggle(
                        'Vitals',
                        'Blood pressure & heart rate',
                        _vitals,
                        (val) => setState(() => _vitals = val),
                      ),
                      const SizedBox(height: 28),

                      // ── Delivery Channels ──────────────────────────────────
                      const Text(
                        'Delivery Channels',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildChannelCheckbox(
                              'Push Notifications',
                              Icons.notifications_rounded,
                              _pushNotifications,
                              (val) => setState(() => _pushNotifications = val),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            _buildChannelCheckbox(
                              'Email Alerts',
                              Icons.mail_outline_rounded,
                              _emailAlerts,
                              (val) => setState(() => _emailAlerts = val),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            _buildChannelCheckbox(
                              'SMS Messages',
                              Icons.sms_outlined,
                              _smsMessages,
                              (val) => setState(() => _smsMessages = val),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            _buildChannelCheckbox(
                              'Vibration',
                              Icons.vibration,
                              _vibration,
                              (val) => setState(() => _vibration = val),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            _buildChannelCheckbox(
                              'Sound Alerts',
                              Icons.volume_up_rounded,
                              _soundAlerts,
                              (val) => setState(() => _soundAlerts = val),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Default Alert Tone ────────────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 20,
                                  color: AppColors.teal,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Default Alert Tone',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _defaultAlertTone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: context.secondaryText,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Snooze Duration ───────────────────────────────────
                      const Text(
                        'Snooze Duration',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _snoozeMinutes,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Icon(
                              Icons.expand_more_rounded,
                               size: 18,
                              color: AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Quiet Hours ───────────────────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.nights_stay_rounded,
                                      size: 20,
                                      color: context.secondaryText,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Quiet Hours',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Transform.scale(
                                  scale: 0.85,
                                  child: Switch(
                                    value: _quietHoursEnabled,
                                    onChanged: (val) =>
                                        setState(() => _quietHoursEnabled = val),
                                    activeThumbColor: AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                            if (_quietHoursEnabled) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'START',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textHint,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'END',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textHint,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTimePickerInput(
                                      value: _quietStartTime,
                                      onChanged: (t) => setState(() => _quietStartTime = t),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTimePickerInput(
                                      value: _quietEndTime,
                                      onChanged: (t) => setState(() => _quietEndTime = t),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Checkbox(
                                      value: _allowEmergency,
                                      onChanged: (val) =>
                                          setState(() => _allowEmergency = val ?? true),
                                      activeColor: AppColors.teal,
                                      side: BorderSide(
                                        color: context.borderCol,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Allow Emergency Notifications',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Save Button ────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Save Reminder Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCheckbox(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Checkbox(
              value: value,
              onChanged: (val) => onChanged(val ?? false),
              activeColor: AppColors.teal,
              side: BorderSide(color: context.borderCol),
            ),
          ),
        ],
      ),
    );
  }
}
