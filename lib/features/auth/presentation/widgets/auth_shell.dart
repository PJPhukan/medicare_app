import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Shared shell ─────────────────────────────────────────────────────────────

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.onBack,
    this.showBack = false,
  });

  final Widget child;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    AppColors.teal.withValues(alpha: isDark ? 0.07 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: onBack,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: AppColors.textHint,
                          ),
                          label: AppText.bodyMd(AppStrings.back, color: AppColors.textHint),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient CTA button ──────────────────────────────────────────────────────

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF67E8F9), AppColors.teal],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.32),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF041226),
                      ),
                    )
                  : AppText.labelLg(
                      label,
                      color: const Color(0xFF041226),
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class AuthStepper extends StatelessWidget {
  const AuthStepper({super.key, required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < current;
            return Expanded(
              child: Container(
                height: 1.5,
                color: done
                    ? AppColors.teal.withValues(alpha: 0.6)
                    : context.borderCol,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == current;
          final isDone = stepIndex < current;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.teal
                      : isActive
                          ? AppColors.teal.withValues(alpha: 0.15)
                          : context.inputBg,
                  border: Border.all(
                    color: isActive || isDone
                        ? AppColors.teal
                        : context.borderCol,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : AppText.labelSm(
                          '${stepIndex + 1}',
                          color: isActive ? AppColors.teal : AppColors.textHint,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              AppText.labelXs(
                steps[stepIndex],
                color: isActive ? AppColors.teal : AppColors.textHint,
              ),
            ],
          );
        }),
      ),
    );
  }
}
