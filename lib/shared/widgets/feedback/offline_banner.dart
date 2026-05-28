import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/connectivity_monitor.dart';

/// Slim amber bar that slides in at the top of a screen when offline.
/// Export via widgets.dart barrel.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: child,
      ),
      child: isOnline
          ? const SizedBox.shrink(key: ValueKey('online'))
          : DecoratedBox(
              key: const ValueKey('offline'),
              decoration: const BoxDecoration(color: AppColors.amber),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 14, color: AppColors.textInverse),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re offline — some features may be limited',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
