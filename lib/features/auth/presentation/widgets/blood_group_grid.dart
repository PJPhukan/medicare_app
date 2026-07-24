import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

class BloodGroupGrid extends StatelessWidget {
  const BloodGroupGrid({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: _bloodGroups.length,
      itemBuilder: (_, i) {
        final bg = _bloodGroups[i];
        final active = selected == bg;
        return GestureDetector(
          onTap: () => onChanged(active ? '' : bg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.teal.withValues(alpha: 0.12)
                  : context.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? AppColors.teal.withValues(alpha: 0.5)
                    : context.borderCol,
              ),
            ),
            child: Center(
              child: AppText.labelMd(
                bg,
                color: active ? AppColors.teal : context.secondaryText,
              ),
            ),
          ),
        );
      },
    );
  }
}
