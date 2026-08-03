import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';

/// Full-page 404 shown by go_router's [GoRouter.errorBuilder] for any
/// unmatched route (bad deep link, stale push notification payload, etc).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.path});

  /// The location that failed to match, shown for debugging context.
  final String? path;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.10),
                  ),
                  child: const Icon(Icons.explore_off_rounded,
                      size: 44, color: AppColors.teal),
                ),
                const SizedBox(height: 28),
                Text(
                  "Page Not Found",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "The screen you're looking for doesn't exist or may have moved.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: context.secondaryText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (path != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    path!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.hintText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape:
                          RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
