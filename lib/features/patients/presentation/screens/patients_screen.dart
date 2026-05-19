import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _Patient {
  final String id;
  final String name;
  final String condition;
  final String since;
  final Color avatarColor;
  final String accessLevel;

  const _Patient({
    required this.id,
    required this.name,
    required this.condition,
    required this.since,
    required this.avatarColor,
    required this.accessLevel,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kPatients = [
  _Patient(
    id: 'pt1',
    name: 'Ravi Kumar',
    condition: 'Type 2 Diabetes',
    since: 'Jan 2026',
    avatarColor: AppColors.teal,
    accessLevel: AppStrings.fullAccess,
  ),
  _Patient(
    id: 'pt2',
    name: 'Meena Joshi',
    condition: 'Hypertension',
    since: 'Mar 2026',
    avatarColor: AppColors.blue,
    accessLevel: AppStrings.readOnly,
  ),
  _Patient(
    id: 'pt3',
    name: 'Arjun Singh',
    condition: 'Post-surgery Recovery',
    since: 'Apr 2026',
    avatarColor: AppColors.purple,
    accessLevel: AppStrings.fullAccess,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final List<_Patient> _patients = List.from(_kPatients);

  void _removePatient(_Patient p) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.removePatient, style: AppTypography.h3),
        content: Text(AppStrings.removePatientConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.remove, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && mounted) {
        setState(() => _patients.remove(p));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.patientRemoved, style: AppTypography.bodySm)),
        );
      }
    });
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
                title: Text(AppStrings.patients, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            if (_patients.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_alt_rounded, size: 36, color: AppColors.teal),
                      ),
                      const SizedBox(height: 20),
                      Text(AppStrings.noPatients, style: AppTypography.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AppStrings.noPatientsDesc,
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _PatientCard(
                      patient: _patients[i],
                      onRemove: () => _removePatient(_patients[i]),
                    ),
                    childCount: _patients.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final _Patient patient;
  final VoidCallback onRemove;

  const _PatientCard({required this.patient, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isFullAccess = patient.accessLevel == AppStrings.fullAccess;
    final accessColor = isFullAccess ? AppColors.teal : AppColors.amber;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: patient.avatarColor.withValues(alpha: 0.15),
              child: Text(
                patient.name[0],
                style: AppTypography.h3.copyWith(color: patient.avatarColor, fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(patient.condition, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${AppStrings.patientSince} ${patient.since}',
                        style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accessColor.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.pill,
                        ),
                        child: Text(
                          patient.accessLevel,
                          style: AppTypography.bodyXs.copyWith(color: accessColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: context.inputBg,
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
              onSelected: (v) { if (v == 'remove') onRemove(); },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      const Icon(Icons.person_remove_rounded, color: AppColors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(AppStrings.removePatient, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
