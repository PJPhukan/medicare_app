import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/sos_native_service.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/bottom_sheets/app_base_bottom_sheet.dart';
import '../../../../shared/widgets/inputs/chip_tag_input.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/entities/emergency_profile_entity.dart';
import '../providers/emergency_provider.dart';
import '../providers/sos_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergency = ref.watch(emergencyProvider);
    final contacts = emergency.contacts;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: AppText.h3(AppStrings.emergency),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AppText.bodySm(AppStrings.emergencySubtitle2,
                      color: AppColors.textSecondary),
                  const SizedBox(height: 24),
                  const _SosCard(),
                  const SizedBox(height: 16),
                  _HealthProfileCard(profile: emergency.profile),
                  const SizedBox(height: 16),
                  _ContactsCard(contacts: contacts),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SOS Card ─────────────────────────────────────────────────────────────────

class _SosCard extends ConsumerWidget {
  const _SosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sos = ref.watch(sosProvider);
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.red),
              const SizedBox(width: 8),
              AppText.h3(AppStrings.sosTitle),
            ],
          ),
          const SizedBox(height: 24),
          if (sos.phase == SosPhase.idle)
            const _SosHoldButton()
          else
            const _ActiveSosView(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Hold-to-trigger button (2 s radial fill) ─────────────────────────────────

class _SosHoldButton extends ConsumerStatefulWidget {
  const _SosHoldButton();

  @override
  ConsumerState<_SosHoldButton> createState() => _SosHoldButtonState();
}

class _SosHoldButtonState extends ConsumerState<_SosHoldButton>
    with TickerProviderStateMixin {
  static const _holdDuration = Duration(seconds: 2);

  late final AnimationController _holdCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _holdCtrl = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _trigger();
      });
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _holdCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _armed => ref.read(emergencyProvider).contacts.isNotEmpty;

  void _onHoldStart() {
    if (!_armed) return;
    HapticFeedback.heavyImpact();
    _holdCtrl.forward(from: 0);
  }

  void _onHoldEnd() {
    if (_holdCtrl.status == AnimationStatus.forward) {
      _holdCtrl.reverse();
    }
  }

  void _trigger() {
    HapticFeedback.heavyImpact();
    ref.read(sosProvider.notifier).trigger();
  }

  @override
  Widget build(BuildContext context) {
    final armed = ref.watch(emergencyProvider).contacts.isNotEmpty;
    final color = armed ? AppColors.red : AppColors.textHint;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _onHoldStart(),
          onTapUp: (_) => _onHoldEnd(),
          onTapCancel: _onHoldEnd,
          child: ScaleTransition(
            scale: _pulse,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Radial fill while holding
                  AnimatedBuilder(
                    animation: _holdCtrl,
                    builder: (_, __) => SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _holdCtrl.value,
                        strokeWidth: 6,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      AppStrings.sos,
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppText.bodySm(
          armed ? AppStrings.sosHoldHint : AppStrings.sosNeedContact,
          color: armed ? AppColors.textHint : AppColors.amber,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Active SOS view (alarm sounding / sent state) ────────────────────────────

class _ActiveSosView extends ConsumerStatefulWidget {
  const _ActiveSosView();

  @override
  ConsumerState<_ActiveSosView> createState() => _ActiveSosViewState();
}

class _ActiveSosViewState extends ConsumerState<_ActiveSosView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Ticks once a second so the cancel-lock countdown updates.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int _cancelLockRemaining(SosState sos) {
    if (sos.triggeredAt == null) return 0;
    final elapsed = DateTime.now().difference(sos.triggeredAt!);
    final remaining = SosState.cancelLock - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds + 1;
  }

  @override
  Widget build(BuildContext context) {
    final sos = ref.watch(sosProvider);
    final notifier = ref.read(sosProvider.notifier);
    final lockRemaining = _cancelLockRemaining(sos);

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFB91C1C),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.red.withValues(alpha: 0.6), width: 6),
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withValues(alpha: 0.55),
                blurRadius: 56,
                spreadRadius: 10,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            sos.cancelled ? Icons.check_rounded : Icons.shield_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sos.cancelled ? AppStrings.sosCancelled : '🚨 ${AppStrings.sosSent}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: AppColors.red,
          ),
        ),

        if (sos.smsUnavailableReason != null) ...[
          const SizedBox(height: 8),
          AppText.bodySm('⚠️ ${sos.smsUnavailableReason!}',
              color: AppColors.amber, textAlign: TextAlign.center),
        ],

        // Who was notified
        if (sos.notifiedContacts.isNotEmpty) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText.labelSm(AppStrings.sosWhoWasNotified,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...sos.notifiedContacts.map((c) {
            final smsStatus = sos.smsResults[c.phone];
            final (label, color) = switch (smsStatus) {
              'sent' => (AppStrings.sosSmsSent, AppColors.green),
              null => ('—', AppColors.textHint),
              _ => (AppStrings.sosSmsFailed, AppColors.red),
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: AppText.bodySm(c.name)),
                  AppText.labelXs(label, color: color),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 16),

        // STOP ALARM — local and instant, never cancels the alert itself.
        if (sos.alarmPlaying)
          AppButton(
            label: AppStrings.sosStopAlarm,
            variant: AppButtonVariant.primary,
            color: AppColors.red,
            isFullWidth: true,
            onPressed: () => notifier.stopAlarm(),
          ),

        if (!sos.cancelled) ...[
          const SizedBox(height: 10),
          // Deliberately amber/outline — must read as a distinct, calmer action
          // from the solid-red STOP ALARM button above, since it does something
          // STOP ALARM doesn't: tells contacts the alert was a false alarm.
          AppButton(
            label: lockRemaining > 0
                ? '${AppStrings.sosCancelFalseAlarm} ($lockRemaining)'
                : AppStrings.sosCancelFalseAlarm,
            variant: AppButtonVariant.outline,
            color: AppColors.amber,
            leading: const Icon(Icons.flag_outlined, size: 14, color: AppColors.amber),
            size: AppButtonSize.sm,
            onPressed: sos.canCancel ? () => notifier.cancel() : null,
          ),
        ] else ...[
          const SizedBox(height: 10),
          AppButton(
            label: AppStrings.dismiss,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            onPressed: () => notifier.dismiss(),
          ),
        ],

        if (!sos.cancelled && !sos.alarmPlaying) ...[
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => notifier.dismiss(),
            child: AppText.bodySm(AppStrings.dismiss, color: AppColors.textHint),
          ),
        ],
      ],
    );
  }
}

// ─── Health Profile Card ──────────────────────────────────────────────────────

class _HealthProfileCard extends ConsumerWidget {
  final EmergencyProfileEntity? profile;
  const _HealthProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = this.profile;
    if (profile == null || profile.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCardHeader(profile: profile, ref: ref),
            const SizedBox(height: 12),
            AppText.bodySm(AppStrings.emergencyDataNote,
                color: AppColors.textHint),
          ],
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileCardHeader(profile: profile, ref: ref),
          const SizedBox(height: 16),

          // Blood group
          if (profile.bloodGroup != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🩸', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.bloodGroup.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppColors.red, letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      profile.bloodGroup!,
                      style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: context.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (profile.allergies.isNotEmpty) ...[
            const SizedBox(height: 14),
            _TagSection(label: AppStrings.allergiesLabel, tags: profile.allergies, color: AppColors.red),
          ],
          if (profile.conditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TagSection(label: AppStrings.conditionsLabel, tags: profile.conditions, color: AppColors.amber),
          ],
          if (profile.medications.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TagSection(label: AppStrings.criticalMedsLabel, tags: profile.medications, color: AppColors.blue),
          ],
          if (profile.notes != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: Text(
                profile.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileCardHeader extends StatelessWidget {
  final EmergencyProfileEntity? profile;
  final WidgetRef ref;
  const _ProfileCardHeader({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText.h3(AppStrings.healthProfileTitle)),
        GestureDetector(
          onTap: () => _showProfileSheet(context, ref, existing: profile),
          child: AppContainer.tinted(
            color: AppColors.blue,
            borderRadius: AppBorderRadius.lgAll,
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.blue),
          ),
        ),
      ],
    );
  }
}

// ─── Edit health profile bottom sheet ─────────────────────────────────────────

Future<void> _showProfileSheet(
  BuildContext context,
  WidgetRef ref, {
  EmergencyProfileEntity? existing,
}) async {
  await showAppBottomSheet<bool>(
    context: context,
    title: AppStrings.editHealthProfile,
    child: _ProfileForm(existing: existing),
  );
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({this.existing});

  final EmergencyProfileEntity? existing;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _bloodGroup;
  late final TextEditingController _notes;
  late List<String> _allergies;
  late List<String> _conditions;
  late List<String> _medications;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _bloodGroup = TextEditingController(text: p?.bloodGroup ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    _allergies = List.from(p?.allergies ?? const []);
    _conditions = List.from(p?.conditions ?? const []);
    _medications = List.from(p?.medications ?? const []);
  }

  @override
  void dispose() {
    _bloodGroup.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bloodGroup = _bloodGroup.text.trim();
      final notes = _notes.text.trim();
      await ref.read(emergencyProvider.notifier).updateProfile(
            bloodGroup: bloodGroup.isEmpty ? null : bloodGroup,
            allergies: _allergies,
            medications: _medications,
            conditions: _conditions,
            notes: notes.isEmpty ? null : notes,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save — please try again';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _bloodGroup,
          label: AppStrings.bloodGroup,
          hint: AppStrings.bloodGroupHint,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppChipTagInput(
          label: AppStrings.allergiesLabel,
          hint: AppStrings.allergiesHint,
          color: AppColors.red,
          initialTags: _allergies,
          onChanged: (tags) => _allergies = tags,
        ),
        const SizedBox(height: 14),
        AppChipTagInput(
          label: AppStrings.conditionsLabel,
          hint: AppStrings.conditionsHint,
          color: AppColors.amber,
          initialTags: _conditions,
          onChanged: (tags) => _conditions = tags,
        ),
        const SizedBox(height: 14),
        AppChipTagInput(
          label: AppStrings.criticalMedsLabel,
          hint: AppStrings.criticalMedsHint,
          color: AppColors.blue,
          initialTags: _medications,
          onChanged: (tags) => _medications = tags,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _notes,
          label: AppStrings.notesLabel,
          hint: AppStrings.notesHint,
          maxLines: 3,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          AppText.bodySm(_error!, color: AppColors.red),
        ],
        const SizedBox(height: 18),
        AppButton(
          label: AppStrings.save,
          isFullWidth: true,
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  const _TagSection({required this.label, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: color, letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: tags
              .map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: AppText.labelXs(t, color: color, fontWeight: FontWeight.w600),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Contacts Card ────────────────────────────────────────────────────────────

class _ContactsCard extends ConsumerWidget {
  final List<EmergencyContactEntity> contacts;
  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.h3(AppStrings.emergencyContacts),
              const Spacer(),
              GestureDetector(
                onTap: () => _showContactSheet(context, ref),
                child: AppContainer.tinted(
                  color: AppColors.green,
                  borderRadius: AppBorderRadius.lgAll,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 13, color: AppColors.green),
                      const SizedBox(width: 4),
                      AppText.labelSm(AppStrings.add, color: AppColors.green),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            AppText.bodySm(AppStrings.noEmergencyContacts, color: AppColors.textHint)
          else
            ...contacts.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContactTile(contact: c),
                )),
        ],
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  final EmergencyContactEntity contact;
  const _ContactTile({required this.contact});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteContactTitle),
        content: const Text(AppStrings.deleteContactBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete,
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(emergencyProvider.notifier).deleteContact(contact.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showContactSheet(context, ref, existing: contact),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AppAvatar(name: contact.name, size: AppAvatarSize.sm),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelMd(contact.name),
                  const SizedBox(height: 2),
                  if (contact.relationship != null)
                    AppText.bodySm(contact.relationship!,
                        color: AppColors.textSecondary),
                  AppText.bodyXs(contact.phone, color: AppColors.textHint),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _confirmDelete(context, ref),
              child: AppContainer.tinted(
                color: AppColors.red,
                borderRadius: AppBorderRadius.lgAll,
                padding: const EdgeInsets.all(11),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add / edit contact bottom sheet ──────────────────────────────────────────

const _kRelationships = ['Family', 'Nurse', 'Neighbor', 'Other'];

Future<void> _showContactSheet(
  BuildContext context,
  WidgetRef ref, {
  EmergencyContactEntity? existing,
}) async {
  final saved = await showAppBottomSheet<bool>(
    context: context,
    title: existing == null
        ? AppStrings.addEmergencyContact
        : AppStrings.editEmergencyContact,
    child: _ContactForm(existing: existing),
  );
  // A saved contact arms SOS — get SMS permission and battery exemption now,
  // with rationale, instead of mid-emergency.
  if (saved == true && context.mounted) {
    await _ensureSosPermissions(context);
  }
}

/// Asks for SEND_SMS (with rationale) and battery-optimization exemption so
/// the SOS SMS and alarm service work reliably when actually needed.
Future<void> _ensureSosPermissions(BuildContext context) async {
  const native = SosNativeService();

  if (!await Permission.sms.isGranted) {
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow SMS for SOS'),
        content: const Text(
          'When you trigger SOS, Curalee sends an SMS directly to your '
          'emergency contacts — even without internet. Allow SMS so alerts '
          'can go out in an emergency.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed == true) await Permission.sms.request();
  }

  if (!await native.isIgnoringBatteryOptimizations()) {
    await native.requestIgnoreBatteryOptimizations();
  }
}

class _ContactForm extends ConsumerStatefulWidget {
  const _ContactForm({this.existing});

  final EmergencyContactEntity? existing;

  @override
  ConsumerState<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<_ContactForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _priority;
  String? _relationship;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _priority = TextEditingController(text: (c?.priority ?? 0).toString());
    _relationship =
        _kRelationships.contains(c?.relationship) ? c?.relationship : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _priority.dispose();
    super.dispose();
  }

  // Backend validates strict E.164; mirror it here for instant feedback.
  static final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

  Future<void> _save() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (!_e164.hasMatch(phone)) {
      setState(() => _error = 'Phone must be in international format, e.g. +919876543210');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final notifier = ref.read(emergencyProvider.notifier);
      final priority = int.tryParse(_priority.text.trim()) ?? 0;
      if (widget.existing == null) {
        await notifier.addContact(
          name: name,
          phone: phone,
          relationship: _relationship,
          priority: priority,
        );
      } else {
        await notifier.updateContact(
          id: widget.existing!.id,
          name: name,
          phone: phone,
          relationship: _relationship,
          priority: priority,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save contact — please try again';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _name,
          label: AppStrings.name,
          hint: 'e.g. Anita Sharma',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _phone,
          label: AppStrings.phone,
          hint: '+919876543210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppText.labelSm(AppStrings.relationshipLabel,
            color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _kRelationships.map((r) {
            final selected = _relationship == r;
            return ChoiceChip(
              label: Text(r),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _relationship = selected ? null : r),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _priority,
          label: AppStrings.priorityLabel,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          AppText.bodySm(_error!, color: AppColors.red),
        ],
        const SizedBox(height: 18),
        AppButton(
          label: AppStrings.save,
          isFullWidth: true,
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
