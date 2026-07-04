import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Args ─────────────────────────────────────────────────────────────────────

class PatientDetailArgs {
  final String name;
  final String condition;
  final String since;
  final Color avatarColor;
  final String accessLevel;

  const PatientDetailArgs({
    required this.name,
    required this.condition,
    required this.since,
    required this.avatarColor,
    required this.accessLevel,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PatientDetailScreen extends StatefulWidget {
  final PatientDetailArgs patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final isFullAccess = p.accessLevel == AppStrings.fullAccess;
    final accessColor = isFullAccess ? AppColors.teal : AppColors.amber;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 220,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      children: [
                        AppAvatar(name: p.name, size: AppAvatarSize.xl),
                        const SizedBox(height: 12),
                        Text(
                          p.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        AppText.bodySm(p.condition, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppContainer.tinted(
                              color: accessColor,
                              borderRadius: AppBorderRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              child: AppText.labelXs(p.accessLevel, color: accessColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '· Since ${p.since}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  color: context.bg,
                  child: TabBar(
                    controller: _tab,
                    indicatorColor: AppColors.teal,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.teal,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Vitals'),
                      Tab(text: 'Medicines'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: [
              _OverviewTab(patient: p),
              _VitalsTab(isFullAccess: isFullAccess),
              _MedicinesTab(isFullAccess: isFullAccess),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PatientDetailArgs patient;
  const _OverviewTab({required this.patient});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('HEALTH SUMMARY'),
                const SizedBox(height: 12),
                _SummaryRow(icon: Icons.monitor_heart_outlined, color: AppColors.blue, label: 'Blood Pressure', value: '128/84 mmHg', status: 'Warning', statusColor: AppColors.amber),
                const SizedBox(height: 8),
                _SummaryRow(icon: Icons.water_drop_outlined, color: AppColors.teal, label: 'Blood Sugar', value: '142 mg/dL', status: 'High', statusColor: AppColors.error),
                const SizedBox(height: 8),
                _SummaryRow(icon: Icons.medication_rounded, color: AppColors.purple, label: 'Adherence', value: '82%', status: 'Good', statusColor: AppColors.green),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('RECENT ACTIVITY'),
                const SizedBox(height: 12),
                _ActivityRow(icon: Icons.check_circle_rounded, color: AppColors.green, text: 'Metformin 500mg taken at 8:00 AM', time: '2h ago'),
                const SizedBox(height: 8),
                _ActivityRow(icon: Icons.cancel_rounded, color: AppColors.error, text: 'Amlodipine 5mg missed at 12:00 PM', time: '4h ago'),
                const SizedBox(height: 8),
                _ActivityRow(icon: Icons.monitor_heart_rounded, color: AppColors.blue, text: 'Blood pressure logged: 128/84', time: '6h ago'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('PERMISSIONS'),
                const SizedBox(height: 12),
                Text(
                  patient.accessLevel == AppStrings.fullAccess
                      ? 'You have full access to view vitals, medicines, reports and schedule.'
                      : 'You have read-only access to vitals and reports only.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      );
}

// ─── Vitals tab ───────────────────────────────────────────────────────────────

class _VitalsTab extends StatelessWidget {
  final bool isFullAccess;
  const _VitalsTab({required this.isFullAccess});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('BLOOD PRESSURE'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VitalChip(label: AppStrings.systolic, value: '128', unit: AppStrings.mmHg, color: AppColors.amber),
                    const SizedBox(width: 10),
                    _VitalChip(label: AppStrings.diastolic, value: '84', unit: AppStrings.mmHg, color: AppColors.blue),
                    const SizedBox(width: 10),
                    _VitalChip(label: AppStrings.heartRate, value: '76', unit: AppStrings.bpm, color: AppColors.purple),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.bodyXs('Logged today at 9:00 AM', color: AppColors.textHint),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('BLOOD SUGAR'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VitalChip(label: 'Fasting', value: '142', unit: AppStrings.mgDl, color: AppColors.error),
                    const SizedBox(width: 10),
                    _VitalChip(label: 'Post-meal', value: '198', unit: AppStrings.mgDl, color: AppColors.amber),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.bodyXs('Logged today at 7:30 AM', color: AppColors.textHint),
              ],
            ),
          ),
        ],
      );
}

// ─── Medicines tab ────────────────────────────────────────────────────────────

class _MedicinesTab extends StatelessWidget {
  final bool isFullAccess;
  const _MedicinesTab({required this.isFullAccess});

  @override
  Widget build(BuildContext context) {
    if (!isFullAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Read-only access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppText.bodySm(
                'You need full access to view this patient\'s medicines.',
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _MedRow(name: 'Metformin 500mg', dose: '1 tablet · Morning', color: AppColors.teal, status: 'Active'),
        const SizedBox(height: 10),
        _MedRow(name: 'Amlodipine 5mg', dose: '1 tablet · Afternoon', color: AppColors.blue, status: 'Active'),
        const SizedBox(height: 10),
        _MedRow(name: 'Vitamin D3', dose: '1 capsule · Evening', color: AppColors.amber, status: 'Active'),
      ],
    );
  }
}

class _MedRow extends StatelessWidget {
  final String name;
  final String dose;
  final Color color;
  final String status;

  const _MedRow({required this.name, required this.dose, required this.color, required this.status});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AppContainer.tinted(
              color: color,
              borderRadius: AppBorderRadius.smAll,
              padding: const EdgeInsets.all(9),
              child: Icon(Icons.medication_rounded, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMd(name, color: context.primaryText, fontWeight: FontWeight.w600),
                  AppText.bodyXs(dose, color: AppColors.textSecondary),
                ],
              ),
            ),
            AppContainer.tinted(
              color: AppColors.green,
              borderRadius: AppBorderRadius.pill,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: AppText.labelXs(status, color: AppColors.green),
            ),
          ],
        ),
      );
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1,
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String status;
  final Color statusColor;

  const _SummaryRow({required this.icon, required this.color, required this.label, required this.value, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(child: AppText.bodySm(label, color: AppColors.textSecondary)),
          AppText.bodySm(value, color: context.primaryText, fontWeight: FontWeight.w600),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: AppBorderRadius.pill),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      );
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _ActivityRow({required this.icon, required this.color, required this.text, required this.time});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: context.primaryText, height: 1.4)),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ],
      );
}

class _VitalChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _VitalChip({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyXs(label, color: AppColors.textSecondary, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, height: 1)),
                    TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
