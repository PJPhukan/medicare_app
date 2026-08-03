import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class NotifBell extends StatelessWidget {
  const NotifBell({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          color: context.secondaryText,
          backgroundColor: Colors.transparent,
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        if (count > 0)
          Positioned(
            top: 6, right: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

// ─── Hero adherence card ──────────────────────────────────────────────────────
