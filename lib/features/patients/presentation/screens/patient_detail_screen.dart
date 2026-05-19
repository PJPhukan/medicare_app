import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

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
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: p.avatarColor.withValues(alpha: 0.15),
                          child: Text(
                            p.name[0],
                            style: AppTypography.h1.copyWith(color: p.avatarColor, fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(p.name, style: AppTypography.h2.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(p.condition, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accessColor.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.pill,
                              ),
                              child: Text(p.accessLevel,
                                  style: AppTypography.labelXs.copyWith(color: accessColor)),
                            ),
                            const SizedBox(width: 8),
                            Text('· Since ${p.since}',
                                style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
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
                    labelStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: AppTypography.labelSm,
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
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel('HEALTH SUMMARY'),
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
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel('RECENT ACTIVITY'),
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
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel('PERMISSIONS'),
                const SizedBox(height: 12),
                Text(
                  patient.accessLevel == AppStrings.fullAccess
                      ? 'You have full access to view vitals, medicines, reports and schedule.'
                      : 'You have read-only access to vitals and reports only.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.6),
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
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel('BLOOD PRESSURE'),
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
                Text('Logged today at 9:00 AM', style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel('BLOOD SUGAR'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VitalChip(label: 'Fasting', value: '142', unit: AppStrings.mgDl, color: AppColors.error),
                    const SizedBox(width: 10),
                    _VitalChip(label: 'Post-meal', value: '198', unit: AppStrings.mgDl, color: AppColors.amber),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Logged today at 7:30 AM', style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
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
              Text('Read-only access', style: AppTypography.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 8),
              Text('You need full access to view this patient\'s medicines.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppBorderRadius.smAll),
              child: Icon(Icons.medication_rounded, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
                  Text(dose, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.pill,
              ),
              child: Text(status, style: AppTypography.labelXs.copyWith(color: AppColors.green)),
            ),
          ],
        ),
      );
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: child,
      );
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1),
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
          Expanded(child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.bodySm.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: AppBorderRadius.pill),
            child: Text(status, style: AppTypography.labelXs.copyWith(color: statusColor, letterSpacing: 0)),
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
          Expanded(child: Text(text, style: AppTypography.bodySm.copyWith(color: context.primaryText, height: 1.4))),
          const SizedBox(width: 8),
          Text(time, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
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
              Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: value, style: AppTypography.statMd.copyWith(color: color, fontSize: 18)),
                    TextSpan(text: ' $unit', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
