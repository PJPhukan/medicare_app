import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import 'shimmer_widget.dart';

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
    this.onTap,
  });

  final String? name;
  final String? imageUrl;
  final AppAvatarSize size;
  final AppAvatarShape shape;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  static double _diameter(AppAvatarSize s) => switch (s) {
    AppAvatarSize.xs => 28,
    AppAvatarSize.sm => 36,
    AppAvatarSize.md => 44,
    AppAvatarSize.lg => 56,
    AppAvatarSize.xl => 72,
  };

  static double _fontSize(AppAvatarSize s) => switch (s) {
    AppAvatarSize.xs => 10,
    AppAvatarSize.sm => 13,
    AppAvatarSize.md => 16,
    AppAvatarSize.lg => 20,
    AppAvatarSize.xl => 26,
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
    final d  = _diameter(size);
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
          child: Container(width: d, height: d, color: AppColors.dark700),
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
            color: borderColor ?? AppColors.dark600,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _buildInitials(double d, Color bg) {
    return Container(
      width: d, height: d,
      color: bg,
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: _fontSize(size),
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}

// ─── Avatar group ─────────────────────────────────────────────────────────────

class AppAvatarGroup extends StatelessWidget {
  const AppAvatarGroup({
    super.key,
    required this.imageUrls,
    this.names,
    this.max = 3,
    this.size = AppAvatarSize.sm,
    this.overlap = 12,
  });

  final List<String?> imageUrls;
  final List<String?>? names;
  final int max;
  final AppAvatarSize size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final shown = imageUrls.take(max).toList();
    final extra = imageUrls.length - max;
    final d = AppAvatar._diameter(size);

    return SizedBox(
      height: d,
      width: d + (shown.length - 1 + (extra > 0 ? 1 : 0)) * (d - overlap),
      child: Stack(
        children: [
          ...shown.asMap().entries.map((e) => Positioned(
            left: e.key * (d - overlap),
            child: AppAvatar(
              imageUrl: e.value,
              name: names?.elementAtOrNull(e.key),
              size: size,
              borderWidth: 2,
            ),
          )),
          if (extra > 0)
            Positioned(
              left: shown.length * (d - overlap),
              child: Container(
                width: d, height: d,
                decoration: BoxDecoration(
                  color: AppColors.dark600,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.dark800, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: AppAvatar._fontSize(size) - 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
