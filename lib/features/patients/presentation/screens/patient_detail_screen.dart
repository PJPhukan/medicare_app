import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../medicines/presentation/providers/medicines_provider.dart';
import '../../../medicines/presentation/widgets/medicine_detail_sheet.dart';
import '../../../medicines/presentation/widgets/medicine_list_row.dart';
import '../../domain/entities/patient_entity.dart';
import '../providers/patient_notes_provider.dart';

String _fmtMonth(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[dt.month - 1]} ${dt.year}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PatientDetailScreen extends StatefulWidget {
  final PatientEntity patient;

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
    final statusColor = p.isJoined ? AppColors.teal : AppColors.amber;
    final statusLabel = p.isJoined ? 'Joined' : 'Pending';

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
                        AppAvatar(name: p.name, imageUrl: p.avatarUrl, size: AppAvatarSize.xl),
                        const SizedBox(height: 12),
                        Text(
                          p.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        AppText.bodySm(p.relation ?? 'Patient', color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppContainer.tinted(
                              color: statusColor,
                              borderRadius: AppBorderRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              child: AppText.labelXs(statusLabel, color: statusColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '· Since ${_fmtMonth(p.createdAtDate)}',
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
                      Tab(text: 'Medicines'),
                      Tab(text: 'Notes'),
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
              _MedicinesTab(patient: p),
              _NotesTab(patient: p),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PatientEntity patient;
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
                const _CardLabel('PROFILE'),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.badge_outlined, label: 'Relation', value: patient.relation ?? '—'),
                if (patient.age != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.cake_outlined, label: 'Age', value: '${patient.age} years'),
                ],
                if (patient.bloodGroup != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.bloodtype_outlined, label: 'Blood group', value: patient.bloodGroup!),
                ],
                if (patient.contact != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.phone_outlined, label: 'Contact', value: patient.contact!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel('STATUS'),
                const SizedBox(height: 12),
                Text(
                  patient.isJoined
                      ? '${patient.name} has their own account. Notes and medicines you manage together sync in real time.'
                      : '${patient.name} hasn\'t joined yet — you\'re managing their medicines directly. '
                        'Once they sign up with the contact you added, their account links automatically.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: AppText.bodySm(label, color: AppColors.textSecondary)),
          AppText.bodySm(value, color: context.primaryText, fontWeight: FontWeight.w600),
        ],
      );
}

// ─── Medicines tab ────────────────────────────────────────────────────────────

class _MedicinesTab extends ConsumerWidget {
  final PatientEntity patient;
  const _MedicinesTab({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(medicinesProvider);
    final meds = st.medicines.where((m) => m.patientProfileId == patient.id).toList();

    if (st.isLoading && meds.isEmpty) {
      return const Center(child: AppLoadingSpinner());
    }
    if (meds.isEmpty) {
      return AppEmptyState(
        icon: Icons.medication_outlined,
        title: 'No medicines yet',
        subtitle: '${patient.name}\'s medicines will show up here once you add one for them.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: meds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => MedicineListRow(
        medicine: meds[i],
        onTap: () => showMedicineDetailSheet(context, meds[i]),
      ),
    );
  }
}

// ─── Notes tab ────────────────────────────────────────────────────────────────

class _NotesTab extends ConsumerStatefulWidget {
  final PatientEntity patient;
  const _NotesTab({required this.patient});

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    final ok = await ref
        .read(patientNotesProvider(widget.patient.id).notifier)
        .addNote(text);
    if (!mounted) return;
    if (ok) {
      _noteCtrl.clear();
      FocusScope.of(context).unfocus();
    } else {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.patient.isJoined) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock_rounded, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Waiting for them to join', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppText.bodySm(
                'Notes unlock once ${widget.patient.name} joins with their own account.',
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final st = ref.watch(patientNotesProvider(widget.patient.id));

    return Column(
      children: [
        Expanded(
          child: st.isLoading && st.notes.isEmpty
              ? const Center(child: AppLoadingSpinner())
              : st.notes.isEmpty
                  ? AppEmptyState(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'No notes yet',
                      subtitle: 'Jot down anything worth remembering about ${widget.patient.name}\'s care.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: st.notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final n = st.notes[i];
                        return AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.note, style: TextStyle(fontSize: 13, color: context.primaryText, height: 1.4)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (n.authorName != null) ...[
                                    AppText.bodyXs(n.authorName!, color: AppColors.textHint, fontWeight: FontWeight.w600),
                                    const SizedBox(width: 6),
                                    AppText.bodyXs('·', color: AppColors.textHint),
                                    const SizedBox(width: 6),
                                  ],
                                  AppText.bodyXs(_fmtMonth(n.createdAtDate), color: AppColors.textHint),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _noteCtrl,
                    hint: 'Add a note…',
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: st.isSaving
                      ? const AppLoadingSpinner(size: 16, strokeWidth: 2)
                      : const Icon(Icons.send_rounded),
                  color: AppColors.teal,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                  onPressed: st.isSaving ? null : _addNote,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
