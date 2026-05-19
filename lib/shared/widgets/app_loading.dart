import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import 'shimmer_widget.dart';

// ─── Spinner ─────────────────────────────────────────────────────────────────

class AppLoadingSpinner extends StatelessWidget {
  const AppLoadingSpinner({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.teal),
      ),
    );
  }
}

// ─── Full page loader ────────────────────────────────────────────────────────

class AppPageLoader extends StatelessWidget {
  const AppPageLoader({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoadingSpinner(size: 32, strokeWidth: 2.5),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Overlay loader ──────────────────────────────────────────────────────────

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.dark900.withValues(alpha: 0.7),
              ),
              child: AppPageLoader(message: message ?? AppStrings.pleaseWait),
            ),
          ),
      ],
    );
  }
}

// ─── Skeleton card ────────────────────────────────────────────────────────────

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 16,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.dark700,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ─── Skeleton list ────────────────────────────────────────────────────────────

class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.count = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  final int count;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) => Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: AppSkeletonCard(height: itemHeight),
      )),
    );
  }
}

// ─── Skeleton grid ────────────────────────────────────────────────────────────

class AppSkeletonGrid extends StatelessWidget {
  const AppSkeletonGrid({
    super.key,
    this.count = 6,
    this.crossAxisCount = 2,
    this.itemHeight = 120,
  });

  final int count;
  final int crossAxisCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: double.infinity / itemHeight,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const AppSkeletonCard(),
    );
  }
}
