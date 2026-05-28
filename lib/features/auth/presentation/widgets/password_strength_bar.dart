import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  _StrengthLevel get _level {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    final levels = [
      _StrengthLevel(AppStrings.strengthVeryWeak, 0.08, const Color(0xFFf87171)),
      _StrengthLevel(AppStrings.strengthWeak,     0.25, const Color(0xFFfb7185)),
      _StrengthLevel(AppStrings.strengthFair,     0.50, const Color(0xFFF59E0B)),
      _StrengthLevel(AppStrings.strengthGood,     0.75, const Color(0xFF60a5fa)),
      _StrengthLevel(AppStrings.strengthStrong,   1.00, AppColors.teal),
    ];
    return levels[score];
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              child: LinearProgressIndicator(
                value: level.pct,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.dark600
                    : AppColors.light400,
                valueColor: AlwaysStoppedAnimation(level.color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AppText.labelSm(level.label, color: level.color),
      ],
    );
  }
}

class _StrengthLevel {
  const _StrengthLevel(this.label, this.pct, this.color);
  final String label;
  final double pct;
  final Color color;
}
