import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

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

class _EmergencyContact {
  final String id;
  final String name;
  final String relation;
  final String phone;

  const _EmergencyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kProfile = _HealthProfile(
  bloodGroup: 'B+',
  allergies: ['Penicillin', 'Aspirin'],
  conditions: ['Hypertension', 'Type 2 Diabetes'],
  medications: ['Metformin 500mg', 'Amlodipine 5mg'],
  notes: 'Patient uses insulin pump. Do not administer NSAIDs.',
);

const _kContacts = [
  _EmergencyContact(id: 'ec1', name: 'Priya Sharma', relation: 'Spouse', phone: '+91 98765 43210'),
  _EmergencyContact(id: 'ec2', name: 'Amit Sharma', relation: 'Son', phone: '+91 87654 32109'),
  _EmergencyContact(id: 'ec3', name: 'Dr. R. Patel', relation: 'Family Doctor', phone: '+91 76543 21098'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                title: Text(AppStrings.emergency, style: AppTypography.h3),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Subtitle
                  Text(
                    AppStrings.emergencySubtitle2,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // SOS button section
                  _SosCard(),
                  const SizedBox(height: 16),

                  // Health profile
                  _HealthProfileCard(profile: _kProfile),
                  const SizedBox(height: 16),

                  // Emergency contacts
                  _ContactsCard(contacts: _kContacts),
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
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.red),
              const SizedBox(width: 8),
              Text(AppStrings.sosTitle, style: AppTypography.h3.copyWith(color: context.primaryText)),
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
                    style: AppTypography.display2.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: 2,
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
                    style: AppTypography.display1.copyWith(color: Colors.white, fontSize: 52),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppStrings.sosSendingIn} $_count…',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _cancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.inputBg,
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      style: AppTypography.buttonSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
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
                  style: AppTypography.labelLg.copyWith(color: AppColors.red),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.sosContactsNotified,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.inputBg,
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Text(
                      AppStrings.dismiss,
                      style: AppTypography.buttonSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
        },

        if (_state == _SosState.idle) ...[
          const SizedBox(height: 14),
          Text(
            AppStrings.sosIdleHint,
            style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
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
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.healthProfileTitle, style: AppTypography.h3),
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
                      style: AppTypography.overline.copyWith(color: AppColors.red, letterSpacing: 1.2),
                    ),
                    Text(
                      profile.bloodGroup,
                      style: AppTypography.display2.copyWith(color: context.primaryText, fontSize: 26),
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
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5),
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
          style: AppTypography.overline.copyWith(color: color, letterSpacing: 1.2),
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
                    child: Text(
                      t,
                      style: AppTypography.labelXs.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Contacts Card ────────────────────────────────────────────────────────────

class _ContactsCard extends StatelessWidget {
  final List<_EmergencyContact> contacts;
  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppStrings.emergencyContacts, style: AppTypography.h3),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, size: 13, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.add,
                        style: AppTypography.labelSm.copyWith(color: AppColors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            Text(
              AppStrings.noEmergencyContacts,
              style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
            )
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
  final _EmergencyContact contact;
  const _ContactTile({required this.contact});

  String get _initials {
    final parts = contact.name.split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.borderCol,
              borderRadius: AppBorderRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: AppTypography.labelMd),
                const SizedBox(height: 2),
                Text(contact.relation, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                Text(contact.phone, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.lgAll,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.phone_rounded, size: 18, color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(color: context.borderCol),
        ),
        child: child,
      );
}
