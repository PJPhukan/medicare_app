import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../presentation/providers/vitals_provider.dart';
import '../../data/models/vital_config_model.dart' as vm;
import '../../data/models/vital_reading_model.dart' as vrm;

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

// ─── Adapters ─────────────────────────────────────────────────────────────────

Color _hexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

IconData _iconForVital(String name) {
  final n = name.toLowerCase();
  if (n.contains('blood pressure') || n.contains(' bp')) return Icons.favorite_rounded;
  if (n.contains('heart')) return Icons.monitor_heart_rounded;
  if (n.contains('sugar') || n.contains('glucose')) return Icons.water_drop_rounded;
  if (n.contains('weight')) return Icons.scale_rounded;
  if (n.contains('spo2') || n.contains('oxygen') || n.contains('saturation')) return Icons.air_rounded;
  return Icons.monitor_heart_outlined;
}

_VitalInput _toVitalInput(vm.VitalInput i) => _VitalInput(
      id: i.id,
      label: i.label,
      unit: i.unit,
      color: _hexColor(i.color),
      normalMin: i.normalMin,
      normalMax: i.normalMax,
      warningMin: i.warningMin,
      warningMax: i.warningMax,
    );

_VitalConfig _toVitalConfig(vm.VitalConfig c) => _VitalConfig(
      id: c.id,
      name: c.name,
      graphType: c.graphType.toUpperCase() == 'BAR' ? _GraphType.bar : _GraphType.line,
      sortOrder: c.sortOrder,
      inputs: c.inputs.map(_toVitalInput).toList(),
      icon: _iconForVital(c.name),
    );

_VitalReading _toVitalReading(vrm.VitalReading r) => _VitalReading(
      id: r.id,
      vitalConfigId: r.vitalConfigId,
      measuredAt: r.measuredAtDate,
      notes: r.notes,
      values: r.values.map((v) => _ReadingValue(v.inputId, v.value)).toList(),
    );

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

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  String _activeConfigId = '';
  bool _is7d = true;

  @override
  void initState() {
    super.initState();
    ref.listenManual(vitalsProvider, (_, state) {
      if (!state.isLoading && state.configs.isNotEmpty && _activeConfigId.isEmpty && mounted) {
        setState(() => _activeConfigId = state.configs.first.id);
      }
    });
  }

  List<_VitalConfig> get _configs =>
      ref.watch(vitalsProvider).configs.map(_toVitalConfig).toList();

  Map<String, List<_VitalReading>> get _readingsByConfig {
    final map = <String, List<_VitalReading>>{};
    for (final r in ref.watch(vitalsProvider).readings) {
      (map[r.vitalConfigId] ??= []).add(_toVitalReading(r));
    }
    for (final v in map.values) {
      v.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    }
    return map;
  }

  _VitalConfig get _activeConfig {
    final configs = _configs;
    if (configs.isEmpty) {
      return _VitalConfig(id: '', name: '', graphType: _GraphType.line,
          sortOrder: 0, inputs: const [], icon: Icons.monitor_heart_outlined);
    }
    return configs.firstWhere((c) => c.id == _activeConfigId,
        orElse: () => configs.first);
  }

  List<_VitalReading> get _activeReadings {
    final all = _readingsByConfig[_activeConfigId] ?? [];
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
        onSaved: (reading) => ref.read(vitalsProvider.notifier).addReading(
          vitalConfigId: _activeConfigId,
          values: reading.values
              .map((v) => <String, dynamic>{'inputId': v.inputId, 'value': v.value})
              .toList(),
          notes: reading.notes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;
    final isLoading = ref.watch(vitalsProvider).isLoading;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(vitalsProvider.notifier).load(),
        child: CustomScrollView(
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
            title: const Text(AppStrings.myVitals,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: AppStrings.logReading,
                onPressed: _openLog,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Loading skeleton ──────────────────────────────────────────────
          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppSkeleton(
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: isDark ? context.cardBg : Colors.white,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                      ),
                    ),
                  ),
                  childCount: 3,
                ),
              ),
            ),

          // ── Vital type tabs ───────────────────────────────────────────────
          if (!isLoading)
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
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0,
                              color: active ? AppColors.textInverse : AppColors.textSecondary,
                            )),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          if (!isLoading) ...[
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
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLog,
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.logReading,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse)),
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
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0,
                  color: active ? AppColors.textInverse : AppColors.textSecondary,
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
                  AppText.bodyXs(input.label, color: status.color),
                  const SizedBox(height: 2),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(
                      rv.value.toStringAsFixed(input.unit == '%' || input.unit == 'bpm' ? 0 : 1),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: status.color, height: 1),
                    ),
                    const SizedBox(width: 4),
                    AppText.bodySm(input.unit, color: status.color.withValues(alpha: 0.7)),
                  ]),
                  const SizedBox(height: 2),
                  Text(status.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: status.color, letterSpacing: 0.3)),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              if (latest != null)
                AppText.bodySm('Last: ${_fmtDateTime(latest.measuredAt)}'),
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
                AppText.bodySm(AppStrings.noReadingsInRange),
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
              AppText.bodyXs('${inp.label} (${inp.unit})'),
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
                  style: TextStyle(fontSize: 9, color: labelColor),
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
                        style: TextStyle(fontSize: 9, color: labelColor)),
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
                  TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: inp.color, letterSpacing: 0),
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
                  style: TextStyle(fontSize: 9, color: labelColor),
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
                        style: TextStyle(fontSize: 9, color: labelColor)),
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
                TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: inp.color, letterSpacing: 0),
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
        Text(AppStrings.recentReadings, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        if (readings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timeline_rounded, size: 28, color: AppColors.textHint),
                const SizedBox(height: 8),
                AppText.bodySm(AppStrings.noReadingsYet),
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
                        return AppText.labelMd(
                          '${rv.value.toStringAsFixed(inp.unit == '%' || inp.unit == 'bpm' ? 0 : 1)} ${inp.unit}',
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 2),
                    AppText.bodyXs(_fmtDateTime(reading.measuredAt)),
                    if (reading.notes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(reading.notes!,
                            style: const TextStyle(
                              fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textHint,
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
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: worstColor, letterSpacing: 0.3)),
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
  final Future<void> Function(_VitalReading) onSaved;
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

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

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

    try {
      await widget.onSaved(reading);
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.success(context, 'Reading logged');
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
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

          Text('Log ${widget.config.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                    Text('${inp.label} ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                    AppText.bodySm('(${inp.unit})'),
                    const Spacer(),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.12),
                          borderRadius: AppBorderRadius.pill,
                        ),
                        child: Text(status.label,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: status.color, letterSpacing: 0.3)),
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
                      style: TextStyle(fontSize: 14, color: context.primaryText),
                      decoration: InputDecoration(
                        hintText: '${inp.normalMin}–${inp.normalMax}',
                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setLocal(() {}),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AppText.bodyXs('${AppStrings.normalRange}: ${inp.normalMin}–${inp.normalMax} ${inp.unit}'),
                ]),
              ),
            );
          }),

          // Notes
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppStrings.notes, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
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
                style: TextStyle(fontSize: 14, color: context.primaryText),
                decoration: InputDecoration(
                  hintText: '${AppStrings.optional}…',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                child: const Text(AppStrings.cancel,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
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
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse)),
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
