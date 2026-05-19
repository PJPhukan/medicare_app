import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/connectivity_monitor.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOnline
          ? const SizedBox.shrink()
          : DecoratedBox(
              key: const ValueKey('offline'),
              decoration: const BoxDecoration(color: AppColors.amber),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 6,
                  bottom: 6,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.textInverse),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.offlineMode,
                        style: AppTypography.labelSm.copyWith(color: AppColors.textInverse),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
