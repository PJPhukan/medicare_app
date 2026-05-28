import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.dark700,
      highlightColor: AppColors.dark500,
      child: child,
    );
  }
}
