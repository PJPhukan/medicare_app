import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/adherence_entity.dart';
import '../../domain/entities/insight_entity.dart';
import '../providers/insights_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';

// ─── Day status enum ──────────────────────────────────────────────────────────

enum _DayStatus { perfect, good, partial, missed, noData, future }

// ─── Calendar builder ─────────────────────────────────────────────────────────

List<_DayStatus> _buildCalendar(List<DailyAdherenceEntity> daily) {
  final now = DateTime.now();
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

  final dailyMap = <int, DailyAdherenceEntity>{};
  for (final d in daily) {
    final dt = d.dateTime;
    if (dt.year == now.year && dt.month == now.month) { dailyMap[dt.day] = d; }
  }

  final result = <_DayStatus>[];
  for (var i = 0; i < firstWeekday; i++) result.add(_DayStatus.noData);
  for (var d = 1; d <= daysInMonth; d++) {
    if (d > now.day) {
      result.add(_DayStatus.future);
    } else {
      final entry = dailyMap[d];
      if (entry == null) {
        result.add(_DayStatus.noData);
      } else if (entry.rate >= 1.0) {
        result.add(_DayStatus.perfect);
      } else if (entry.rate >= 0.8) {
        result.add(_DayStatus.good);
      } else if (entry.rate >= 0.5) {
        result.add(_DayStatus.partial);
      } else {
        result.add(_DayStatus.missed);
      }
    }
  }
  return result;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  String _period = '30d';
  static const _periods = [('7d', '7D'), ('30d', '30D'), ('90d', '90D')];

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Insights', showAppBar: false);
    }
    final st = ref.watch(insightsProvider);
    final adherence = st.adherence;
    final insights = st.insights;

    final adherencePct = adherence == null ? 0 : (adherence.overallRate * 100).round();
    final accentColor = adherencePct >= 90
        ? AppColors.teal
        : adherencePct >= 60
            ? AppColors.amber
            : AppColors.red;

    final calendar = adherence == null ? <_DayStatus>[] : _buildCalendar(adherence.daily);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: AppText.h3(AppStrings.insights),
              ),
            ),

            if (st.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Period selector ───────────────────────────────────────
                    _PeriodSelector(
                      selected: _period,
                      periods: _periods,
                      onSelect: (p) => setState(() => _period = p),
                    ),
                    const SizedBox(height: 16),

                    // ── Hero score card ───────────────────────────────────────
                    _HeroScoreCard(
                      pct: adherencePct,
                      accent: accentColor,
                      taken: adherence?.takenDoses ?? 0,
                      total: adherence?.totalDoses ?? 0,
                      missed: adherence?.missedDoses ?? 0,
                      skipped: adherence?.skippedDoses ?? 0,
                    ),
                    const SizedBox(height: 16),

                    // ── Adherence calendar ────────────────────────────────────
                    if (calendar.isNotEmpty) ...[
                      _AdherenceCalendarCard(cells: calendar),
                      const SizedBox(height: 16),
                    ],

                    // ── Insights list ─────────────────────────────────────────
                    if (insights.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          AppText.labelMd(AppStrings.insights,
                              fontWeight: FontWeight.w700),
                          const SizedBox(width: 8),
                          AppContainer.tinted(
                            color: AppColors.teal,
                            borderRadius: AppBorderRadius.pill,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: AppText.labelXs('${insights.length}',
                                color: AppColors.teal, fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                      ...insights.map((i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _InsightCard(insight: i),
                          )),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Period selector ──────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final String selected;
  final List<(String, String)> periods;
  final ValueChanged<String> onSelect;

  const _PeriodSelector({
    required this.selected,
    required this.periods,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: periods.map((p) {
          final active = selected == p.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(p.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.teal : Colors.transparent,
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: AppText.labelSm(p.$2,
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Hero score card ──────────────────────────────────────────────────────────

class _HeroScoreCard extends StatelessWidget {
  final int pct;
  final Color accent;
  final int taken, total, missed, skipped;

  const _HeroScoreCard({
    required this.pct,
    required this.accent,
    required this.taken,
    required this.total,
    required this.missed,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = pct >= 90;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            accent.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: AppBorderRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Circular ring + score ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ring
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(110, 110),
                        painter: _RingPainter(
                          progress: pct / 100.0,
                          trackColor: Colors.white.withValues(alpha: 0.18),
                          fillColor: Colors.white,
                          strokeWidth: 9,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$pct',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todaysAdherence,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isGood ? AppStrings.onTrack : AppStrings.needsAttention,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$taken / $total ${AppStrings.ofScheduled}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),

          // ── Mini stat row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                _MiniStat(
                  icon: Icons.done_all_rounded,
                  label: AppStrings.dosesTakenToday,
                  value: '$taken',
                  iconColor: Colors.white,
                ),
                _Divider(),
                _MiniStat(
                  icon: Icons.cancel_outlined,
                  label: 'Missed',
                  value: '$missed',
                  iconColor: Colors.white.withValues(alpha: missed > 0 ? 1 : 0.5),
                ),
                _Divider(),
                _MiniStat(
                  icon: Icons.remove_circle_outline_rounded,
                  label: 'Skipped',
                  value: '$skipped',
                  iconColor: Colors.white.withValues(alpha: skipped > 0 ? 1 : 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.18),
      );
}

// ─── Circular ring painter ────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor, fillColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Adherence calendar card ──────────────────────────────────────────────────

class _AdherenceCalendarCard extends StatelessWidget {
  final List<_DayStatus> cells;

  const _AdherenceCalendarCard({required this.cells});

  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  Color _cellColor(_DayStatus s, BuildContext context) => switch (s) {
    _DayStatus.perfect => AppColors.teal,
    _DayStatus.good    => AppColors.teal.withValues(alpha: 0.38),
    _DayStatus.partial => AppColors.amber,
    _DayStatus.missed  => AppColors.red,
    _DayStatus.noData  => context.borderCol,
    _DayStatus.future  => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][now.month];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AppText.labelMd(AppStrings.adherenceCalendar,
                  fontWeight: FontWeight.w700),
              const Spacer(),
              AppText.bodySm('$monthLabel ${now.year}',
                  color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(color: AppColors.teal, label: AppStrings.perfectLabel),
              _LegendDot(color: AppColors.teal.withValues(alpha: 0.38), label: AppStrings.goodLabel),
              _LegendDot(color: AppColors.amber, label: AppStrings.partialLabel),
              _LegendDot(color: AppColors.red, label: AppStrings.missed),
            ],
          ),
          const SizedBox(height: 14),

          // Day labels
          Row(
            children: _days
                .map((d) => Expanded(
                      child: Center(
                        child: AppText.bodyXs(d, color: AppColors.textHint),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Cells
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1,
            ),
            itemCount: cells.length,
            itemBuilder: (_, i) {
              final status = cells[i];
              final isFuture = status == _DayStatus.future;
              final isBlank = status == _DayStatus.noData && i < 7;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isBlank ? Colors.transparent : _cellColor(status, context),
                  borderRadius: AppBorderRadius.smAll,
                  border: (isFuture || isBlank)
                      ? Border.all(
                          color: isFuture
                              ? context.borderCol.withValues(alpha: 0.4)
                              : Colors.transparent,
                          width: 0.5,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: AppBorderRadius.xsAll),
        ),
        const SizedBox(width: 4),
        AppText.bodyXs(label, color: AppColors.textHint),
      ],
    );
  }
}

// ─── Insight card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final InsightEntity insight;
  const _InsightCard({required this.insight});

  Color get _accent => insight.isCritical
      ? AppColors.red
      : insight.isWarning
          ? AppColors.amber
          : AppColors.teal;

  IconData get _icon => insight.isCritical
      ? Icons.error_outline_rounded
      : insight.isWarning
          ? Icons.warning_amber_rounded
          : Icons.info_outline_rounded;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppContainer.tinted(
                      color: _accent,
                      borderRadius: AppBorderRadius.smAll,
                      padding: const EdgeInsets.all(6),
                      child: Icon(_icon, size: 14, color: _accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.labelSm(insight.title,
                              color: _accent, fontWeight: FontWeight.w700),
                          const SizedBox(height: 3),
                          AppText.bodySm(insight.body,
                              color: AppColors.textSecondary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
