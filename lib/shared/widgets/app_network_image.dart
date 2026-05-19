import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import 'shimmer_widget.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      placeholder: (_, __) => placeholder ?? AppShimmer(
        child: Container(
          width: width,
          height: height,
          color: AppColors.dark700,
        ),
      ),
      errorWidget: (_, __, ___) => errorWidget ?? Container(
        width: width,
        height: height,
        color: AppColors.dark700,
        child: const Icon(Icons.broken_image_rounded, color: AppColors.textHint, size: 24),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// ─── Image carousel ───────────────────────────────────────────────────────────

class AppImageCarousel extends StatefulWidget {
  const AppImageCarousel({
    super.key,
    required this.urls,
    this.height = 200,
    this.borderRadius,
    this.showIndicator = true,
    this.onTap,
  });

  final List<String> urls;
  final double height;
  final BorderRadius? borderRadius;
  final bool showIndicator;
  final ValueChanged<int>? onTap;

  @override
  State<AppImageCarousel> createState() => _AppImageCarouselState();
}

class _AppImageCarouselState extends State<AppImageCarousel> {
  final _ctrl = PageController();
  int _current = 0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => widget.onTap?.call(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppNetworkImage(
                  url: widget.urls[i],
                  height: widget.height,
                  borderRadius: widget.borderRadius ?? AppBorderRadius.xlAll,
                ),
              ),
            ),
          ),
        ),
        if (widget.showIndicator && widget.urls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.urls.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.teal : AppColors.dark500,
                borderRadius: AppBorderRadius.pill,
              ),
            )),
          ),
        ],
      ],
    );
  }
}
