import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/connectivity_monitor.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';

// ─── Available-offline feature chips ─────────────────────────────────────────

const _offlineFeatures = [
  (Icons.home_rounded, 'Home'),
  (Icons.medication_rounded, 'Medicines'),
  (Icons.alarm_rounded, 'Reminders'),
  (Icons.monitor_heart_rounded, 'Vitals'),
  (Icons.sticky_note_2_rounded, 'Notes'),
  (Icons.emergency_rounded, 'Emergency'),
];

// ─── Offline page ─────────────────────────────────────────────────────────────

/// Full-page offline state shown when a screen requires network connectivity.
///
/// Shows:
///   • Animated pulsing signal orb
///   • Feature-specific message ("Community needs a connection")
///   • Chips listing features available offline
///   • Retry button that re-checks connectivity
class OfflinePage extends ConsumerStatefulWidget {
  const OfflinePage({
    super.key,
    this.featureName,
    this.showAppBar = true,
  });

  /// The name of the feature that requires internet, e.g. "Community".
  final String? featureName;

  /// Whether to render a back-arrow app bar (false for main tab screens).
  final bool showAppBar;

  @override
  ConsumerState<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends ConsumerState<OfflinePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _checking = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _checking = false);
    // isOnlineProvider is a stream — it updates automatically.
    // Calling checkConnectivity forces an immediate re-check.
    await checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    final feature = widget.featureName;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: context.bg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: Navigator.canPop(context)
                    ? GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: context.primaryText),
                        ),
                      )
                    : null,
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated orb ────────────────────────────────────────────
                _PulsingOrb(controller: _pulse),

                const SizedBox(height: 36),

                // ── Heading ─────────────────────────────────────────────────
                Text(
                  "You're Offline",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // ── Sub-message ──────────────────────────────────────────────
                Text(
                  feature != null
                      ? '$feature needs an internet connection to load.'
                      : 'This section needs an internet connection to load.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: context.secondaryText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // ── Available offline ────────────────────────────────────────
                _AvailableOfflineSection(),

                const Spacer(flex: 1),

                // ── Retry button ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _checking ? null : _retry,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      disabledBackgroundColor:
                          AppColors.teal.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.lgAll),
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing orb ─────────────────────────────────────────────────────────────

class _PulsingOrb extends StatelessWidget {
  const _PulsingOrb({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _OrbPainter(progress: controller.value),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.12),
                  border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3), width: 1.5),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 32,
                  color: AppColors.teal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 3; i++) {
      final delay = i / 3.0;
      final t = ((progress - delay) % 1.0 + 1.0) % 1.0;
      final eased = Curves.easeOut.transform(t);
      final radius = 38.0 + eased * 52.0;
      final opacity = (1.0 - eased) * 0.18;

      final paint = Paint()
        ..color = AppColors.teal.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.progress != progress;
}

// ─── Available offline chips section ─────────────────────────────────────────

class _AvailableOfflineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Divider(color: context.borderCol, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Available offline',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: context.secondaryText,
                ),
              ),
            ),
            Expanded(
                child: Divider(color: context.borderCol, thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _offlineFeatures
              .map((f) => _FeatureChip(icon: f.$1, label: f.$2))
              .toList(),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.08),
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
              color: AppColors.teal.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.teal),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      );
}

// ─── Inline no-internet card (for use inside scrollable content) ──────────────

/// Compact card-style offline indicator for use inside a scrollable body
/// when only part of the content requires network (e.g. a widget inside a list).
class OfflineCard extends StatelessWidget {
  const OfflineCard({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.lgAll,
        border:
            Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 18, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ?? 'Connect to the internet to load this content.',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.amber,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
