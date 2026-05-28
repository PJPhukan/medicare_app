import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Segmented toggle bar — one option active at a time.
///
/// ```dart
/// AppToggleButton(
///   options: ['Day', 'Week', 'Month'],
///   selectedIndex: _index,
///   onChanged: (i) => setState(() => _index = i),
/// )
///
/// // With icons
/// AppToggleButton(
///   options: ['Grid', 'List'],
///   icons:   [Icons.grid_view_rounded, Icons.list_rounded],
///   selectedIndex: _view,
///   onChanged: (i) => setState(() => _view = i),
/// )
/// ```
class AppToggleButton extends StatelessWidget {
  const AppToggleButton({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
    this.color,
    this.height = 40,
    this.padding,
    this.enabled = true,
  }) : assert(icons == null || icons.length == options.length,
            'icons length must match options length');

  final List<String> options;
  final List<IconData>? icons;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Accent colour for the active segment. Defaults to [AppColors.teal].
  final Color? color;

  final double height;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent  = color ?? AppColors.teal;
    final trackBg = context.inputBg;
    final border  = context.borderCol;

    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: border),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: enabled && !active ? () => onChanged(i) : null,
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                curve: AppAnimations.standard,
                decoration: BoxDecoration(
                  color: active ? accent : Colors.transparent,
                  borderRadius: AppBorderRadius.mdAll,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icons != null) ...[
                      Icon(
                        icons![i],
                        size: 14,
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      options[i],
                      style: AppTypography.labelSm.copyWith(
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
