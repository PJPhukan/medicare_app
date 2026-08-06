import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CelebrationOverlay {
  static OverlayEntry? _activeEntry;

  static void show(BuildContext context) {
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _CelebrationParticleWidget(
        onDone: () {
          entry.remove();
          if (_activeEntry == entry) _activeEntry = null;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _CelebrationParticleWidget extends StatefulWidget {
  final VoidCallback onDone;
  const _CelebrationParticleWidget({required this.onDone});

  @override
  State<_CelebrationParticleWidget> createState() =>
      _CelebrationParticleWidgetState();
}

class _CelebrationParticleWidgetState extends State<_CelebrationParticleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rng = math.Random();

  static const _colors = [
    AppColors.teal,
    AppColors.green,
    AppColors.amber,
    AppColors.blue,
    AppColors.purple,
    AppColors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          widget.onDone();
        }
      });

    _particles = List.generate(45, (_) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 120.0 + _rng.nextDouble() * 260.0;
      return _Particle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 160.0,
        color: _colors[_rng.nextInt(_colors.length)],
        size: 5.0 + _rng.nextDouble() * 7.0,
        spin: (_rng.nextDouble() - 0.5) * 6.0,
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cx = size.width / 2;
    final cy = size.height * 0.4;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          final opacity = (1.0 - t).clamp(0.0, 1.0);

          return CustomPaint(
            size: Size.infinite,
            painter: _CelebrationPainter(
              particles: _particles,
              t: t,
              opacity: opacity,
              cx: cx,
              cy: cy,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double spin;
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.spin,
  });
}

class _CelebrationPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final double opacity;
  final double cx;
  final double cy;

  _CelebrationPainter({
    required this.particles,
    required this.t,
    required this.opacity,
    required this.cx,
    required this.cy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 400.0;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final x = cx + p.vx * t;
      final y = cy + p.vy * t + 0.5 * gravity * t * t;
      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter old) => old.t != t;
}
