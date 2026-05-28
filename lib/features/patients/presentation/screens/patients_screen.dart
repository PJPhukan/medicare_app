import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

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

  Future<void> _removePatient(_Patient p) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.removePatient,
      message: AppStrings.removePatientConfirm,
      confirmLabel: AppStrings.remove,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _patients.remove(p));
    AppSnackbar.success(context, AppStrings.patientRemoved);
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
                title: AppText.h2(AppStrings.patients),
                background: Container(color: context.bg),
              ),
            ),
            if (_patients.isEmpty)
              SliverFillRemaining(
                child: AppEmptyState(
                  icon: Icons.people_alt_rounded,
                  title: AppStrings.noPatients,
                  subtitle: AppStrings.noPatientsDesc,
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AppAvatar(name: patient.name, size: AppAvatarSize.md),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMd(
                  patient.name,
                  color: context.primaryText,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 2),
                AppText.bodyXs(patient.condition, color: AppColors.textSecondary),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${AppStrings.patientSince} ${patient.since}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                    ),
                    const SizedBox(width: 10),
                    AppContainer.tinted(
                      color: accessColor,
                      borderRadius: AppBorderRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: AppText.labelXs(
                        patient.accessLevel,
                        color: accessColor,
                        fontWeight: FontWeight.w600,
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
                    AppText.bodySm(AppStrings.removePatient, color: AppColors.red),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
