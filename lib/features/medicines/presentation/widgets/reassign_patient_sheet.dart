import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../patients/presentation/providers/patient_profiles_provider.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicines_provider.dart';

/// Lets the owner move a personal medicine between themselves and one of their
/// patient profiles. Resolves true when the assignment changed.
Future<bool?> showReassignPatientSheet(
  BuildContext context,
  UserMedicineEntity medicine,
) {
  return AppBottomSheet.show<bool>(
    context,
    title: 'Who is this for?',
    subtitle: medicine.displayName,
    child: _ReassignBody(medicine: medicine),
  );
}

class _ReassignBody extends ConsumerStatefulWidget {
  const _ReassignBody({required this.medicine});

  final UserMedicineEntity medicine;

  @override
  ConsumerState<_ReassignBody> createState() => _ReassignBodyState();
}

class _ReassignBodyState extends ConsumerState<_ReassignBody> {
  late String? _selected = widget.medicine.patientProfileId;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(medicinesProvider.notifier)
          .reassignMedicine(widget.medicine.id, _selected);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(patientProfilesProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Option(
          label: 'Me',
          icon: Icons.person_rounded,
          color: AppColors.teal,
          selected: _selected == null,
          onTap: () => setState(() => _selected = null),
        ),
        switch (profiles) {
          AsyncLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLoadingSpinner()),
            ),
          AsyncError() => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AppText.bodySm('Could not load your patients',
                  color: AppColors.amber),
            ),
          _ => Column(
              children: [
                for (final p in profiles.valueOrNull ?? const [])
                  _Option(
                    label: p.name,
                    icon: Icons.account_circle_rounded,
                    color: AppColors.blue,
                    selected: _selected == p.id,
                    onTap: () => setState(() => _selected = p.id),
                  ),
              ],
            ),
        },
        if ((profiles.valueOrNull ?? const []).isEmpty &&
            profiles is! AsyncLoading) ...[
          const SizedBox(height: 8),
          AppText.bodyXs(
            'Add a patient to assign medicines to someone else.',
            color: AppColors.textHint,
          ),
        ],
        const SizedBox(height: 20),
        AppButton(
          variant: AppButtonVariant.primary,
          label: 'Save',
          isFullWidth: true,
          isLoading: _saving,
          // Nothing to write when the selection is unchanged.
          onPressed: _saving || _selected == widget.medicine.patientProfileId
              ? null
              : _save,
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        color: selected ? color.withValues(alpha: 0.07) : null,
        borderColor: selected ? color.withValues(alpha: 0.4) : null,
        effectColor: selected ? color : null,
        child: AppListTile(
          color: Colors.transparent,
          leading: Icon(icon,
              size: 22, color: selected ? color : context.secondaryText),
          title: label,
          trailing: selected
              ? Icon(Icons.check_circle_rounded, size: 20, color: color)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
