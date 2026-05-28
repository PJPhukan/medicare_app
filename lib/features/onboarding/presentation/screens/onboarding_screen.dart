import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

const _kSeenKey = 'onboarding_seen';
const _kAutoAdvanceMs = 4000;

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kSeenKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kSeenKey, true);
}

// ─── Page model ───────────────────────────────────────────────────────────────

class _PageData {
  const _PageData({
    required this.title,
    required this.body,
    required this.makePainter,
    required this.accentColor,
    required this.darkGradientEnd,
    required this.lightGradientEnd,
  });
  final String title;
  final String body;
  final CustomPainter Function(bool isDark) makePainter;
  final Color accentColor;
  final Color darkGradientEnd;
  final Color lightGradientEnd;
}

// ─── Main screen ──────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _page = 0;
  Timer? _autoTimer;

  late final AnimationController _floatCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<double> _floatAnim;

  static const _pages = [
    _PageData(
      title: AppStrings.onboarding1Title,
      body: AppStrings.onboarding1Body,
      makePainter: _MedicinePainter.new,
      accentColor: AppColors.teal,
      darkGradientEnd: Color(0xFF0A1F1C),
      lightGradientEnd: Color(0xFFE6FAF8),
    ),
    _PageData(
      title: AppStrings.onboarding2Title,
      body: AppStrings.onboarding2Body,
      makePainter: _ReminderPainter.new,
      accentColor: AppColors.blue,
      darkGradientEnd: Color(0xFF0D0F1F),
      lightGradientEnd: Color(0xFFE8F0FF),
    ),
    _PageData(
      title: AppStrings.onboarding3Title,
      body: AppStrings.onboarding3Body,
      makePainter: _ShieldPainter.new,
      accentColor: AppColors.purple,
      darkGradientEnd: Color(0xFF1A0D1F),
      lightGradientEnd: Color(0xFFF0E8FF),
    ),
    _PageData(
      title: AppStrings.onboarding4Title,
      body: AppStrings.onboarding4Body,
      makePainter: _ProfessionalPainter.new,
      accentColor: AppColors.amber,
      darkGradientEnd: Color(0xFF1F1500),
      lightGradientEnd: Color(0xFFFFF8E1),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _startAutoTimer();
  }

  void _startAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(milliseconds: _kAutoAdvanceMs), (_) {
      if (!mounted) return;
      if (_page < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _autoTimer?.cancel();
      }
    });
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    _contentCtrl.forward(from: 0);
    // Reset timer on manual swipe so the current page gets full 4s
    _startAutoTimer();
  }

  void _goNext() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _done();
    }
  }

  void _goBack() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _done() async {
    _autoTimer?.cancel();
    await markOnboardingSeen();
    widget.onDone();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    _floatCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _pages[_page];
    final isLast = _page == _pages.length - 1;

    final bgBase = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final bgEnd = isDark ? page.darkGradientEnd : page.lightGradientEnd;

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          // Animated gradient bg
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgEnd, bgBase],
              ),
            ),
          ),

          // Subtle grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(isDark: isDark)),
          ),

          // Accent glow behind illustration
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 0.65,
                colors: [
                  page.accentColor.withValues(alpha: isDark ? 0.14 : 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, index) => _PageContent(
              page: _pages[index],
              floatAnim: _floatAnim,
              contentCtrl: _contentCtrl,
              isCurrent: index == _page,
              isDark: isDark,
            ),
          ),

          // Top navigation row: Back (left) + Skip (right)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button — fades in from page 2
                    AnimatedOpacity(
                      opacity: _page > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: TextButton.icon(
                        onPressed: _page > 0 ? _goBack : null,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textHint
                              : const Color(0xFF94A3B8),
                        ),
                        label: Text(
                          AppStrings.back,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),

                    // Skip button — hidden on last page
                    AnimatedOpacity(
                      opacity: isLast ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: TextButton(
                        onPressed: isLast ? null : _done,
                        child: Text(
                          AppStrings.onboardingSkip,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProgressDots(
                      count: _pages.length,
                      current: _page,
                      activeColor: page.accentColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),

                    // CTA button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            page.accentColor,
                            Color.lerp(page.accentColor, Colors.white, 0.12)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: page.accentColor.withValues(
                                alpha: isDark ? 0.35 : 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _goNext,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLast
                                      ? AppStrings.onboardingGetStarted
                                      : AppStrings.onboardingNext,
                                  style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: Colors.white, letterSpacing: 0.2,
                                  ),
                                ),
                                if (!isLast) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single page content ──────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.floatAnim,
    required this.contentCtrl,
    required this.isCurrent,
    required this.isDark,
  });

  final _PageData page;
  final Animation<double> floatAnim;
  final AnimationController contentCtrl;
  final bool isCurrent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fadeSlide = CurvedAnimation(parent: contentCtrl, curve: Curves.easeOut);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A202C);
    final bodyColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    return Column(
      children: [
        // Illustration
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, floatAnim.value),
                child: child,
              ),
              child: CustomPaint(
                painter: page.makePainter(isDark),
                child: const SizedBox(width: 280, height: 280),
              ),
            ),
          ),
        ),

        // Text
        Expanded(
          flex: 3,
          child: AnimatedBuilder(
            animation: fadeSlide,
            builder: (_, child) => Opacity(
              opacity: fadeSlide.value,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - fadeSlide.value)),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800,
                      color: titleColor, height: 1.15, letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400,
                      color: bodyColor, height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 148),
      ],
    );
  }
}

// ─── Progress dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.isDark,
  });
  final int count;
  final int current;
  final Color activeColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.textHint.withValues(alpha: 0.4)
        : const Color(0xFFCBD5E1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}

// ─── Illustrations ────────────────────────────────────────────────────────────

Color _cardBg(bool isDark) =>
    isDark ? AppColors.dark700 : const Color(0xFFFFFFFF);
Color _cardBorder(bool isDark, Color accent) =>
    accent.withValues(alpha: isDark ? 0.55 : 0.40);
Color _ringColor(bool isDark, Color accent) =>
    accent.withValues(alpha: isDark ? 0.15 : 0.20);

// Page 1: Medicine
class _MedicinePainter extends CustomPainter {
  const _MedicinePainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const accent = AppColors.teal;

    canvas.drawCircle(Offset(cx, cy), 130,
        Paint()..color = accent.withValues(alpha: isDark ? 0.08 : 0.06));

    final ringPaint = Paint()
      ..color = _ringColor(isDark, accent)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 100, ringPaint);
    canvas.drawCircle(Offset(cx, cy), 118,
        ringPaint..color = accent.withValues(alpha: isDark ? 0.07 : 0.10));

    canvas.drawCircle(Offset(cx, cy), 80,
        Paint()
          ..color = accent.withValues(alpha: isDark ? 0.2 : 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    canvas.drawCircle(Offset(cx, cy), 80, Paint()..color = _cardBg(isDark));
    canvas.drawCircle(Offset(cx, cy), 80,
        Paint()
          ..color = _cardBorder(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final crossPaint = Paint()..color = accent;
    final r = RRect.fromRectAndRadius;
    const cw = 14.0;
    const ch = 44.0;
    canvas.drawRRect(
      r(Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch),
          const Radius.circular(6)),
      crossPaint,
    );
    canvas.drawRRect(
      r(Rect.fromCenter(center: Offset(cx, cy), width: ch, height: cw),
          const Radius.circular(6)),
      crossPaint,
    );

    _drawPill(canvas, Offset(cx + 90, cy - 75), 28, 14, AppColors.blue, -0.4);
    _drawPill(canvas, Offset(cx - 85, cy + 68), 24, 12, AppColors.purple, 0.5);
    canvas.drawCircle(Offset(cx + 78, cy + 72), 8,
        Paint()..color = AppColors.amber.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx - 88, cy - 60), 6,
        Paint()..color = accent.withValues(alpha: 0.6));
  }

  void _drawPill(Canvas canvas, Offset center, double w, double h, Color color,
      double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Radius.circular(h / 2),
      ),
      Paint()..color = color,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 1, height: h),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MedicinePainter old) => old.isDark != isDark;
}

// Page 2: Reminder / clock
class _ReminderPainter extends CustomPainter {
  const _ReminderPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const accent = AppColors.blue;

    canvas.drawCircle(Offset(cx, cy), 130,
        Paint()..color = accent.withValues(alpha: isDark ? 0.08 : 0.06));
    canvas.drawCircle(Offset(cx, cy), 100,
        Paint()
          ..color = _ringColor(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    canvas.drawCircle(Offset(cx, cy - 6), 78,
        Paint()
          ..color = accent.withValues(alpha: isDark ? 0.2 : 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(Offset(cx, cy - 6), 78, Paint()..color = _cardBg(isDark));
    canvas.drawCircle(Offset(cx, cy - 6), 78,
        Paint()
          ..color = _cardBorder(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final tickColor = isDark
        ? AppColors.textHint.withValues(alpha: 0.4)
        : const Color(0xFFCBD5E1);
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final outer = Offset(cx + 66 * math.sin(angle), cy - 6 - 66 * math.cos(angle));
      final inner = Offset(cx + 56 * math.sin(angle), cy - 6 - 56 * math.cos(angle));
      canvas.drawLine(inner, outer, tickPaint);
    }

    canvas.drawLine(
      Offset(cx, cy - 6),
      Offset(cx - 26 * math.sin(0.7), cy - 6 - 26 * math.cos(0.7)),
      Paint()
        ..color = isDark ? AppColors.textPrimary : const Color(0xFF1A202C)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx, cy - 6),
      Offset(cx + 42 * math.sin(1.1), cy - 6 - 42 * math.cos(1.1)),
      Paint()
        ..color = accent
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy - 6), 5, Paint()..color = accent);

    _drawBell(canvas, Offset(cx + 80, cy + 62), AppColors.amber);
    canvas.drawCircle(Offset(cx - 90, cy + 55), 7,
        Paint()..color = accent.withValues(alpha: 0.5));
    canvas.drawCircle(Offset(cx + 70, cy - 80), 9,
        Paint()..color = AppColors.teal.withValues(alpha: 0.5));
  }

  void _drawBell(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(center.dx, center.dy - 14)
      ..cubicTo(center.dx - 12, center.dy - 14, center.dx - 14, center.dy - 2,
          center.dx - 14, center.dy + 4)
      ..lineTo(center.dx + 14, center.dy + 4)
      ..cubicTo(center.dx + 14, center.dy - 2, center.dx + 12, center.dy - 14,
          center.dx, center.dy - 14)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 6), width: 28, height: 5),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawCircle(Offset(center.dx, center.dy + 11), 4, paint);
  }

  @override
  bool shouldRepaint(_ReminderPainter old) => old.isDark != isDark;
}

// Page 3: Shield / security
class _ShieldPainter extends CustomPainter {
  const _ShieldPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const accent = AppColors.purple;

    canvas.drawCircle(Offset(cx, cy), 130,
        Paint()..color = accent.withValues(alpha: isDark ? 0.08 : 0.06));
    canvas.drawCircle(Offset(cx, cy), 100,
        Paint()
          ..color = _ringColor(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    final shieldPath = _shieldPath(Offset(cx, cy - 4), 72);
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = accent.withValues(alpha: isDark ? 0.18 : 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawPath(shieldPath, Paint()..color = _cardBg(isDark));
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = _cardBorder(isDark, accent)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final checkPath = Path()
      ..moveTo(cx - 22, cy - 4)
      ..lineTo(cx - 6, cy + 14)
      ..lineTo(cx + 24, cy - 20);
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = accent
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    final linePaint = Paint()
      ..color = accent.withValues(alpha: isDark ? 0.2 : 0.15)
      ..strokeWidth = 1;
    for (final pos in [
      Offset(cx - 88, cy - 50),
      Offset(cx + 86, cy - 48),
      Offset(cx - 82, cy + 60),
      Offset(cx + 80, cy + 58),
    ]) {
      canvas.drawLine(pos, Offset(cx, cy - 4), linePaint);
      canvas.drawCircle(pos, 8, Paint()..color = _cardBg(isDark));
      canvas.drawCircle(pos, 8,
          Paint()
            ..color = accent.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      canvas.drawCircle(pos, 3, Paint()..color = accent);
    }
  }

  Path _shieldPath(Offset center, double size) {
    final path = Path();
    final w = size * 0.85;
    final h = size;
    path.moveTo(center.dx, center.dy - h);
    path.lineTo(center.dx + w, center.dy - h * 0.55);
    path.lineTo(center.dx + w, center.dy + h * 0.1);
    path.quadraticBezierTo(center.dx + w, center.dy + h * 0.5, center.dx, center.dy + h);
    path.quadraticBezierTo(center.dx - w, center.dy + h * 0.5, center.dx - w, center.dy + h * 0.1);
    path.lineTo(center.dx - w, center.dy - h * 0.55);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.isDark != isDark;
}

// Page 4: Professional workspace
class _ProfessionalPainter extends CustomPainter {
  const _ProfessionalPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const accent = AppColors.amber;

    canvas.drawCircle(Offset(cx, cy), 130,
        Paint()..color = accent.withValues(alpha: isDark ? 0.08 : 0.06));
    canvas.drawCircle(Offset(cx, cy), 100,
        Paint()
          ..color = _ringColor(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 110, height: 130),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = accent.withValues(alpha: isDark ? 0.18 : 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawRRect(cardRect, Paint()..color = _cardBg(isDark));
    canvas.drawRRect(cardRect,
        Paint()
          ..color = _cardBorder(isDark, accent)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 59), width: 36, height: 12),
        const Radius.circular(6),
      ),
      Paint()..color = accent,
    );

    final lineColor = isDark
        ? AppColors.textHint.withValues(alpha: 0.35)
        : const Color(0xFFCBD5E1);
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final y = cy - 16 + i * 20.0;
      final w = i == 0 ? 70.0 : i == 3 ? 45.0 : 80.0;
      canvas.drawLine(Offset(cx - w / 2, y), Offset(cx + w / 2, y), linePaint);
    }
    canvas.drawLine(
      Offset(cx - 35, cy - 16),
      Offset(cx + 35, cy - 16),
      Paint()
        ..color = accent.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    _drawStethoscope(canvas, Offset(cx - 72, cy - 72), isDark);
    _drawAvatarChip(canvas, Offset(cx + 82, cy - 52), AppColors.teal, isDark);
    _drawAvatarChip(canvas, Offset(cx + 82, cy - 18), AppColors.blue, isDark);
    _drawAvatarChip(canvas, Offset(cx + 82, cy + 16), AppColors.purple, isDark);

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 60, cy + 72), width: 56, height: 22),
      const Radius.circular(11),
    );
    canvas.drawRRect(badgeRect, Paint()..color = accent.withValues(alpha: 0.2));
    canvas.drawRRect(badgeRect,
        Paint()
          ..color = accent.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    final plusPaint = Paint()
      ..color = accent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 68, cy + 72), Offset(cx - 52, cy + 72), plusPaint);
    canvas.drawLine(Offset(cx - 60, cy + 64), Offset(cx - 60, cy + 80), plusPaint);
  }

  void _drawStethoscope(Canvas canvas, Offset center, bool isDark) {
    final paint = Paint()
      ..color = AppColors.amber
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - 14, center.dy - 10)
      ..cubicTo(center.dx - 14, center.dy + 10, center.dx + 14, center.dy + 10,
          center.dx + 14, center.dy - 10)
      ..moveTo(center.dx, center.dy + 10)
      ..lineTo(center.dx, center.dy + 32);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(center.dx, center.dy + 38), 10,
        Paint()..color = _cardBg(isDark));
    canvas.drawCircle(Offset(center.dx, center.dy + 38), 10,
        Paint()
          ..color = AppColors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }

  void _drawAvatarChip(Canvas canvas, Offset center, Color color, bool isDark) {
    canvas.drawCircle(center, 13, Paint()..color = _cardBg(isDark));
    canvas.drawCircle(center, 13,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(center, 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ProfessionalPainter old) => old.isDark != isDark;
}

// ─── Background grid ──────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}
