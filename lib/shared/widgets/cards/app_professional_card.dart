import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_strings.dart';
import '../avatars/app_avatar.dart';
import '../buttons/app_button.dart';

class AppProfessionalCard extends StatelessWidget {
  const AppProfessionalCard({
    super.key,
    required this.name,
    required this.category,
    this.imageUrl,
    this.isVerified = false,
    this.experienceYrs,
    this.address,
    this.lowestRate,
    this.currency = '₹',
    this.color,
    this.connectionState = ProConnectionState.none,
    this.onConnect,
    this.onMessage,
    this.onView,
    this.certifications = const [],
  });

  final String name;
  final String category;
  final String? imageUrl;
  final bool isVerified;
  final int? experienceYrs;
  final String? address;
  final num? lowestRate;
  final String currency;
  final Color? color;
  final ProConnectionState connectionState;
  final VoidCallback? onConnect;
  final VoidCallback? onMessage;
  final VoidCallback? onView;
  final List<String> certifications;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Top color bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c, c.withValues(alpha: 0.4)]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppAvatar(
                          name: name,
                          imageUrl: imageUrl,
                          size: AppAvatarSize.lg,
                          shape: AppAvatarShape.rounded,
                          color: c,
                        ),
                        if (isVerified)
                          Positioned(
                            bottom: -2, right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_rounded, size: 13, color: AppColors.teal),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                            style: AppTypography.labelMd,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.15),
                              borderRadius: AppBorderRadius.pill,
                            ),
                            child: Text(category,
                              style: AppTypography.labelXs.copyWith(color: c),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (lowestRate != null) ...[
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppStrings.from, style: AppTypography.bodyXs),
                          Text(
                            '$currency${lowestRate!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // Meta chips
                if (experienceYrs != null || address != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: [
                      if (experienceYrs != null)
                        _MetaChip(icon: Icons.work_outline_rounded, label: '${experienceYrs}y exp'),
                      if (address != null)
                        _MetaChip(icon: Icons.location_on_outlined, label: address!),
                    ],
                  ),
                ],

                // Actions
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.secondary,
                        label: AppStrings.viewProfile,
                        size: AppButtonSize.sm,
                        onPressed: onView,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: switch (connectionState) {
                        ProConnectionState.connected => AppButton(
                          label: AppStrings.message,
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.sm,
                          color: c,
                          leading: const Icon(Icons.message_rounded),
                          onPressed: onMessage,
                        ),
                        ProConnectionState.pending => DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.lgAll,
                            border: Border.all(color: c.withValues(alpha: 0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Center(
                              child: Text(AppStrings.pending,
                                style: AppTypography.buttonSm.copyWith(color: c),
                              ),
                            ),
                          ),
                        ),
                        ProConnectionState.none => AppButton(
                          label: AppStrings.connect,
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.sm,
                          color: c,
                          leading: const Icon(Icons.person_add_rounded),
                          onPressed: onConnect,
                        ),
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ProConnectionState { none, pending, connected }

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: context.borderCol),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: AppColors.textHint),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                label,
                style: AppTypography.bodyXs,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
