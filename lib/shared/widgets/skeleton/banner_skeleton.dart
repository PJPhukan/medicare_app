import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton placeholder that mirrors the 4:1 banner carousel layout.
class BannerCarouselSkeleton extends StatelessWidget {
  const BannerCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 1,
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 20, height: 6, borderRadius: BorderRadius.circular(999)),
              const SizedBox(width: 5),
              SkeletonBox(width: 6, height: 6, borderRadius: BorderRadius.circular(999)),
              const SizedBox(width: 5),
              SkeletonBox(width: 6, height: 6, borderRadius: BorderRadius.circular(999)),
            ],
          ),
        ],
      ),
    );
  }
}
