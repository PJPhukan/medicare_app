import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

enum _GraphType { line, bar }

class _VitalInput {
  final String id, label, unit;
  final Color color;
  final double normalMin, normalMax, warningMin, warningMax;

  const _VitalInput({
    required this.id,
    required this.label,
    required this.unit,
    required this.color,
    required this.normalMin,
    required this.normalMax,
    required this.warningMin,
    required this.warningMax,
  });
}

class _VitalConfig {
  final String id, name;
  final _GraphType graphType;
  final int sortOrder;
  final List<_VitalInput> inputs;
  final IconData icon;

  const _VitalConfig({
    required this.id,
    required this.name,
    required this.graphType,
    required this.sortOrder,
    required this.inputs,
    required this.icon,
  });
}

class _ReadingValue {
  final String inputId;
  final double value;
  const _ReadingValue(this.inputId, this.value);
}

class _VitalReading {
  final String id, vitalConfigId;
  final DateTime measuredAt;
  final String? notes;
  final List<_ReadingValue> values;

  const _VitalReading({
    required this.id,
    required this.vitalConfigId,
    required this.measuredAt,
    this.notes,
    required this.values,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _configs = <_VitalConfig>[
  _VitalConfig(
    id: 'bp',
    name: 'Blood Pressure',
    graphType: _GraphType.line,
    sortOrder: 0,
    icon: Icons.favorite_rounded,
    inputs: const [
      _VitalInput(id: 'sys', label: 'Systolic', unit: 'mmHg', color: AppColors.teal,
          normalMin: 90, normalMax: 120, warningMin: 80, warningMax: 140),
      _VitalInput(id: 'dia', label: 'Diastolic', unit: 'mmHg', color: AppColors.blue,
          normalMin: 60, normalMax: 80, warningMin: 50, warningMax: 90),
    ],
  ),
  _VitalConfig(
    id: 'hr',
    name: 'Heart Rate',
    graphType: _GraphType.line,
    sortOrder: 1,
    icon: Icons.monitor_heart_rounded,
    inputs: const [
      _VitalInput(id: 'bpm', label: 'BPM', unit: 'bpm', color: AppColors.red,
          normalMin: 60, normalMax: 100, warningMin: 50, warningMax: 120),
    ],
  ),
  _VitalConfig(
    id: 'bg',
    name: 'Blood Sugar',
    graphType: _GraphType.bar,
    sortOrder: 2,
    icon: Icons.water_drop_rounded,
    inputs: const [
      _VitalInput(id: 'glucose', label: 'Glucose', unit: 'mg/dL', color: AppColors.amber,
          normalMin: 70, normalMax: 140, warningMin: 54, warningMax: 180),
    ],
  ),
  _VitalConfig(
    id: 'wt',
    name: 'Weight',
    graphType: _GraphType.bar,
    sortOrder: 3,
    icon: Icons.scale_rounded,
    inputs: const [
      _VitalInput(id: 'kg', label: 'Weight', unit: 'kg', color: AppColors.purple,
          normalMin: 50, normalMax: 90, warningMin: 40, warningMax: 110),
    ],
  ),
  _VitalConfig(
    id: 'spo2',
    name: 'SpO₂',
    graphType: _GraphType.line,
    sortOrder: 4,
    icon: Icons.air_rounded,
    inputs: const [
      _VitalInput(id: 'pct', label: 'Oxygen', unit: '%', color: AppColors.blue,
          normalMin: 95, normalMax: 100, warningMin: 90, warningMax: 100),
    ],
  ),
];

List<_VitalReading> _generateReadings(String configId, List<_VitalInput> inputs, int days) {
  final rng = math.Random(configId.hashCode);
  final now = DateTime.now();
  final readings = <_VitalReading>[];

  final baseValues = <String, double>{
    'sys': 118, 'dia': 76, 'bpm': 72, 'glucose': 105,
    'kg': 72.4, 'pct': 97.5,
  };

  for (int i = days; i >= 0; i--) {
    if (rng.nextDouble() < 0.25) continue; // skip some days
    final date = now.subtract(Duration(days: i, hours: rng.nextInt(12)));
    final values = inputs.map((inp) {
      final base = baseValues[inp.id] ?? ((inp.normalMin + inp.normalMax) / 2);
      final jitter = (rng.nextDouble() - 0.5) * (inp.normalMax - inp.normalMin) * 0.3;
      return _ReadingValue(inp.id, (base + jitter).clamp(inp.warningMin, inp.warningMax));
    }).toList();
    readings.add(_VitalReading(
      id: '$configId-$i',
      vitalConfigId: configId,
      measuredAt: date,
      notes: rng.nextDouble() < 0.15 ? 'After morning exercise' : null,
      values: values,
    ));
  }
  return readings..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
}

final _allReadings = {
  for (final c in _configs) c.id: _generateReadings(c.id, c.inputs, 30),
};

// ─── Status helper ────────────────────────────────────────────────────────────

({Color color, String label}) _valueStatus(double value, _VitalInput input) {
  if (value < input.warningMin || value > input.warningMax) {
    return (color: AppColors.error, label: AppStrings.highRisk);
  }
  if (value < input.normalMin || value > input.normalMax) {
    return (color: AppColors.warning, label: AppStrings.warningStatus);
  }
  return (color: AppColors.success, label: AppStrings.normal);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  String _activeConfigId = _configs.first.id;
  bool _is7d = true;

  _VitalConfig get _activeConfig =>
      _configs.firstWhere((c) => c.id == _activeConfigId);

  List<_VitalReading> get _activeReadings {
    final all = _allReadings[_activeConfigId] ?? [];
    final cutoff = DateTime.now().subtract(Duration(days: _is7d ? 7 : 30));
    return all.where((r) => r.measuredAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  void _openLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogReadingSheet(
        config: _activeConfig,
        onSaved: (reading) {
          setState(() {
            _allReadings[_activeConfigId]!.insert(0, reading);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, size: 22),
              onPressed: openAppSidebar,
              tooltip: 'Menu',
            ),
            title: Text(AppStrings.myVitals,
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: AppStrings.logReading,
                onPressed: _openLog,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Vital type tabs ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _configs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cfg = _configs[i];
                  final active = cfg.id == _activeConfigId;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeConfigId = cfg.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.teal : Colors.transparent,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: active
                              ? AppColors.teal
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(cfg.icon, size: 14,
                            color: active ? AppColors.textInverse : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(cfg.name,
                            style: AppTypography.labelSm.copyWith(
                              color: active ? AppColors.textInverse : AppColors.textSecondary,
                              letterSpacing: 0,
                            )),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Range toggle ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RangeToggle(is7d: _is7d, onChanged: (v) => setState(() => _is7d = v)),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Latest reading summary ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _activeReadings.isEmpty
                ? const SizedBox.shrink()
                : _LatestReadingRow(
                    reading: _activeReadings.first,
                    config: _activeConfig,
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Graph card ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _GraphCard(
                config: _activeConfig,
                readings: _activeReadings,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Recent readings ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RecentReadingsCard(
                config: _activeConfig,
                readings: _activeReadings,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLog,
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.logReading,
            style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
      ),
    );
  }
}

// ─── Range toggle ─────────────────────────────────────────────────────────────

class _RangeToggle extends StatelessWidget {
  final bool is7d;
  final ValueChanged<bool> onChanged;
  const _RangeToggle({required this.is7d, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.inputBg : AppColors.light200;

    return Container(
      height: 36,
      decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.pill),
      padding: const EdgeInsets.all(3),
      child: Row(children: [
        _RangeBtn(label: AppStrings.last7Days, active: is7d, onTap: () => onChanged(true)),
        _RangeBtn(label: AppStrings.last30Days, active: !is7d, onTap: () => onChanged(false)),
      ]),
    );
  }
}

class _RangeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RangeBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.transparent,
            borderRadius: AppBorderRadius.pill,
          ),
          child: Center(
            child: Text(label,
                style: AppTypography.labelSm.copyWith(
                  color: active ? AppColors.textInverse : AppColors.textSecondary,
                  letterSpacing: 0,
                  fontSize: 12,
                )),
          ),
        ),
      ),
    );
  }
}

// ─── Latest reading row ───────────────────────────────────────────────────────

class _LatestReadingRow extends StatelessWidget {
  final _VitalReading reading;
  final _VitalConfig config;
  const _LatestReadingRow({required this.reading, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: reading.values.map((rv) {
            final input = config.inputs.firstWhere((i) => i.id == rv.inputId);
            final status = _valueStatus(rv.value, input);
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(color: status.color.withValues(alpha: 0.25)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(input.label, style: AppTypography.bodyXs.copyWith(color: status.color)),
                  const SizedBox(height: 2),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(
                      rv.value.toStringAsFixed(input.unit == '%' || input.unit == 'bpm' ? 0 : 1),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28, fontWeight: FontWeight.w800, color: status.color, height: 1),
                    ),
                    const SizedBox(width: 4),
                    Text(input.unit, style: AppTypography.bodySm.copyWith(color: status.color.withValues(alpha: 0.7))),
                  ]),
                  const SizedBox(height: 2),
                  Text(status.label,
                      style: AppTypography.labelXs.copyWith(color: status.color, letterSpacing: 0.3)),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Graph card ───────────────────────────────────────────────────────────────

class _GraphCard extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  const _GraphCard({required this.config, required this.readings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    final hasData = readings.isNotEmpty;
    final latest = readings.isNotEmpty ? readings.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${config.name} ${AppStrings.trends}',
                  style: AppTypography.h3.copyWith(fontSize: 15)),
              if (latest != null)
                Text(
                  'Last: ${_fmtDateTime(latest.measuredAt)}',
                  style: AppTypography.bodySm,
                ),
            ]),
          ),
        ]),

        const SizedBox(height: 16),

        // Chart
        if (!hasData)
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: border, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.show_chart_rounded, size: 28, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text(AppStrings.noReadingsInRange, style: AppTypography.bodySm),
              ]),
            ),
          )
        else if (config.graphType == _GraphType.line)
          _LineGraph(config: config, readings: readings)
        else
          _BarGraph(config: config, readings: readings),

        // Legend for multi-input
        if (config.inputs.length > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16, runSpacing: 6,
            children: config.inputs.map((inp) => Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 20, height: 2, color: inp.color),
              const SizedBox(width: 6),
              Text('${inp.label} (${inp.unit})', style: AppTypography.bodyXs),
            ])).toList(),
          ),
        ],
      ]),
    );
  }
}

// ─── Line graph ───────────────────────────────────────────────────────────────

class _LineGraph extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  const _LineGraph({required this.config, required this.readings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = (isDark ? context.borderCol : AppColors.light300).withValues(alpha: 0.5);
    final labelColor = AppColors.textHint;

    // Sort readings oldest→newest for chart
    final sorted = [...readings]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final lineBars = config.inputs.asMap().entries.map((entry) {
      final inp = entry.value;
      final spots = sorted.asMap().entries.map((e) {
        final rv = e.value.values.firstWhere(
          (v) => v.inputId == inp.id,
          orElse: () => _ReadingValue(inp.id, 0),
        );
        return FlSpot(e.key.toDouble(), rv.value);
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: inp.color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: sorted.length <= 15,
          getDotPainter: (spot, _, __, ___) {
            final rv = sorted[spot.x.toInt()].values
                .firstWhere((v) => v.inputId == inp.id, orElse: () => _ReadingValue(inp.id, 0));
            final status = _valueStatus(rv.value, inp);
            return FlDotCirclePainter(
              radius: 3.5,
              color: status.color,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: inp.color.withValues(alpha: 0.06),
        ),
      );
    }).toList();

    // X-axis date labels — show evenly spaced
    final step = (sorted.length / 5).ceil().clamp(1, 99);
    final dateLabels = <int, String>{};
    for (int i = 0; i < sorted.length; i += step) {
      dateLabels[i] = _fmtDate(sorted[i].measuredAt);
    }
    if (sorted.isNotEmpty) dateLabels[sorted.length - 1] = _fmtDate(sorted.last.measuredAt);

    // Y range
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final inp in config.inputs) {
      minY = math.min(minY, inp.warningMin.toDouble());
      maxY = math.max(maxY, inp.warningMax.toDouble());
    }
    final yPad = (maxY - minY) * 0.1;

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (sorted.length - 1).toDouble().clamp(1, double.infinity),
          minY: minY - yPad,
          maxY: maxY + yPad,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: AppTypography.bodyXs.copyWith(color: labelColor, fontSize: 9),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  final label = dateLabels[idx];
                  if (label == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label,
                        style: AppTypography.bodyXs.copyWith(color: labelColor, fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: lineBars,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark ? context.inputBg : AppColors.light200,
              getTooltipItems: (spots) => spots.map((spot) {
                final inp = config.inputs[spot.barIndex];
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} ${inp.unit}',
                  AppTypography.labelSm.copyWith(color: inp.color, letterSpacing: 0),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bar graph ────────────────────────────────────────────────────────────────

class _BarGraph extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  const _BarGraph({required this.config, required this.readings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = (isDark ? context.borderCol : AppColors.light300).withValues(alpha: 0.5);
    final labelColor = AppColors.textHint;
    final inp = config.inputs.first;

    final sorted = [...readings]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final groups = sorted.asMap().entries.map((e) {
      final rv = e.value.values.firstWhere(
        (v) => v.inputId == inp.id,
        orElse: () => _ReadingValue(inp.id, 0),
      );
      final status = _valueStatus(rv.value, inp);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: rv.value,
            color: status.color,
            width: math.max(4, 240 / sorted.length.clamp(1, 60)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: inp.warningMax,
              color: inp.color.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    }).toList();

    final step = (sorted.length / 5).ceil().clamp(1, 99);
    final dateLabels = <int, String>{};
    for (int i = 0; i < sorted.length; i += step) {
      dateLabels[i] = _fmtDate(sorted[i].measuredAt);
    }
    if (sorted.isNotEmpty) dateLabels[sorted.length - 1] = _fmtDate(sorted.last.measuredAt);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          minY: inp.warningMin * 0.9,
          maxY: inp.warningMax * 1.05,
          barGroups: groups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: AppTypography.bodyXs.copyWith(color: labelColor, fontSize: 9),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  final label = dateLabels[idx];
                  if (label == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label,
                        style: AppTypography.bodyXs.copyWith(color: labelColor, fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDark ? context.inputBg : AppColors.light200,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} ${inp.unit}',
                AppTypography.labelSm.copyWith(color: inp.color, letterSpacing: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recent readings card ─────────────────────────────────────────────────────

class _RecentReadingsCard extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  const _RecentReadingsCard({required this.config, required this.readings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;
    final divider = border.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppStrings.recentReadings, style: AppTypography.h3.copyWith(fontSize: 15)),
        const SizedBox(height: 12),

        if (readings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timeline_rounded, size: 28, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text(AppStrings.noReadingsYet, style: AppTypography.bodySm),
              ]),
            ),
          )
        else
          ...readings.take(10).map((reading) {
            // Worst status across all values
            Color worstColor = AppColors.success;
            String worstLabel = AppStrings.normal;
            for (final rv in reading.values) {
              final inp = config.inputs.firstWhere((i) => i.id == rv.inputId);
              final st = _valueStatus(rv.value, inp);
              if (st.label == AppStrings.highRisk) {
                worstColor = AppColors.error;
                worstLabel = st.label;
                break;
              }
              if (st.label == AppStrings.warningStatus) {
                worstColor = AppColors.warning;
                worstLabel = st.label;
              }
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: divider, width: 0.5)),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(
                      spacing: 10,
                      children: reading.values.map((rv) {
                        final inp = config.inputs.firstWhere((i) => i.id == rv.inputId);
                        return Text(
                          '${rv.value.toStringAsFixed(inp.unit == '%' || inp.unit == 'bpm' ? 0 : 1)} ${inp.unit}',
                          style: AppTypography.labelMd,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 2),
                    Text(_fmtDateTime(reading.measuredAt), style: AppTypography.bodyXs),
                    if (reading.notes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(reading.notes!,
                            style: AppTypography.bodyXs.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textHint,
                            )),
                      ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: worstColor.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.pill,
                  ),
                  child: Text(worstLabel,
                      style: AppTypography.labelXs.copyWith(color: worstColor, letterSpacing: 0.3)),
                ),
              ]),
            );
          }),
      ]),
    );
  }
}

// ─── Log Reading sheet ────────────────────────────────────────────────────────

class _LogReadingSheet extends StatefulWidget {
  final _VitalConfig config;
  final ValueChanged<_VitalReading> onSaved;
  const _LogReadingSheet({required this.config, required this.onSaved});

  @override
  State<_LogReadingSheet> createState() => _LogReadingSheetState();
}

class _LogReadingSheetState extends State<_LogReadingSheet> {
  late final Map<String, TextEditingController> _ctrls;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrls = {
      for (final inp in widget.config.inputs) inp.id: TextEditingController()
    };
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) { c.dispose(); }
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => widget.config.inputs.every((inp) {
    final v = _ctrls[inp.id]?.text ?? '';
    return v.isNotEmpty && double.tryParse(v) != null;
  });

  void _save() {
    if (!_canSave) return;
    setState(() => _saving = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final values = widget.config.inputs.map((inp) {
        return _ReadingValue(inp.id, double.parse(_ctrls[inp.id]!.text));
      }).toList();

      final reading = _VitalReading(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        vitalConfigId: widget.config.id,
        measuredAt: DateTime.now(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        values: values,
      );
      widget.onSaved(reading);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Reading logged'),
        backgroundColor: context.inputBg,
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.topXxl),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: border, borderRadius: AppBorderRadius.pill)),
          ),
          const SizedBox(height: 20),

          Text('Log ${widget.config.name}', style: AppTypography.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 20),

          // Input fields
          ...widget.config.inputs.map((inp) {
            final status = _ctrls[inp.id]!.text.isNotEmpty
                ? _valueStatus(double.tryParse(_ctrls[inp.id]!.text) ?? inp.normalMin, inp)
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: StatefulBuilder(
                builder: (_, setLocal) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('${inp.label} ', style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
                    Text('(${inp.unit})', style: AppTypography.bodySm),
                    const Spacer(),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.12),
                          borderRadius: AppBorderRadius.pill,
                        ),
                        child: Text(status.label,
                            style: AppTypography.labelXs.copyWith(color: status.color, letterSpacing: 0.3)),
                      ),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? context.inputBg : AppColors.light100,
                      borderRadius: AppBorderRadius.mdAll,
                      border: Border.all(
                        color: status != null && status.label != AppStrings.normal
                            ? status.color.withValues(alpha: 0.4)
                            : border,
                      ),
                    ),
                    child: TextField(
                      controller: _ctrls[inp.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: '${inp.normalMin}–${inp.normalMax}',
                        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setLocal(() {}),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('${AppStrings.normalRange}: ${inp.normalMin}–${inp.normalMax} ${inp.unit}',
                      style: AppTypography.bodyXs),
                ]),
              ),
            );
          }),

          // Notes
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppStrings.notes, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? context.inputBg : AppColors.light100,
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: AppTypography.bodyMd,
                decoration: InputDecoration(
                  hintText: '${AppStrings.optional}…',
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Buttons
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: border),
                ),
                child: Text(AppStrings.cancel,
                    style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ListenableBuilder(
                listenable: Listenable.merge(_ctrls.values.toList()),
                builder: (_, __) => FilledButton(
                  onPressed: (_canSave && !_saving) ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_saving ? AppStrings.saving : AppStrings.save,
                      style: AppTypography.buttonLg.copyWith(color: AppColors.textInverse)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─── Date helpers ─────────────────────────────────────────────────────────────

String _fmtDate(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[dt.month - 1]} ${dt.day}';
}

String _fmtDateTime(DateTime dt) {
  final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${_fmtDate(dt)}, $h:$m $ampm';
}
