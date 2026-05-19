import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/banner_config.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../shared/widgets/charts.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

enum _DoseStatus { taken, skipped, missed, pending }

class _Dose {
  _Dose(this.name, this.time, this.status);
  final String name;
  final String time;
  _DoseStatus status;
}

// Mock sparkline history for each vital
const _systolicPoints  = [118.0, 122.0, 119.0, 124.0, 117.0, 121.0, 120.0];
const _diastolicPoints = [79.0, 83.0, 78.0, 82.0, 76.0, 81.0, 80.0];
const _heartRatePoints = [70.0, 74.0, 71.0, 76.0, 68.0, 73.0, 72.0];

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final List<_Dose> _doses;
  BannerConfig? _bannerConfig;

  @override
  void initState() {
    super.initState();
    _doses = [
      _Dose('Metformin 500mg',   '8:00 AM',  _DoseStatus.taken),
      _Dose('Amlodipine 5mg',    '12:00 PM', _DoseStatus.taken),
      _Dose('Vitamin D3',        '6:00 PM',  _DoseStatus.pending),
      _Dose('Omega-3 Capsule',   '9:00 PM',  _DoseStatus.pending),
    ];
    BannerConfig.fetch().then((c) {
      if (mounted) setState(() => _bannerConfig = c);
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.goodMorning;
    if (h < 17) return AppStrings.goodAfternoon;
    if (h < 21) return AppStrings.goodEvening;
    return AppStrings.goodNight;
  }

  int get _takenCount   => _doses.where((d) => d.status == _DoseStatus.taken).length;
  int get _adherence    => _doses.isEmpty ? 100 : ((_takenCount / _doses.length) * 100).round();

  void _markDose(int i, _DoseStatus s) => setState(() => _doses[i].status = s);

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgPage    = isDark ? context.bg : AppColors.light100;
    final bgCard    = isDark ? context.cardBg : Colors.white;
    final border    = isDark ? context.borderCol : const Color(0xFFE2E8F0);
    final secondary = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final textColor = isDark ? context.primaryText : const Color(0xFF1A202C);

    return Scaffold(
      backgroundColor: bgPage,
      body: CustomScrollView(
        slivers: [

          // ── Greeting app bar ───────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: bgPage,
            pinned: true,
            floating: false,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, color: textColor, size: 22),
              onPressed: openAppSidebar,
              tooltip: 'Menu',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_greeting, Arjun 👋',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 19, fontWeight: FontWeight.w800,
                      color: textColor, letterSpacing: -0.3,
                    )),
                Text(AppStrings.todayOverview,
                    style: GoogleFonts.inter(fontSize: 12, color: secondary)),
              ],
            ),
            actions: [
              _NotifBell(count: 3),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  width: 34, height: 34,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: Text('AK',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.teal,
                      )),
                ),
              ),
            ],
          ),

          // ── Promo banners ──────────────────────────────────────────────────
          if (_bannerConfig != null && _bannerConfig!.shouldShow)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 18),
                child: Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.98,
                    child: _BannerCarousel(banners: _bannerConfig!.banners),
                  ),
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Stat cards ─────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    value: '$_adherence%',
                    label: AppStrings.adherenceRate,
                    color: AppColors.teal,
                    bgCard: bgCard, border: border,
                    badge: _StatBadge(
                      icon: Icons.arrow_upward_rounded,
                      label: '12% vs last week',
                      color: AppColors.green,
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    value: '2',
                    label: AppStrings.upcoming,
                    color: AppColors.purple,
                    bgCard: bgCard, border: border,
                    badge: _StatBadge(
                      label: 'Appointments',
                      color: AppColors.purple,
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.inventory_2_outlined,
                    value: '1',
                    label: 'Low stock',
                    color: AppColors.amber,
                    bgCard: bgCard, border: border,
                    badge: _StatBadge(
                      label: 'View details',
                      color: AppColors.amber,
                    ),
                  )),
                ]),
                const SizedBox(height: 24),

                // ── Today's medicines ──────────────────────────────────────
                _SectionHeader(
                  title: AppStrings.todayMedicines,
                  subtitle: '$_takenCount/${_doses.length} ${AppStrings.taken}',
                  onViewAll: () {},
                ),
                const SizedBox(height: 10),
                _card(bgCard, border,
                  child: Column(
                    children: List.generate(_doses.length, (i) {
                      final d = _doses[i];
                      final isLast = i == _doses.length - 1;
                      return Column(children: [
                        _DoseRow(
                          dose: d,
                          onTake: () => _markDose(i, _DoseStatus.taken),
                          onSkip: () => _markDose(i, _DoseStatus.skipped),
                        ),
                        if (!isLast) Divider(height: 1, color: border),
                      ]);
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Recent vitals ──────────────────────────────────────────
                _SectionHeader(title: AppStrings.recentVitals, onViewAll: () {}),
                const SizedBox(height: 10),
                _card(bgCard, border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monitor_heart_outlined, size: 16, color: AppColors.blue),
                          const SizedBox(width: 6),
                          Text('Blood Pressure',
                              style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w600, color: secondary,
                              )),
                          const Spacer(),
                          Text('Today, 9:00 AM',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: secondary.withValues(alpha: 0.7),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _VitalChip(
                            label: AppStrings.systolic,
                            value: '120', unit: AppStrings.mmHg,
                            color: AppColors.teal,
                            sparkPoints: _systolicPoints,
                            bgCard: bgCard, border: border,
                          ),
                          const SizedBox(width: 10),
                          _VitalChip(
                            label: AppStrings.diastolic,
                            value: '80', unit: AppStrings.mmHg,
                            color: AppColors.blue,
                            sparkPoints: _diastolicPoints,
                            bgCard: bgCard, border: border,
                          ),
                          const SizedBox(width: 10),
                          _VitalChip(
                            label: AppStrings.heartRate,
                            value: '72', unit: AppStrings.bpm,
                            color: AppColors.purple,
                            sparkPoints: _heartRatePoints,
                            bgCard: bgCard, border: border,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quick actions ──────────────────────────────────────────
                _SectionHeader(title: AppStrings.quickActions),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    _QuickAction(
                      icon: Icons.medication_outlined,
                      label: AppStrings.addMedicine,
                      subtitle: 'Set medicine reminder',
                      color: AppColors.teal,
                      bgCard: bgCard, border: border,
                      onTap: () {},
                    ),
                    _QuickAction(
                      icon: Icons.monitor_heart_outlined,
                      label: AppStrings.addVital,
                      subtitle: 'Record your health',
                      color: AppColors.blue,
                      bgCard: bgCard, border: border,
                      onTap: () {},
                    ),
                    _QuickAction(
                      icon: Icons.calendar_today_outlined,
                      label: AppStrings.addAppointment,
                      subtitle: 'Schedule a visit',
                      color: AppColors.purple,
                      bgCard: bgCard, border: border,
                      onTap: () {},
                    ),
                    _QuickAction(
                      icon: Icons.emergency_outlined,
                      label: AppStrings.sos,
                      subtitle: 'Emergency assistance',
                      color: AppColors.error,
                      bgCard: bgCard, border: border,
                      onTap: () {},
                    ),
                  ],
                ),

              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification bell ────────────────────────────────────────────────────────

class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 24,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            top: 6, right: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Center(
                child: Text('$count',
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white,
                    )),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgCard,
    required this.border,
    required this.badge,
  });

  final IconData icon;
  final String  value;
  final String  label;
  final Color   color;
  final Color   bgCard;
  final Color   border;
  final Widget  badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.smAll,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const Spacer(),
              SizedBox(
                width: 22, height: 22,
                child: Icon(Icons.more_horiz_rounded,
                    size: 16,
                    color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTypography.statMd.copyWith(color: color, height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textHint,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          badge,
        ],
      ),
    );
  }
}

// ─── Stat badge ───────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.color,
    this.icon,
  });

  final String   label;
  final Color    color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(label,
                style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700, color: color,
                ),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.onViewAll});
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: isDark ? context.primaryText : const Color(0xFF1A202C),
                  )),
              if (subtitle != null)
                Text(subtitle!,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(AppStrings.viewAll,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal,
                )),
          ),
      ],
    );
  }
}

// ─── Card wrapper ─────────────────────────────────────────────────────────────

Widget _card(Color bg, Color border, {required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: AppBorderRadius.xlAll,
      border: Border.all(color: border),
    ),
    child: child,
  );
}

// ─── Dose row ─────────────────────────────────────────────────────────────────

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose, required this.onTake, required this.onSkip});
  final _Dose dose;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final textColor = isDark ? context.primaryText    : const Color(0xFF1A202C);

    final (statusColor, statusLabel) = switch (dose.status) {
      _DoseStatus.taken   => (AppColors.green, AppStrings.taken),
      _DoseStatus.skipped => (AppColors.amber, AppStrings.skip),
      _DoseStatus.missed  => (AppColors.error, AppStrings.missed),
      _DoseStatus.pending => (AppColors.textHint, AppStrings.pending),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              borderRadius: AppBorderRadius.smAll,
            ),
            child: const Icon(Icons.medication_rounded, size: 18, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dose.name,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 10, color: secondary),
                    const SizedBox(width: 3),
                    Text(dose.time,
                        style: GoogleFonts.inter(fontSize: 11, color: secondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (dose.status == _DoseStatus.pending) ...[
            _ActionBtn(Icons.check_rounded, AppColors.green, onTake),
            const SizedBox(width: 6),
            _ActionBtn(Icons.close_rounded, AppColors.amber, onSkip),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.pill,
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
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

// ─── Vital chip (with sparkline) ──────────────────────────────────────────────

class _VitalChip extends StatelessWidget {
  const _VitalChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.sparkPoints,
    required this.bgCard,
    required this.border,
  });

  final String       label;
  final String       value;
  final String       unit;
  final Color        color;
  final List<double> sparkPoints;
  final Color        bgCard;
  final Color        border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? context.inputBg : AppColors.light200;

    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 9, color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18, fontWeight: FontWeight.w800,
                            color: color, height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: GoogleFonts.inter(
                            fontSize: 9, color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Sparkline flush to bottom edge, no side padding
            MiniSparkline(
              points: sparkPoints,
              color: color,
              height: 30,
              strokeWidth: 1.5,
              filled: true,
              fillOpacity: 0.22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick action button ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgCard,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final String   subtitle;
  final Color    color;
  final Color    bgCard;
  final Color    border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? context.primaryText : const Color(0xFF1A202C);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.smAll,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700, color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Banner carousel ──────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.banners});
  final List<DashboardBanner> banners;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _ctrl;
  late final Timer _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl  = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % widget.banners.length;
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isDark ? context.inputBg : AppColors.light200,
            child: const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
              ),
            ),
          ),
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
                      Text(banner.title!,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: -0.2,
                          )),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(banner.subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.72),
                          )),
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
