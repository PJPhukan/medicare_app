import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onDone});
  final VoidCallback? onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Controllers ──────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _ripple1Ctrl;
  late final AnimationController _ripple2Ctrl;
  late final AnimationController _ripple3Ctrl;
  late final AnimationController _wordmarkCtrl;
  late final AnimationController _progressCtrl;

  // ─── Animations ───────────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoGlow;
  late final Animation<double> _pulseScale;

  late final Animation<double> _ripple1Scale;
  late final Animation<double> _ripple1Opacity;
  late final Animation<double> _ripple2Scale;
  late final Animation<double> _ripple2Opacity;
  late final Animation<double> _ripple3Scale;
  late final Animation<double> _ripple3Opacity;

  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineOpacity;

  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _startSequence();
  }

  void _setupControllers() {
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Pulse happens once after logo appears
    _ripple1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripple2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripple3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _wordmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  void _setupAnimations() {
    // ── Logo ──
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.7, curve: Curves.elasticOut)),
    );
    _logoGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.4, 1, curve: Curves.easeOut)),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 60),
    ]).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.6, 1, curve: Curves.easeInOut)));

    // ── Ripple rings ──
    _ripple1Scale   = Tween<double>(begin: 1, end: 2.6).animate(CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut));
    _ripple1Opacity = Tween<double>(begin: 0.5, end: 0).animate(CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut));
    _ripple2Scale   = Tween<double>(begin: 1, end: 2.6).animate(CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut));
    _ripple2Opacity = Tween<double>(begin: 0.35, end: 0).animate(CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut));
    _ripple3Scale   = Tween<double>(begin: 1, end: 2.6).animate(CurvedAnimation(parent: _ripple3Ctrl, curve: Curves.easeOut));
    _ripple3Opacity = Tween<double>(begin: 0.2, end: 0).animate(CurvedAnimation(parent: _ripple3Ctrl, curve: Curves.easeOut));

    // ── Wordmark ──
    _wordmarkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOut),
    );
    _wordmarkSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _wordmarkCtrl, curve: const Interval(0.4, 1, curve: Curves.easeOut)),
    );

    // ── Progress bar ──
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // 1. Logo pops in + pulse
    _logoCtrl.forward();

    // 2. Ripple rings staggered after logo appears
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _ripple1Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple2Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple3Ctrl.forward();

    // 3. Wordmark slides up
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _wordmarkCtrl.forward();

    // 4. Progress bar starts
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _progressCtrl.forward();

    // 5. Done
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    widget.onDone?.call();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _ripple1Ctrl.dispose();
    _ripple2Ctrl.dispose();
    _ripple3Ctrl.dispose();
    _wordmarkCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? context.bg : const Color(0xFFF8FAFC);
    final textPri = isDark ? context.primaryText : const Color(0xFF1A202C);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    // Light mode needs a stronger glow so it's visible on white
    final glowAlpha = isDark ? 0.08 : 0.18;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Subtle background glow ──
          AnimatedBuilder(
            animation: _logoGlow,
            builder: (_, __) => Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.15),
                    radius: 0.8,
                    colors: [
                      AppColors.teal.withValues(alpha: glowAlpha * _logoGlow.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Center content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo + ripples ──
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple ring 3 (outermost)
                      _RippleRing(
                        scaleAnim: _ripple3Scale,
                        opacityAnim: _ripple3Opacity,
                        size: 88,
                        color: AppColors.teal,
                      ),
                      // Ripple ring 2
                      _RippleRing(
                        scaleAnim: _ripple2Scale,
                        opacityAnim: _ripple2Opacity,
                        size: 88,
                        color: AppColors.teal,
                      ),
                      // Ripple ring 1 (closest)
                      _RippleRing(
                        scaleAnim: _ripple1Scale,
                        opacityAnim: _ripple1Opacity,
                        size: 88,
                        color: AppColors.teal,
                      ),

                      // Logo mark
                      AnimatedBuilder(
                        animation: Listenable.merge([_logoCtrl]),
                        builder: (_, __) => Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value * _pulseScale.value,
                            child: _LogoMark(isDark: isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Wordmark ──
                AnimatedBuilder(
                  animation: _wordmarkCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _wordmarkOpacity.value,
                    child: SlideTransition(
                      position: _wordmarkSlide,
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: textPri,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _wordmarkCtrl,
                        builder: (_, child) => Opacity(
                          opacity: _taglineOpacity.value,
                          child: child,
                        ),
                        child: Text(
                          AppStrings.appTagline,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textSec,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom progress bar ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36, left: 48, right: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Track
                    ClipRRect(
                      borderRadius: AppBorderRadius.pill,
                      child: SizedBox(
                        height: 2,
                        child: AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor: isDark
                                ? context.borderCol
                                : const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
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

// ─── Logo mark widget ──────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal, Color(0xFF00B89E)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const SizedBox(
        width: 88,
        height: 88,
        child: Center(
          child: _HeartCrossIcon(),
        ),
      ),
    );
  }
}

// ─── Custom heart + cross icon ────────────────────────────────────────────────

class _HeartCrossIcon extends StatelessWidget {
  const _HeartCrossIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(44, 44),
      painter: _HeartCrossPainter(),
    );
  }
}

class _HeartCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Medical cross (plus sign)
    final crossW = size.width * 0.18;
    final crossH = size.height * 0.42;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: crossW, height: crossH),
        const Radius.circular(3),
      ),
      paint,
    );
    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: crossH, height: crossW),
        const Radius.circular(3),
      ),
      paint,
    );

    // Small heart shape below the cross (subtle)
    final heartPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    final hx = cx;
    final hy = cy + size.height * 0.24;
    final hr = size.width * 0.14;

    heartPath.moveTo(hx, hy + hr * 0.8);
    heartPath.cubicTo(hx - hr * 2, hy - hr * 0.5, hx - hr * 2, hy + hr * 1.2, hx, hy + hr * 1.8);
    heartPath.cubicTo(hx + hr * 2, hy + hr * 1.2, hx + hr * 2, hy - hr * 0.5, hx, hy + hr * 0.8);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(_HeartCrossPainter old) => false;
}

// ─── Ripple ring ──────────────────────────────────────────────────────────────

class _RippleRing extends StatelessWidget {
  const _RippleRing({
    required this.scaleAnim,
    required this.opacityAnim,
    required this.size,
    required this.color,
  });

  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnim, opacityAnim]),
      builder: (_, __) => Transform.scale(
        scale: scaleAnim.value,
        child: Opacity(
          opacity: opacityAnim.value.clamp(0.0, 1.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
