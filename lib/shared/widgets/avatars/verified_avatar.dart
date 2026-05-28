import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_avatar.dart';

/// Avatar with an optional verified badge in the bottom-right corner.
///
/// Falls back to two-character initials from [name] when [imageUrl] is absent
/// or fails to load — identical behaviour to [AppAvatar].
///
/// The verified badge is only shown when [isVerified] is true.
///
/// ```dart
/// AppVerifiedAvatar(
///   name: 'Dr. Riya Sharma',
///   imageUrl: doctor.photoUrl,
///   isVerified: doctor.isVerified,
///   size: AppAvatarSize.lg,
/// )
/// ```
class AppVerifiedAvatar extends StatelessWidget {
  const AppVerifiedAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.isVerified = false,
    this.size = AppAvatarSize.md,
    this.shape = AppAvatarShape.circle,
    this.color,
    this.borderColor,
    this.borderWidth = 0,
    this.badgeColor,
    this.onTap,
  });

  final String? name;
  final String? imageUrl;

  /// When true the teal verified checkmark badge is shown.
  final bool isVerified;

  final AppAvatarSize size;
  final AppAvatarShape shape;

  /// Initials background accent. Auto-derived from [name] when null.
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  /// Badge background colour. Defaults to [AppColors.teal].
  final Color? badgeColor;

  final VoidCallback? onTap;

  static double _avatarDiameter(AppAvatarSize s) => switch (s) {
        AppAvatarSize.xs => 28,
        AppAvatarSize.sm => 36,
        AppAvatarSize.md => 44,
        AppAvatarSize.lg => 56,
        AppAvatarSize.xl => 72,
      };

  static double _badgeDiameter(AppAvatarSize s) => switch (s) {
        AppAvatarSize.xs => 12,
        AppAvatarSize.sm => 14,
        AppAvatarSize.md => 18,
        AppAvatarSize.lg => 22,
        AppAvatarSize.xl => 28,
      };

  static double _badgeIconSize(AppAvatarSize s) => switch (s) {
        AppAvatarSize.xs => 7,
        AppAvatarSize.sm => 8,
        AppAvatarSize.md => 11,
        AppAvatarSize.lg => 13,
        AppAvatarSize.xl => 17,
      };

  @override
  Widget build(BuildContext context) {
    final avatarDiameter = _avatarDiameter(size);
    final bd = _badgeDiameter(size);
    final totalSize = avatarDiameter + (borderWidth * 2);

    final avatar = AppAvatar(
      name: name,
      imageUrl: imageUrl,
      size: size,
      shape: shape,
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );

    if (!isVerified) {
      if (onTap != null) {
        return GestureDetector(onTap: onTap, child: avatar);
      }
      return avatar;
    }

    final badge = _VerifiedBadge(
      diameter: bd,
      iconSize: _badgeIconSize(size),
      color: badgeColor ?? AppColors.teal,
      borderColor: context.cardBg,
    );

    Widget stack = SizedBox(
      width: totalSize + bd * 0.4,
      height: totalSize + bd * 0.4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: badge,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: stack);
    }
    return stack;
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({
    required this.diameter,
    required this.iconSize,
    required this.color,
    required this.borderColor,
  });

  final double diameter;
  final double iconSize;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.check_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
