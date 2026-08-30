import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../domain/entities/patient_entity.dart';
import '../providers/patients_provider.dart';
import '../widgets/add_patient_sheet.dart';

String _fmtMonth(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[dt.month - 1]} ${dt.year}';
}

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  Future<void> _addPatient() async {
    await showAddPatientSheet(context);
  }

  Future<void> _removePatient(PatientEntity p) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.removePatient,
      message: AppStrings.removePatientConfirm,
      confirmLabel: AppStrings.remove,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref.read(patientsProvider.notifier).removePatient(p.id);
    if (!mounted) return;
    if (removed) {
      AppSnackbar.success(context, AppStrings.patientRemoved);
    } else {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(patientsProvider);
    final isEmpty = st.patients.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () => ref.read(patientsProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              AppSliverAppBar(
                config: AppBarConfig(
                  title: AppStrings.patients,
                  subtitle: 'People you manage medicines and care for',
                  actions: [
                    AppIconButton(
                      icon: const Icon(Icons.person_add_rounded),
                      color: AppColors.teal,
                      onPressed: _addPatient,
                      tooltip: AppStrings.addPatient,
                    ),
                  ],
                ),
              ),
              if (st.isLoading && isEmpty)
                SliverToBoxAdapter(
                  child: AppListTileSkeleton.list(itemCount: 3, showTrailing: true),
                )
              else if (st.error != null && isEmpty)
                SliverFillRemaining(
                  child: AppErrorState(
                    message: st.error,
                    onRetry: () => ref.read(patientsProvider.notifier).load(),
                  ),
                )
              else if (isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.people_alt_rounded,
                    title: AppStrings.noPatients,
                    subtitle: AppStrings.noPatientsDesc,
                    action: _addPatient,
                    actionLabel: AppStrings.addPatient,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _PatientCard(
                        patient: st.patients[i],
                        onRemove: () => _removePatient(st.patients[i]),
                        onTap: () => context.push(
                          AppRoutes.patientDetail,
                          extra: st.patients[i],
                        ),
                      ),
                      childCount: st.patients.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = patient.isJoined ? AppColors.teal : AppColors.amber;
    final statusLabel = patient.isJoined ? 'Joined' : 'Pending';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AppAvatar(name: patient.name, imageUrl: patient.avatarUrl, size: AppAvatarSize.md),
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
                AppText.bodyXs(
                  patient.relation ?? 'Patient',
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${AppStrings.patientSince} ${_fmtMonth(patient.createdAtDate)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                    ),
                    const SizedBox(width: 10),
                    AppContainer.tinted(
                      color: statusColor,
                      borderRadius: AppBorderRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: AppText.labelXs(
                        statusLabel,
                        color: statusColor,
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
