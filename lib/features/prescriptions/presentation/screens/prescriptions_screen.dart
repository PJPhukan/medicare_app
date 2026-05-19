import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _Prescription {
  final String id;
  final String doctor;
  final String specialty;
  final String issuedOn;
  final String? validUntil;
  final List<String> medicines;
  final String? notes;
  final bool active;

  const _Prescription({
    required this.id,
    required this.doctor,
    required this.specialty,
    required this.issuedOn,
    this.validUntil,
    required this.medicines,
    this.notes,
    required this.active,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kPrescriptions = [
  _Prescription(
    id: 'p1',
    doctor: 'Dr. Arjun Mehta',
    specialty: 'Cardiologist',
    issuedOn: '15 Apr 2026',
    validUntil: '15 Jul 2026',
    medicines: ['Metoprolol 25mg – twice daily', 'Aspirin 75mg – once daily', 'Atorvastatin 20mg – at night'],
    notes: 'Avoid strenuous activity. Follow up in 3 months.',
    active: true,
  ),
  _Prescription(
    id: 'p2',
    doctor: 'Dr. Priya Sharma',
    specialty: 'Endocrinologist',
    issuedOn: '2 Mar 2026',
    validUntil: '2 Jun 2026',
    medicines: ['Metformin 500mg – twice daily', 'Insulin Glargine 10 units – bedtime'],
    notes: 'Monitor fasting glucose daily.',
    active: true,
  ),
  _Prescription(
    id: 'p3',
    doctor: 'Dr. Ravi Kumar',
    specialty: 'General Physician',
    issuedOn: '10 Jan 2026',
    validUntil: '10 Feb 2026',
    medicines: ['Amoxicillin 500mg – thrice daily', 'Paracetamol 650mg – as needed'],
    active: false,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final List<_Prescription> _prescriptions = List.from(_kPrescriptions);

  void _openDetail(_Prescription p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrescriptionDetailSheet(
        prescription: p,
        onDelete: () {
          setState(() => _prescriptions.remove(p));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.prescriptionDeleted, style: AppTypography.bodySm)),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: Text(AppStrings.prescriptions, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            if (_prescriptions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_rounded, size: 56, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(AppStrings.noPrescriptions, style: AppTypography.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.noPrescriptionsDesc,
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Active section
              if (_prescriptions.any((p) => p.active)) ...[
                _SectionHeader(label: AppStrings.activePrescription, color: AppColors.teal),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final active = _prescriptions.where((p) => p.active).toList();
                        return _PrescriptionCard(
                          prescription: active[i],
                          onTap: () => _openDetail(active[i]),
                        );
                      },
                      childCount: _prescriptions.where((p) => p.active).length,
                    ),
                  ),
                ),
              ],
              // Expired section
              if (_prescriptions.any((p) => !p.active)) ...[
                _SectionHeader(label: AppStrings.expiredPrescription, color: AppColors.textHint),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final expired = _prescriptions.where((p) => !p.active).toList();
                        return _PrescriptionCard(
                          prescription: expired[i],
                          onTap: () => _openDetail(expired[i]),
                        );
                      },
                      childCount: _prescriptions.where((p) => !p.active).length,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: AppBorderRadius.pill)),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), style: AppTypography.labelSm.copyWith(color: color, letterSpacing: 0.8)),
            ],
          ),
        ),
      );
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _PrescriptionCard extends StatelessWidget {
  final _Prescription prescription;
  final VoidCallback onTap;

  _PrescriptionCard({required this.prescription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = prescription.active ? AppColors.teal : AppColors.textHint;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: prescription.active ? AppColors.teal.withValues(alpha: 0.2) : context.borderCol),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: color, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription.doctor,
                          style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          prescription.specialty,
                          style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.pill,
                    ),
                    child: Text(
                      prescription.active ? AppStrings.activePrescription : AppStrings.expiredPrescription,
                      style: AppTypography.bodyXs.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: context.borderCol, height: 1),
              const SizedBox(height: 12),
              // Medicines
              ...prescription.medicines.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 5, height: 5,
                          margin: const EdgeInsets.only(right: 8, top: 1),
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(m, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  )),
              if (prescription.medicines.length > 3)
                Text(
                  '+${prescription.medicines.length - 3} more',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${AppStrings.prescribedOn}: ${prescription.issuedOn}',
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                  ),
                  if (prescription.validUntil != null) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.event_available_rounded, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Until: ${prescription.validUntil}',
                      style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                    ),
                  ],
                  const Spacer(),
                  Text('View →', style: AppTypography.bodyXs.copyWith(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail sheet ─────────────────────────────────────────────────────────────

class _PrescriptionDetailSheet extends StatelessWidget {
  final _Prescription prescription;
  final VoidCallback onDelete;

  _PrescriptionDetailSheet({required this.prescription, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = prescription.active ? AppColors.teal : AppColors.textHint;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prescription.doctor, style: AppTypography.h3.copyWith(fontSize: 18)),
                      Text(prescription.specialty, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.pill,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    prescription.active ? AppStrings.activePrescription : AppStrings.expiredPrescription,
                    style: AppTypography.labelSm.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${AppStrings.prescribedOn}: ${prescription.issuedOn}${prescription.validUntil != null ? '  ·  ${AppStrings.prescriptionExpiry}: ${prescription.validUntil}' : ''}',
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.prescriptionMeds, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            SizedBox(height: 10),
            ...prescription.medicines.map((m) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medication_rounded, size: 16, color: color),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m, style: AppTypography.bodySm.copyWith(color: context.primaryText))),
                    ],
                  ),
                )),
            if (prescription.notes != null) ...[
              const SizedBox(height: 16),
              Text(AppStrings.prescriptionNotes, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.06),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
                ),
                child: Text(prescription.notes!, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
              ),
            ],
            SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.cardBg,
                    title: Text(AppStrings.deletePrescription, style: AppTypography.h3),
                    content: Text(AppStrings.deletePrescriptionConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(AppStrings.delete, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
                      ),
                    ],
                  ),
                ).then((ok) { if (ok == true) onDelete(); });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(AppStrings.deletePrescription, style: AppTypography.buttonMd.copyWith(color: AppColors.red)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
