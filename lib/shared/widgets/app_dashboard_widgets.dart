import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import 'animated_tap.dart';
import 'app_avatar.dart';

// ─── Greeting header ─────────────────────────────────────────────────────────

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.name,
    this.imageUrl,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  final String name;
  final String? imageUrl;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.goodMorning;
    if (h < 17) return AppStrings.goodAfternoon;
    if (h < 21) return AppStrings.goodEvening;
    return AppStrings.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting,', style: AppTypography.bodySm),
              Text(
                name.split(' ').first,
                style: AppTypography.h2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Stack(
          children: [
            AppAvatar(
              name: name,
              imageUrl: imageUrl,
              size: AppAvatarSize.md,
              onTap: onAvatarTap,
            ),
            if (notificationCount > 0)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notificationCount > 9 ? '9+' : '$notificationCount',
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Quick action tile ────────────────────────────────────────────────────────

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return AnimatedTap(
      onTap: onTap,
      borderRadius: AppBorderRadius.xlAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.07),
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.15),
                      borderRadius: AppBorderRadius.lgAll,
                    ),
                    child: Icon(icon, color: c, size: 22),
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(color: AppColors.dark900, width: 1.5),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textInverse),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Medicine dose card ───────────────────────────────────────────────────────

class DoseCard extends StatelessWidget {
  const DoseCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.time,
    required this.status,
    this.onTaken,
    this.onSkip,
    this.color,
  });

  final String medicineName;
  final String dosage;
  final String time;
  final DoseStatus status;
  final VoidCallback? onTaken;
  final VoidCallback? onSkip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final (Color statusColor, IconData statusIcon, String statusLabel) = switch (status) {
      DoseStatus.upcoming  => (AppColors.blue,    Icons.access_time_rounded,   AppStrings.upcoming),
      DoseStatus.taken     => (AppColors.green,   Icons.check_circle_rounded,   AppStrings.taken),
      DoseStatus.missed    => (AppColors.error,   Icons.cancel_rounded,         AppStrings.missed),
      DoseStatus.skipped   => (AppColors.textHint, Icons.skip_next_rounded,    AppStrings.doseSkipped),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: AppBorderRadius.pill,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicineName, style: AppTypography.labelMd),
                  const SizedBox(height: 2),
                  Text('$dosage · $time', style: AppTypography.bodySm),
                ],
              ),
            ),
            if (status == DoseStatus.upcoming) ...[
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textHint,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppStrings.skip, style: AppTypography.labelSm),
                ),
              if (onTaken != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onTaken,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: AppBorderRadius.lgAll,
                    ),
                    child: Text(
                      AppStrings.markAsTaken,
                      style: AppTypography.labelSm.copyWith(color: AppColors.textInverse),
                    ),
                  ),
                ),
              ],
            ] else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusLabel,
                    style: AppTypography.labelSm.copyWith(color: statusColor),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum DoseStatus { upcoming, taken, missed, skipped }

// ─── Vital reading card ───────────────────────────────────────────────────────

class VitalReadingCard extends StatelessWidget {
  const VitalReadingCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.color,
    this.status,
    this.onTap,
    this.trend,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color? color;
  final VitalStatus? status;
  final VoidCallback? onTap;
  final double? trend;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.blue;
    final statusColor = switch (status) {
      VitalStatus.normal   => AppColors.green,
      VitalStatus.high     => AppColors.amber,
      VitalStatus.critical => AppColors.error,
      VitalStatus.low      => AppColors.blue,
      null                 => null,
    };

    return AnimatedTap(
      onTap: onTap,
      borderRadius: AppBorderRadius.xlAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.06),
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: c),
                  const SizedBox(width: 6),
                  Expanded(child: Text(label, style: AppTypography.labelSm)),
                  if (statusColor != null)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              if (trend != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      trend! >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 12,
                      color: trend! >= 0 ? AppColors.green : AppColors.error,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${trend! >= 0 ? '+' : ''}${trend!.toStringAsFixed(1)}',
                      style: AppTypography.bodyXs.copyWith(
                        color: trend! >= 0 ? AppColors.green : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum VitalStatus { normal, high, low, critical }
