import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import '../providers/emergency_provider.dart';

// ─── Health profile model (local static data) ─────────────────────────────────

class _HealthProfile {
  final String bloodGroup;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final String? notes;

  const _HealthProfile({
    required this.bloodGroup,
    required this.allergies,
    required this.conditions,
    required this.medications,
    this.notes,
  });
}

const _kProfile = _HealthProfile(
  bloodGroup: 'B+',
  allergies: ['Penicillin', 'Aspirin'],
  conditions: ['Hypertension', 'Type 2 Diabetes'],
  medications: ['Metformin 500mg', 'Amlodipine 5mg'],
  notes: 'Patient uses insulin pump. Do not administer NSAIDs.',
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(emergencyProvider).contacts;
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
                  _SosCard(),
                  const SizedBox(height: 16),
                  _HealthProfileCard(profile: _kProfile),
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

class _SosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const _SosButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

enum _SosState { idle, countdown, triggered }

class _SosButton extends StatefulWidget {
  const _SosButton();

  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton> with SingleTickerProviderStateMixin {
  _SosState _state = _SosState.idle;
  int _count = 3;
  Timer? _timer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_state != _SosState.idle) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _state = _SosState.countdown;
      _count = 3;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _count--);
      if (_count <= 0) {
        t.cancel();
        _trigger();
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _state = _SosState.idle;
      _count = 3;
    });
  }

  void _trigger() {
    HapticFeedback.heavyImpact();
    setState(() => _state = _SosState.triggered);
  }

  void _dismiss() => setState(() {
        _state = _SosState.idle;
        _count = 3;
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        switch (_state) {
          _SosState.idle => GestureDetector(
              onLongPressStart: (_) => _start(),
              child: ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.35), width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withValues(alpha: 0.35),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.sos,
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          _SosState.countdown => Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.5), width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withValues(alpha: 0.45),
                        blurRadius: 48,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_count',
                    style: const TextStyle(
                      fontSize: 52, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppText.bodySm('${AppStrings.sosSendingIn} $_count…',
                    color: AppColors.textSecondary),
                const SizedBox(height: 10),
                AppButton.outline(
                  label: AppStrings.cancel,
                  size: AppButtonSize.sm,
                  onPressed: _cancel,
                ),
              ],
            ),
          _SosState.triggered => Column(
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
                  child: const Icon(Icons.shield_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '🚨 ${AppStrings.sosActivated}',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 6),
                AppText.bodySm(
                  AppStrings.sosContactsNotified,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                AppButton.outline(
                  label: AppStrings.dismiss,
                  size: AppButtonSize.sm,
                  onPressed: _dismiss,
                ),
              ],
            ),
        },

        if (_state == _SosState.idle) ...[
          const SizedBox(height: 14),
          AppText.bodySm(AppStrings.sosIdleHint,
              color: AppColors.textHint,
              textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

// ─── Health Profile Card ──────────────────────────────────────────────────────

class _HealthProfileCard extends StatelessWidget {
  final _HealthProfile profile;
  const _HealthProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h3(AppStrings.healthProfileTitle),
          const SizedBox(height: 16),

          // Blood group
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
                      profile.bloodGroup,
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

class _ContactsCard extends StatelessWidget {
  final List<EmergencyContactEntity> contacts;
  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
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
                onTap: () {},
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

class _ContactTile extends StatelessWidget {
  final EmergencyContactEntity contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
            onTap: () {},
            child: AppContainer.tinted(
              color: AppColors.green,
              borderRadius: AppBorderRadius.lgAll,
              padding: const EdgeInsets.all(11),
              child: const Icon(Icons.phone_rounded, size: 18, color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}
