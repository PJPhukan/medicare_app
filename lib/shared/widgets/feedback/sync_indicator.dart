import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum SyncState { idle, syncing, error, success }

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key, required this.state, this.message});
  final SyncState state;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (state == SyncState.idle) return const SizedBox.shrink();

    final (Color color, Widget icon, String label) = switch (state) {
      SyncState.syncing => (
          AppColors.blue,
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.blue),
          ),
          'Syncing…',
        ),
      SyncState.error => (
          AppColors.error,
          const Icon(Icons.sync_problem_rounded, size: 12, color: AppColors.error),
          'Sync failed',
        ),
      SyncState.success => (
          AppColors.green,
          const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.green),
          'Synced',
        ),
      SyncState.idle => (
          AppColors.textHint,
          const SizedBox.shrink(),
          '',
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: DecoratedBox(
        key: ValueKey(state),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 5),
              Text(
                message ?? label,
                style: AppTypography.labelXs.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
