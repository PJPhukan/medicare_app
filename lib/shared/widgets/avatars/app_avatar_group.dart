import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_avatar.dart';

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
    final d = AppAvatar.diameter(size);

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
                  color: context.borderCol,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cardBg, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: AppAvatar.fontSize(size) - 1,
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
