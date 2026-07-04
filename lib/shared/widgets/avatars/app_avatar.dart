import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../skeleton/shimmer_widget.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }
enum AppAvatarShape { circle, rounded }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = AppAvatarSize.md,
    this.shape = AppAvatarShape.circle,
    this.color,
    this.borderColor,
    this.borderWidth = 0,
    this.isVerified = false,
    this.badgeColor,
    this.onTap,
  });

  final String? name;
  final String? imageUrl;
  final AppAvatarSize size;
  final AppAvatarShape shape;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final bool isVerified;
  final Color? badgeColor;
  final VoidCallback? onTap;

  static double diameter(AppAvatarSize s) => switch (s) {
    AppAvatarSize.xs => 28,
    AppAvatarSize.sm => 36,
    AppAvatarSize.md => 44,
    AppAvatarSize.lg => 56,
    AppAvatarSize.xl => 72,
  };

  static double fontSize(AppAvatarSize s) => switch (s) {
    AppAvatarSize.xs => 10,
    AppAvatarSize.sm => 13,
    AppAvatarSize.md => 16,
    AppAvatarSize.lg => 20,
    AppAvatarSize.xl => 26,
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

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name![0].toUpperCase();
  }

  Color _bgColor() {
    if (color != null) return color!;
    final colors = [
      AppColors.teal, AppColors.blue, AppColors.purple,
      AppColors.amber, AppColors.red, AppColors.green,
    ];
    final idx = (name ?? '').codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final d  = diameter(size);
    final br = shape == AppAvatarShape.circle
        ? BorderRadius.circular(d)
        : AppBorderRadius.lgAll;
    final bg = _bgColor();

    Widget inner;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      inner = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: d, height: d,
        fit: BoxFit.cover,
        placeholder: (_, __) => AppShimmer(
          child: Container(width: d, height: d, color: context.inputBg),
        ),
        errorWidget: (_, __, ___) => _buildInitials(d, bg),
      );
    } else {
      inner = _buildInitials(d, bg);
    }

    Widget avatar = ClipRRect(
      borderRadius: br,
      child: SizedBox(width: d, height: d, child: inner),
    );

    if (borderWidth > 0) {
      avatar = Container(
        width: d + borderWidth * 2,
        height: d + borderWidth * 2,
        decoration: BoxDecoration(
          borderRadius: br,
          border: Border.all(
            color: borderColor ?? context.borderCol,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    // Always reserve badge space so layout size is identical whether
    // isVerified is true or false — prevents Row alignment shifts.
    final badgeSize = _badgeDiameter(size);
    final totalSize = d + (borderWidth * 2) + badgeSize * .4;

    Widget result = SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: _VerifiedBadge(
                diameter: badgeSize,
                iconSize: _badgeIconSize(size),
                color: badgeColor ?? AppColors.teal,
                borderColor: context.cardBg,
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: result);
    }
    return result;
  }

  Widget _buildInitials(double d, Color bg) {
    return Container(
      width: d, height: d,
      color: bg,
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: fontSize(size),
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}

// ─── Verified badge ───────────────────────────────────────────────────────────

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
            color: color.withValues(alpha: .35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.check_rounded, size: iconSize, color: Colors.white),
      ),
    );
  }
}
