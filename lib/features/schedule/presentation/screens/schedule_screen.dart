import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import 'add_appointment_screen.dart';

// ─── Mock dose data ───────────────────────────────────────────────────────────

enum _DoseStatus { taken, skipped, pending }

enum _FoodTiming { before, with_, after }

class _Dose {
  _Dose({
    required this.name,
    required this.time,
    required this.unit,
    required this.foodTiming,
    required this.status,
  });
  final String name;
  final String time; // "08:00"
  final String unit;
  final _FoodTiming foodTiming;
  _DoseStatus status;
}

String _foodLabel(_FoodTiming t) => switch (t) {
      _FoodTiming.before => AppStrings.beforeFood,
      _FoodTiming.with_  => AppStrings.withFood,
      _FoodTiming.after  => AppStrings.afterFood,
    };

String _timeGroup(String hhmm) {
  final h = int.parse(hhmm.split(':')[0]);
  if (h >= 5 && h < 12) return 'Morning';
  if (h >= 12 && h < 17) return 'Afternoon';
  if (h >= 17 && h < 21) return 'Evening';
  return 'Night';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late final List<_Dose> _doses;
  late final List<DateTime> _week;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _week = List.generate(14, (i) => today.subtract(const Duration(days: 3)).add(Duration(days: i)));
    _doses = [
      _Dose(name: 'Metformin 500mg',  time: '08:00', unit: '1 tablet',  foodTiming: _FoodTiming.after,  status: _DoseStatus.taken),
      _Dose(name: 'Amlodipine 5mg',   time: '12:00', unit: '1 tablet',  foodTiming: _FoodTiming.with_,  status: _DoseStatus.taken),
      _Dose(name: 'Vitamin D3',        time: '13:30', unit: '1 capsule', foodTiming: _FoodTiming.after,  status: _DoseStatus.pending),
      _Dose(name: 'Omega-3 Capsule',   time: '18:00', unit: '2 capsules',foodTiming: _FoodTiming.after,  status: _DoseStatus.pending),
      _Dose(name: 'Pantoprazole 40mg', time: '21:00', unit: '1 tablet',  foodTiming: _FoodTiming.before, status: _DoseStatus.pending),
    ];
  }

  Future<void> _openAddDose() async {
    final input = await showAddDoseSheet(context);
    if (input == null || !mounted) return;
    setState(() {
      _doses.add(_Dose(
        name: input.name,
        time: input.time,
        unit: input.unit,
        foodTiming: switch (input.foodTiming) {
          DoseFoodTiming.before => _FoodTiming.before,
          DoseFoodTiming.with_  => _FoodTiming.with_,
          DoseFoodTiming.after  => _FoodTiming.after,
        },
        status: _DoseStatus.pending,
      ));
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.doseAdded,
            style: GoogleFonts.inter(fontSize: 13, color: context.primaryText)),
        backgroundColor: context.inputBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, List<_Dose>> get _grouped {
    final order = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final map = <String, List<_Dose>>{for (final g in order) g: []};
    for (final d in _doses) {
      map[_timeGroup(d.time)]!.add(d);
    }
    return {
      for (final g in order)
        if (map[g]!.isNotEmpty) g: map[g]!,
    };
  }

  void _mark(int i, _DoseStatus s) {
    setState(() => _doses[i].status = s);
    if (s == _DoseStatus.taken) _showCelebration();
  }

  void _showCelebration() {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CelebrationOverlay(onDone: () {
        entry.remove();
      }),
    );
    Overlay.of(context).insert(entry);
  }

  static const _groupMeta = {
    'Morning':   (icon: Icons.wb_sunny_rounded,        color: Color(0xFFF59E0B), range: '5 AM – 12 PM'),
    'Afternoon': (icon: Icons.wb_cloudy_rounded,        color: Color(0xFF4D9EFF), range: '12 PM – 5 PM'),
    'Evening':   (icon: Icons.nights_stay_rounded,      color: Color(0xFFA855F7), range: '5 PM – 9 PM'),
    'Night':     (icon: Icons.dark_mode_rounded,        color: Color(0xFF8B9BB4), range: '9 PM – 5 AM'),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgPage = isDark ? context.bg : AppColors.light100;
    final bgCard = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : const Color(0xFFE2E8F0);
    final textColor = isDark ? context.primaryText : const Color(0xFF1A202C);
    final secondary = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    final takenCount   = _doses.where((d) => d.status == _DoseStatus.taken).length;
    final pendingCount = _doses.where((d) => d.status == _DoseStatus.pending).length;
    final skippedCount = _doses.where((d) => d.status == _DoseStatus.skipped).length;

    return Scaffold(
      backgroundColor: bgPage,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: bgPage,
            pinned: true,
            floating: false,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, size: 22, color: textColor),
              onPressed: openAppSidebar,
              tooltip: 'Menu',
            ),
            title: Text(AppStrings.doseSchedule,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: textColor, letterSpacing: -0.3,
                )),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: AppColors.teal,
                onPressed: _openAddDose,
                tooltip: 'Add dose',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date strip ──────────────────────────────────────────────
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _week.length,
                    itemBuilder: (_, i) {
                      final day = _week[i];
                      final selected = _isSameDay(day, _selectedDate);
                      final isToday = _isToday(day);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          width: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.teal
                                : isDark ? context.cardBg : Colors.white,
                            borderRadius: AppBorderRadius.lgAll,
                            border: Border.all(
                              color: selected
                                  ? AppColors.teal
                                  : isToday
                                      ? AppColors.teal.withValues(alpha: 0.4)
                                      : border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ['Mo','Tu','We','Th','Fr','Sa','Su'][day.weekday - 1],
                                style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.textInverse
                                      : isToday ? AppColors.teal : secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${day.day}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17, fontWeight: FontWeight.w800,
                                    color: selected
                                        ? AppColors.textInverse
                                        : textColor,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Summary chips ────────────────────────────────────────────
                if (_doses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        if (takenCount > 0)
                          _SummaryChip('✓ $takenCount ${AppStrings.taken}', AppColors.green),
                        if (pendingCount > 0)
                          _SummaryChip('⏳ $pendingCount ${AppStrings.pending}', AppColors.amber),
                        if (skippedCount > 0)
                          _SummaryChip('✕ $skippedCount ${AppStrings.skip}', AppColors.error),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Dose timeline by group ────────────────────────────────────
                if (_grouped.isEmpty)
                  _EmptyDoses(isDark: isDark, secondary: secondary, textColor: textColor, onAdd: _openAddDose)
                else
                  ...() {
                    final grouped = _grouped;
                    return grouped.entries.map((entry) {
                      final meta = _groupMeta[entry.key]!;
                      return _GroupSection(
                        group: entry.key,
                        range: meta.range,
                        icon: meta.icon,
                        color: meta.color,
                        doses: entry.value,
                        allDoses: _doses,
                        onMark: _mark,
                        bgCard: bgCard,
                        border: border,
                        textColor: textColor,
                        secondary: secondary,
                      );
                    });
                  }(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary chip ─────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700, color: color,
          )),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyDoses extends StatelessWidget {
  const _EmptyDoses({required this.isDark, required this.secondary, required this.textColor, required this.onAdd});
  final bool isDark;
  final Color secondary;
  final Color textColor;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(
            color: isDark ? context.borderCol : const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.medication_outlined, size: 36, color: secondary),
            const SizedBox(height: 12),
            Text(AppStrings.noMedicinesYet,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, fontWeight: FontWeight.w700, color: textColor,
                )),
            const SizedBox(height: 4),
            Text('No doses scheduled for this day.',
                style: GoogleFonts.inter(fontSize: 12, color: secondary)),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Dose Schedule'),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Time group section ───────────────────────────────────────────────────────

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.range,
    required this.icon,
    required this.color,
    required this.doses,
    required this.allDoses,
    required this.onMark,
    required this.bgCard,
    required this.border,
    required this.textColor,
    required this.secondary,
  });

  final String group;
  final String range;
  final IconData icon;
  final Color color;
  final List<_Dose> doses;
  final List<_Dose> allDoses;
  final void Function(int, _DoseStatus) onMark;
  final Color bgCard;
  final Color border;
  final Color textColor;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(group,
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color,
                    )),
                const SizedBox(width: 6),
                Text(range,
                    style: GoogleFonts.inter(fontSize: 11, color: secondary)),
              ],
            ),
          ),
          // Dose cards
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: AppBorderRadius.xlAll,
              border: Border.all(color: border),
            ),
            child: Column(
              children: List.generate(doses.length, (i) {
                final dose = doses[i];
                final globalIndex = allDoses.indexOf(dose);
                final isLast = i == doses.length - 1;
                return Column(children: [
                  _DoseRow(
                    dose: dose,
                    onTake: () => onMark(globalIndex, _DoseStatus.taken),
                    onSkip: () => onMark(globalIndex, _DoseStatus.skipped),
                    textColor: textColor,
                    secondary: secondary,
                  ),
                  if (!isLast) Divider(height: 1, color: border),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dose row ─────────────────────────────────────────────────────────────────

class _DoseRow extends StatelessWidget {
  const _DoseRow({
    required this.dose,
    required this.onTake,
    required this.onSkip,
    required this.textColor,
    required this.secondary,
  });

  final _Dose dose;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final Color textColor;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (dose.status) {
      _DoseStatus.taken   => (AppColors.green, AppStrings.taken),
      _DoseStatus.skipped => (AppColors.amber, AppStrings.skip),
      _DoseStatus.pending => (AppColors.textHint, AppStrings.pending),
    };

    // Format "08:00" → "8:00 AM"
    final parts = dose.time.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final timeLabel = '${h > 12 ? h - 12 : h == 0 ? 12 : h}:$m ${h >= 12 ? 'PM' : 'AM'}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 48,
            child: Text(timeLabel,
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: secondary,
                )),
          ),
          const SizedBox(width: 10),

          // Pill icon
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              borderRadius: AppBorderRadius.smAll,
            ),
            child: const Icon(Icons.medication_rounded, size: 17, color: AppColors.teal),
          ),
          const SizedBox(width: 10),

          // Name + detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dose.name,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis),
                Text('${dose.unit} · ${_foodLabel(dose.foodTiming)}',
                    style: GoogleFonts.inter(fontSize: 11, color: secondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status / actions
          if (dose.status == _DoseStatus.pending) ...[
            _ActionBtn(Icons.check_rounded, AppColors.green, onTake),
            const SizedBox(width: 6),
            _ActionBtn(Icons.close_rounded, AppColors.amber, onSkip),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.pill,
              ),
              child: Text(statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700, color: statusColor,
                  )),
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(this.icon, this.color, this.onTap);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppBorderRadius.smAll,
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

// ─── Celebration overlay ──────────────────────────────────────────────────────

class _CelebrationOverlay extends StatefulWidget {
  final VoidCallback onDone;
  const _CelebrationOverlay({required this.onDone});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();

    _particles = List.generate(28, (i) => _Particle(
      x: _rng.nextDouble(),
      y: 0.45 + _rng.nextDouble() * 0.2,
      vx: (_rng.nextDouble() - 0.5) * 0.6,
      vy: -0.3 - _rng.nextDouble() * 0.5,
      color: _colors[i % _colors.length],
      size: 6 + _rng.nextDouble() * 8,
      rotation: _rng.nextDouble() * math.pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 6,
      shape: _rng.nextBool(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          final fadeOut = t > 0.7 ? 1.0 - ((t - 0.7) / 0.3) : 1.0;
          return Stack(
            children: [
              // Particles
              ..._particles.map((p) {
                final px = (p.x + p.vx * t) * size.width;
                final py = (p.y + p.vy * t + 0.5 * 0.8 * t * t) * size.height;
                final opacity = (fadeOut * (1.0 - t * 0.5)).clamp(0.0, 1.0);
                return Positioned(
                  left: px - p.size / 2,
                  top: py - p.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: p.rotation + p.rotSpeed * t,
                      child: p.shape
                          ? Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          : Container(
                              width: p.size * 0.6,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                    ),
                  ),
                );
              }),

              // Central checkmark burst
              if (t < 0.6)
                Center(
                  child: Opacity(
                    opacity: (t < 0.3
                        ? t / 0.3
                        : t < 0.5
                            ? 1.0
                            : 1.0 - ((t - 0.5) / 0.1)).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: t < 0.25
                          ? Curves.elasticOut.transform(t / 0.25) * 1.1
                          : 1.0,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.5),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x, y, vx, vy, size, rotation, rotSpeed;
  final Color color;
  final bool shape; // true = square, false = oval

  const _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.size,
    required this.rotation, required this.rotSpeed,
    required this.shape,
  });
}
