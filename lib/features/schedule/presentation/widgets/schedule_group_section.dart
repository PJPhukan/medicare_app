import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';
import '../models/presentation_dose.dart';
import 'schedule_dose_row.dart';

class ScheduleGroupSection extends StatelessWidget {
  const ScheduleGroupSection({
    super.key,
    required this.group,
    required this.doses,
    required this.onMark,
    required this.textColor,
    required this.secondaryColor,
  });

  final DoseTimeGroup group;
  final List<PresentationDose> doses;
  final void Function(String id, DoseStatus status) onMark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) return const SizedBox.shrink();

    final color = group.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header tag
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Row(
              children: [
                Icon(group.icon, size: 15, color: color),
                const SizedBox(width: 6),
                AppText.bodySm(group.label, color: color, fontWeight: FontWeight.w800),
                const SizedBox(width: 8),
                AppBadge(label: group.range, variant: group.badgeVariant),
              ],
            ),
          ),
          // Dose cards stacked vertically
          Column(
            children: doses.map((dose) {
              return ScheduleDoseRow(
                dose: dose,
                onTake: () => onMark(dose.id, DoseStatus.taken),
                onSkip: () => onMark(dose.id, DoseStatus.skipped),
                textColor: textColor,
                secondaryColor: secondaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
