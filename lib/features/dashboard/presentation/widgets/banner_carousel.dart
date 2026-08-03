import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/banner_config.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});
  final List<DashboardBanner> banners;

  @override
  State<BannerCarousel> createState() => BannerCarouselState();
}

class BannerCarouselState extends State<BannerCarousel> {
  late final PageController _ctrl;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    _timer = null;
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || widget.banners.isEmpty) return;
        final next = (_page + 1) % widget.banners.length;
        _ctrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 1,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _BannerCard(banner: widget.banners[i]),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 5),
                width: active ? 20 : 6, height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal
                      : AppColors.teal.withValues(alpha: 0.25),
                  borderRadius: AppBorderRadius.pill,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final DashboardBanner banner;

  @override
  Widget build(BuildContext context) {
    if (banner.isGradient) return _GradientBanner(banner: banner);
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: AppBorderRadius.smAll,
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(
            color: context.inputBg,
            child: const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
              ),
            ),
          ),
          // A broken image still belongs to a real, enabled banner — fall back
          // to a plain gradient, never to unrelated hard-coded promo copy.
          errorWidget: (_, __, ___) => _GradientBanner(banner: banner),
        ),
      ),
    );
  }
}

class _GradientBanner extends StatelessWidget {
  const _GradientBanner({required this.banner});
  final DashboardBanner banner;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: AppBorderRadius.smAll,
        child: Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                banner.gradientStart ?? AppColors.teal.withValues(alpha: 0.8),
                banner.gradientEnd   ?? const Color(0xFF0D2137),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (banner.title != null)
                      AppText.labelMd(
                        banner.title!,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 3),
                      AppText.bodyXs(
                        banner.subtitle!,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
