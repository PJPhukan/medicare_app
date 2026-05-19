import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Mock data models ─────────────────────────────────────────────────────────

enum _DayStatus { perfect, good, partial, missed, noData, future }

class _MedStat {
  final String name;
  final int taken;
  final int scheduled;
  const _MedStat(this.name, this.taken, this.scheduled);
  double get rate => scheduled == 0 ? 0 : taken / scheduled;
}

class _SlotStat {
  final String label;
  final double missRate; // 0.0–1.0
  const _SlotStat(this.label, this.missRate);
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kMeds = [
  _MedStat('Metformin 500mg', 2, 2),
  _MedStat('Amlodipine 5mg', 1, 1),
  _MedStat('Aspirin 75mg', 0, 1),
  _MedStat('Vitamin D3', 1, 1),
];

const _kSlots = [
  _SlotStat('Early Morning', 0.1),
  _SlotStat('Morning', 0.22),
  _SlotStat('Afternoon', 0.48),
  _SlotStat('Evening', 0.35),
];

// Calendar: generate a month's worth of statuses
List<_DayStatus> _buildCalendar() {
  final now = DateTime.now();
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7; // 0=Sun

  const pattern = [
    _DayStatus.perfect, _DayStatus.perfect, _DayStatus.good,
    _DayStatus.partial, _DayStatus.missed, _DayStatus.perfect,
    _DayStatus.perfect,
  ];

  final result = <_DayStatus>[];
  // Leading blanks for alignment
  for (var i = 0; i < firstWeekday; i++) {
    result.add(_DayStatus.noData);
  }
  for (var d = 1; d <= daysInMonth; d++) {
    if (d > now.day) {
      result.add(_DayStatus.future);
    } else {
      result.add(pattern[(d - 1) % pattern.length]);
    }
  }
  return result;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = _buildCalendar();
    final totalScheduled = _kMeds.fold(0, (s, m) => s + m.scheduled);
    final totalTaken = _kMeds.fold(0, (s, m) => s + m.taken);
    final adherencePct = totalScheduled == 0
        ? 0
        : ((totalTaken / totalScheduled) * 100).round();
    final lowStock = 1; // mock
    final activeMeds = _kMeds.length;

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
                title: Text(AppStrings.insights, style: AppTypography.h3),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Hero stat grid ──────────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.35,
                    children: [
                      _StatCard(
                        label: AppStrings.todaysAdherence,
                        value: '$adherencePct%',
                        accent: adherencePct >= 90
                            ? AppColors.teal
                            : adherencePct >= 60
                                ? AppColors.amber
                                : AppColors.red,
                        icon: Icons.check_circle_outline_rounded,
                        sub: adherencePct >= 90
                            ? AppStrings.onTrack
                            : AppStrings.needsAttention,
                      ),
                      _StatCard(
                        label: AppStrings.activeMedicinesLabel,
                        value: '$activeMeds',
                        accent: AppColors.blue,
                        icon: Icons.medication_outlined,
                        sub: AppStrings.totalPrescribed,
                      ),
                      _StatCard(
                        label: AppStrings.dosesTakenToday,
                        value: '$totalTaken / $totalScheduled',
                        accent: AppColors.green,
                        icon: Icons.done_all_rounded,
                        sub: AppStrings.ofScheduled,
                      ),
                      _StatCard(
                        label: AppStrings.filterLowStock,
                        value: '$lowStock',
                        accent: lowStock > 0 ? AppColors.amber : AppColors.teal,
                        icon: Icons.inventory_2_outlined,
                        sub: lowStock > 0
                            ? AppStrings.reorderNeeded
                            : AppStrings.allWellStocked,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Adherence calendar ──────────────────────────────────────
                  _SectionCard(
                    title: AppStrings.adherenceCalendar,
                    child: _AdherenceCalendar(cells: calendar),
                  ),
                  const SizedBox(height: 12),

                  // ── Per-medicine bars ───────────────────────────────────────
                  _SectionCard(
                    title: AppStrings.perMedicineToday,
                    child: Column(
                      children: _kMeds
                          .map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MedBar(med: m),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Miss pattern bars ───────────────────────────────────────
                  _SectionCard(
                    title: AppStrings.missPatternToday,
                    child: Column(
                      children: _kSlots
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SlotBar(slot: s),
                              ))
                          .toList(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final String sub;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTypography.statMd.copyWith(color: accent)),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTypography.bodyXs,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Section card wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Adherence calendar ───────────────────────────────────────────────────────

class _AdherenceCalendar extends StatelessWidget {
  final List<_DayStatus> cells;

  const _AdherenceCalendar({required this.cells});

  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  Color _cellColor(_DayStatus s, BuildContext context) => switch (s) {
    _DayStatus.perfect => AppColors.teal,
    _DayStatus.good    => AppColors.teal.withValues(alpha: 0.35),
    _DayStatus.partial => AppColors.amber,
    _DayStatus.missed  => AppColors.red,
    _DayStatus.noData  => context.borderCol,
    _DayStatus.future  => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legend
        Row(
          children: [
            _LegendDot(color: AppColors.teal, label: AppStrings.perfectLabel),
            const SizedBox(width: 12),
            _LegendDot(
                color: AppColors.teal.withValues(alpha: 0.35),
                label: AppStrings.goodLabel),
            const SizedBox(width: 12),
            _LegendDot(color: AppColors.amber, label: AppStrings.partialLabel),
            const SizedBox(width: 12),
            _LegendDot(color: AppColors.red, label: AppStrings.missPatternToday.split(' ').first),
          ],
        ),
        const SizedBox(height: 12),

        // Day headers
        Row(
          children: _days
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: AppTypography.bodyXs
                              .copyWith(color: AppColors.textHint)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
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
                borderRadius: AppBorderRadius.xsAll,
                border: (isFuture || isBlank)
                    ? null
                    : Border.all(color: Colors.black12, width: 0.5),
              ),
            );
          },
        ),
      ],
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
        Text(label,
            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
            maxLines: 1),
      ],
    );
  }
}

// ─── Medicine bar ─────────────────────────────────────────────────────────────

class _MedBar extends StatelessWidget {
  final _MedStat med;
  const _MedBar({required this.med});

  Color get _color => med.rate >= 0.8
      ? AppColors.teal
      : med.rate >= 0.5
          ? AppColors.amber
          : AppColors.red;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                med.name,
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${med.taken} / ${med.scheduled}',
              style: AppTypography.bodyXs.copyWith(color: _color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: AppBorderRadius.pill,
          child: LinearProgressIndicator(
            value: med.rate,
            backgroundColor: _color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Slot miss bar ────────────────────────────────────────────────────────────

class _SlotBar extends StatelessWidget {
  final _SlotStat slot;
  const _SlotBar({required this.slot});

  Color get _color =>
      slot.missRate >= 0.4 ? AppColors.red : AppColors.amber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              slot.label,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${(slot.missRate * 100).round()}% missed',
              style: AppTypography.bodyXs.copyWith(color: _color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: AppBorderRadius.pill,
          child: LinearProgressIndicator(
            value: slot.missRate,
            backgroundColor: context.borderCol,
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
