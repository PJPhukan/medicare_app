import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/graphs/charts.dart';

class VitalChip extends StatelessWidget {
  const VitalChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.sparkPoints,
  });

  final String       label;
  final String       value;
  final String       unit;
  final Color        color;
  final List<double> sparkPoints;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelXs(label, color: context.secondaryText, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: TextStyle(
                            fontSize: 9,
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            MiniSparkline(
              points: sparkPoints,
              color: color,
              height: 30,
              strokeWidth: 1.5,
              filled: true,
              fillOpacity: 0.22,
            ),
          ],
        ),
      ),
    );
  }
}
