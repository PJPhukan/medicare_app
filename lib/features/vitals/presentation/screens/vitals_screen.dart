import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/chips/status_chip.dart';
import '../../../../shared/widgets/graphs/donut_chart.dart';
import '../../../../shared/widgets/graphs/app_chart_series.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../presentation/providers/vitals_provider.dart';
import '../../../shell/presentation/providers/tabs_provider.dart';
import '../../data/models/vital_config_model.dart' as vm;
import '../../data/models/vital_reading_model.dart' as vrm;

// ─── Data models ──────────────────────────────────────────────────────────────

enum _GraphType { line, bar, area, donut, pie }

_GraphType _parseGraphType(String s) {
  switch (s.toUpperCase()) {
    case 'BAR':
      return _GraphType.bar;
    case 'AREA':
      return _GraphType.area;
    case 'DONUT':
      return _GraphType.donut;
    case 'PIE':
      return _GraphType.pie;
    case 'LINE':
      return _GraphType.line;
    default:
      return _GraphType.line;
  }
}

enum _Range { today, week, month }

extension _RangeX on _Range {
  String get label => switch (this) {
        _Range.today => AppStrings.rangeToday,
        _Range.week => AppStrings.range7Days,
        _Range.month => AppStrings.range30Days,
      };
  int get days => switch (this) {
        _Range.today => 1,
        _Range.week => 7,
        _Range.month => 30,
      };
}

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

  /// Worst server-raised, unacknowledged alert severity for this reading
  /// (`CRITICAL` > `HIGH` > `LOW`), or null when the backend flagged nothing.
  final String? alertSeverity;

  const _VitalReading({
    required this.id,
    required this.vitalConfigId,
    required this.measuredAt,
    this.notes,
    required this.values,
    this.alertSeverity,
  });
}

// ─── Adapters ─────────────────────────────────────────────────────────────────

Color _hexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

IconData _iconForVital(String name) {
  final n = name.toLowerCase();
  if (n.contains('blood pressure') || n.contains(' bp'))
    return Icons.favorite_rounded;
  if (n.contains('heart')) return Icons.monitor_heart_rounded;
  if (n.contains('sugar') || n.contains('glucose'))
    return Icons.water_drop_rounded;
  if (n.contains('weight')) return Icons.scale_rounded;
  if (n.contains('spo2') || n.contains('oxygen') || n.contains('saturation'))
    return Icons.air_rounded;
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
      graphType: _parseGraphType(c.graphType),
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
      alertSeverity: _worstSeverity(r.activeAlerts),
    );

/// Reduce a reading's server alerts to its most severe level.
String? _worstSeverity(List<dynamic> alerts) {
  const rank = {'CRITICAL': 3, 'HIGH': 2, 'LOW': 1};
  String? worst;
  var best = 0;
  for (final a in alerts) {
    final sev = a.severity as String;
    final r = rank[sev] ?? 0;
    if (r > best) {
      best = r;
      worst = sev;
    }
  }
  return worst;
}

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

/// Display style for a server-raised alert severity, or null when none.
({Color color, String label, IconData icon})? _severityStyle(String? severity) {
  switch (severity) {
    case 'CRITICAL':
      return (
        color: AppColors.error,
        label: AppStrings.severityCritical,
        icon: Icons.crisis_alert_rounded
      );
    case 'HIGH':
      return (
        color: AppColors.warning,
        label: AppStrings.severityHigh,
        icon: Icons.trending_up_rounded
      );
    case 'LOW':
      return (
        color: AppColors.warning,
        label: AppStrings.severityLow,
        icon: Icons.trending_down_rounded
      );
    default:
      return null;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  String _activeConfigId = '';
  _Range _range = _Range.week;

  @override
  void initState() {
    super.initState();
    ref.listenManual(vitalsProvider, (_, state) {
      if (!state.isLoading &&
          state.configs.isNotEmpty &&
          _activeConfigId.isEmpty &&
          mounted) {
        setState(() => _activeConfigId = state.configs.first.id);
      }
    });
  }

  List<_VitalConfig> get _configs =>
      ref.watch(vitalsProvider).configs.map(_toVitalConfig).toList();

  /// The selected tab, defensively resolved: falls back to the first config
  /// when nothing is selected yet or the selection no longer exists (e.g.
  /// after the admin-managed config list changes, or on screen remount).
  String get _effectiveConfigId {
    final configs = _configs;
    if (configs.isEmpty) return '';
    if (configs.any((c) => c.id == _activeConfigId)) return _activeConfigId;
    return configs.first.id;
  }

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
      return _VitalConfig(
          id: '',
          name: '',
          graphType: _GraphType.line,
          sortOrder: 0,
          inputs: const [],
          icon: Icons.monitor_heart_outlined);
    }
    final id = _effectiveConfigId;
    return configs.firstWhere((c) => c.id == id, orElse: () => configs.first);
  }

  List<_VitalReading> get _activeReadings {
    final all = _readingsByConfig[_effectiveConfigId] ?? [];
    final now = DateTime.now();
    // "Today" = since the start of today; week/month = a rolling window.
    final cutoff = _range == _Range.today
        ? DateTime(now.year, now.month, now.day)
        : now.subtract(Duration(days: _range.days));
    return all.where((r) => r.measuredAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  void _openLog() {
    final config = _activeConfig;
    // Logging requires a config tab with at least one input (admin-defined).
    if (config.id.isEmpty || config.inputs.isEmpty) {
      AppSnackbar.info(context, AppStrings.noVitalsConfigured);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogReadingSheet(
        config: config,
        onSaved: (reading) => ref.read(vitalsProvider.notifier).addReading(
              vitalConfigId: config.id,
              values: reading.values
                  .map((v) =>
                      <String, dynamic>{'inputId': v.inputId, 'value': v.value})
                  .toList(),
              measuredAt: reading.measuredAt.toUtc().toIso8601String(),
              notes: reading.notes,
            ),
      ),
    );
  }

  void _openEdit(_VitalReading reading) {
    final config = _activeConfig;
    if (config.id.isEmpty || config.inputs.isEmpty) {
      AppSnackbar.info(context, AppStrings.noVitalsConfigured);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogReadingSheet(
        config: config,
        existing: reading,
        onSaved: (edited) => ref.read(vitalsProvider.notifier).updateReading(
              id: reading.id,
              values: edited.values
                  .map((v) =>
                      <String, dynamic>{'inputId': v.inputId, 'value': v.value})
                  .toList(),
              measuredAt: edited.measuredAt.toUtc().toIso8601String(),
              notes: edited.notes,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;
    final state = ref.watch(vitalsProvider);
    final isLoading = state.isLoading;
    final hasConfigs = _configs.isNotEmpty;
    // Empty / error states only matter once the first load has settled.
    final showError = !isLoading && !hasConfigs && state.error != null;
    final showEmpty = !isLoading && !hasConfigs && state.error == null;
    // TabConfig gate: only surface the log action if the admin granted "add" on
    // the vitals tab. Defaults to allowed while tabs load (see tabPermissionsProvider).
    final canAdd = ref.watch(tabPermissionsProvider('vitals')).add;
    final canEdit = ref.watch(tabPermissionsProvider('vitals')).edit;
    final canLog = canAdd &&
        _activeConfig.id.isNotEmpty &&
        _activeConfig.inputs.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(vitalsProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            AppSliverAppBar(
              floating: true,
              snap: true,
              config: AppBarConfig(
                title: AppStrings.myVitals,
                subtitle: AppStrings.vitalsSubtitle,
                actions: [
                  if (canLog)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _openLog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.teal, AppColors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppBorderRadius.pill,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(AppStrings.logReading,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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

            // ── Error state (fetch failed, no configs) ─────────────────────────
            if (showError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: state.isOffline
                    ? AppNoInternetState(
                        onRetry: () => ref.read(vitalsProvider.notifier).load(),
                      )
                    : AppErrorState(
                        message: state.error,
                        onRetry: () => ref.read(vitalsProvider.notifier).load(),
                      ),
              ),

            // ── Empty state (no vital types configured by admin) ───────────────
            if (showEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.monitor_heart_outlined,
                  title: AppStrings.noVitalsConfiguredTitle,
                  subtitle: AppStrings.noVitalsConfigured,
                ),
              ),

            // ── Offline banner (self-hides when back online) ───────────────────
            if (!isLoading && hasConfigs)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: OfflineBanner(),
                ),
              ),

            // ── Vital type tabs ───────────────────────────────────────────────
            if (!isLoading && hasConfigs)
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
                      final active = cfg.id == _effectiveConfigId;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeConfigId = cfg.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.teal : Colors.transparent,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: active
                                  ? AppColors.teal
                                  : context.secondaryText
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(cfg.icon,
                                size: 14,
                                color: active
                                    ? Colors.white
                                    : context.secondaryText),
                            const SizedBox(width: 6),
                            Text(cfg.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                  color: active
                                      ? Colors.white
                                      : context.secondaryText,
                                )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (!isLoading && hasConfigs) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Premium hero: latest reading ───────────────────────────────────
              SliverToBoxAdapter(
                child: _activeReadings.isEmpty
                    ? const SizedBox.shrink()
                    : _VitalHeroCard(
                        reading: _activeReadings.first,
                        config: _activeConfig,
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Graph card (range filter lives in its header) ──────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GraphCard(
                    config: _activeConfig,
                    readings: _activeReadings,
                    range: _range,
                    onRangeChanged: (r) => setState(() => _range = r),
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
                    onEdit: canEdit ? _openEdit : null,
                    onViewAll: _activeConfig.id.isNotEmpty
                        ? () => context.push(
                              AppRoutes.vitalHistory,
                              extra: VitalHistoryArgs(
                                configId: _activeConfig.id,
                                configName: _activeConfig.name,
                              ),
                            )
                        : null,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
      // Add-log now lives in the toolbar (gradient pill), so no FAB.
    );
  }
}

// ─── Range toggle ─────────────────────────────────────────────────────────────

// Compact range filter shown in the graph card header (right of the title).
class _RangeDropdown extends StatelessWidget {
  final _Range range;
  final ValueChanged<_Range> onChanged;
  const _RangeDropdown({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<_Range>(
      initialValue: range,
      tooltip: 'Range',
      color: isDark ? context.cardBg : Colors.white,
      elevation: 4,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      onSelected: (v) {
        HapticFeedback.selectionClick();
        onChanged(v);
      },
      itemBuilder: (_) => _Range.values.map((r) {
        final selected = r == range;
        return PopupMenuItem<_Range>(
          value: r,
          height: 42,
          child: Row(children: [
            Icon(selected ? Icons.check_rounded : Icons.calendar_today_rounded,
                size: 16,
                color: selected ? AppColors.teal : AppColors.textHint),
            const SizedBox(width: 10),
            Text(r.label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.teal : context.primaryText)),
          ]),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.10),
          borderRadius: AppBorderRadius.pill,
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_rounded,
              size: 13, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(range.label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                  letterSpacing: 0)),
          const SizedBox(width: 2),
          const Icon(Icons.expand_more_rounded,
              size: 16, color: AppColors.teal),
        ]),
      ),
    );
  }
}

// ─── Premium hero card (latest reading) ───────────────────────────────────────

class _VitalHeroCard extends StatelessWidget {
  final _VitalReading reading;
  final _VitalConfig config;
  const _VitalHeroCard({required this.reading, required this.config});

  @override
  Widget build(BuildContext context) {
    // Worst status across the reading's inputs drives the hero status pill.
    // Prefer the backend's server-raised alert (authoritative), else client bands.
    Color statusColor = AppColors.success;
    String statusLabel = AppStrings.normal;
    final serverAlert = _severityStyle(reading.alertSeverity);
    if (serverAlert != null) {
      statusColor = serverAlert.color;
      statusLabel = serverAlert.label;
    } else {
      for (final rv in reading.values) {
        final inp = config.inputs.firstWhere((i) => i.id == rv.inputId);
        final st = _valueStatus(rv.value, inp);
        if (st.color == AppColors.error) {
          statusColor = st.color;
          statusLabel = st.label;
          break;
        }
        if (st.color == AppColors.warning) {
          statusColor = st.color;
          statusLabel = st.label;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GradientCard(
        colors: const [AppColors.teal, AppColors.blue],
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppBorderRadius.lgAll,
                ),
                child: Icon(config.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(config.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Latest · ${_fmtDateTime(reading.measuredAt)}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ]),
              ),
              // Frosted status pill (premium on the gradient).
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppBorderRadius.pill,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(statusLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
            // Big values (e.g. systolic / diastolic). Scrollable to avoid overflow.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < reading.values.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('/',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 28,
                                fontWeight: FontWeight.w300)),
                      ),
                    _HeroValue(
                      value: reading.values[i],
                      input: config.inputs.firstWhere(
                        (inp) => inp.id == reading.values[i].inputId,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  final _ReadingValue value;
  final _VitalInput input;
  const _HeroValue({required this.value, required this.input});

  @override
  Widget build(BuildContext context) {
    final decimals = input.unit == '%' || input.unit == 'bpm' ? 0 : 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(input.label.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value.value.toStringAsFixed(decimals),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1)),
            const SizedBox(width: 4),
            Text(input.unit,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

// ─── Graph card ───────────────────────────────────────────────────────────────

class _GraphCard extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  final _Range range;
  final ValueChanged<_Range> onRangeChanged;
  const _GraphCard({
    required this.config,
    required this.readings,
    required this.range,
    required this.onRangeChanged,
  });

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
        // Header — title/subtitle on the left, range filter on the right.
        SectionHeader(
          title: '${config.name} ${AppStrings.trends}',
          subtitle: latest != null
              ? 'Last: ${_fmtDateTime(latest.measuredAt)}'
              : null,
          accentColor: config.inputs.isNotEmpty
              ? config.inputs.first.color
              : AppColors.teal,
          action: _RangeDropdown(range: range, onChanged: onRangeChanged),
        ),

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
                Icon(Icons.show_chart_rounded,
                    size: 28, color: AppColors.textHint),
                const SizedBox(height: 8),
                AppText.bodySm(AppStrings.noReadingsInRange),
              ]),
            ),
          )
        else
          switch (config.graphType) {
            _GraphType.bar =>
              _BarGraph(config: config, readings: readings, range: range),
            _GraphType.donut => _DistributionChart(
                config: config, readings: readings, isPie: false),
            _GraphType.pie => _DistributionChart(
                config: config, readings: readings, isPie: true),
            // line + area both use the line chart (area = line with its filled band).
            _ => _LineGraph(config: config, readings: readings, range: range),
          },

        // Legend for multi-input (line/bar/area only — donut/pie carry their own).
        if (config.inputs.length > 1 &&
            config.graphType != _GraphType.donut &&
            config.graphType != _GraphType.pie) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: config.inputs
                .map((inp) => Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 20, height: 2, color: inp.color),
                      const SizedBox(width: 6),
                      AppText.bodyXs('${inp.label} (${inp.unit})'),
                    ]))
                .toList(),
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
  final _Range range;
  const _LineGraph(
      {required this.config, required this.readings, required this.range});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = (isDark ? context.borderCol : AppColors.light300)
        .withValues(alpha: 0.5);
    final labelColor = AppColors.textHint;

    // Sort readings oldest→newest for chart
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

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
          // Dots use the input's configured color (status is surfaced in the
          // readings list + hero pill, so the chart shows the chosen color).
          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
            radius: 3.5,
            color: inp.color,
            strokeWidth: 1.5,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: inp.color.withValues(alpha: 0.06),
        ),
      );
    }).toList();

    // Range-aware, de-duplicated X-axis labels.
    final dateLabels = _buildAxisLabels(sorted, range);

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
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
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
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              getTooltipColor: (_) =>
                  isDark ? context.inputBg : AppColors.light200,
              getTooltipItems: (spots) => spots.map((spot) {
                final inp = config.inputs[spot.barIndex];
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} ${inp.unit}',
                  TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: inp.color,
                      letterSpacing: 0),
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
  final _Range range;
  const _BarGraph(
      {required this.config, required this.readings, required this.range});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = (isDark ? context.borderCol : AppColors.light300)
        .withValues(alpha: 0.5);
    final labelColor = AppColors.textHint;
    final inp = config.inputs.first;

    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final groups = sorted.asMap().entries.map((e) {
      final rv = e.value.values.firstWhere(
        (v) => v.inputId == inp.id,
        orElse: () => _ReadingValue(inp.id, 0),
      );
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: rv.value,
            color: inp.color,
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

    final dateLabels = _buildAxisLabels(sorted, range);

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
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
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
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              getTooltipColor: (_) =>
                  isDark ? context.inputBg : AppColors.light200,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} ${inp.unit}',
                TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: inp.color,
                    letterSpacing: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Distribution chart (donut / pie) ─────────────────────────────────────────

/// Worst status color for a reading — server alert first, else client bands.
Color _worstStatusColor(_VitalReading reading, _VitalConfig config) {
  final sev = _severityStyle(reading.alertSeverity);
  if (sev != null) return sev.color;
  Color c = AppColors.success;
  for (final rv in reading.values) {
    final inp = config.inputs.firstWhere((i) => i.id == rv.inputId);
    final st = _valueStatus(rv.value, inp);
    if (st.color == AppColors.error) return AppColors.error;
    if (st.color == AppColors.warning) c = AppColors.warning;
  }
  return c;
}

/// Donut/pie of the reading STATUS distribution (Normal / Warning / High-risk)
/// across the selected range — a natural fit for a proportional chart.
class _DistributionChart extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  final bool isPie;
  const _DistributionChart({
    required this.config,
    required this.readings,
    required this.isPie,
  });

  @override
  Widget build(BuildContext context) {
    var normal = 0, warning = 0, high = 0;
    for (final r in readings) {
      final c = _worstStatusColor(r, config);
      if (c == AppColors.error) {
        high++;
      } else if (c == AppColors.warning) {
        warning++;
      } else {
        normal++;
      }
    }

    final segments = <AppDonutSegment>[
      if (normal > 0)
        AppDonutSegment(
            label: AppStrings.normal,
            value: normal.toDouble(),
            color: AppColors.success),
      if (warning > 0)
        AppDonutSegment(
            label: AppStrings.warningStatus,
            value: warning.toDouble(),
            color: AppColors.warning),
      if (high > 0)
        AppDonutSegment(
            label: AppStrings.highRisk,
            value: high.toDouble(),
            color: AppColors.error),
    ];

    if (segments.isEmpty) return const SizedBox(height: 160);

    return Center(
      child: AppDonutChart(
        segments: segments,
        size: 180,
        holeRadius: isPie ? 0.0 : 0.55,
        centerValue: isPie ? null : '${readings.length}',
        centerLabel: isPie ? null : AppStrings.recentReadings,
        showLegend: true,
      ),
    );
  }
}

// ─── Recent readings card ─────────────────────────────────────────────────────

class _RecentReadingsCard extends StatelessWidget {
  final _VitalConfig config;
  final List<_VitalReading> readings;
  // When non-null, each row shows an edit button (gated on the tab's allowEdit).
  final void Function(_VitalReading)? onEdit;
  final VoidCallback? onViewAll;
  const _RecentReadingsCard({
    required this.config,
    required this.readings,
    this.onEdit,
    this.onViewAll,
  });

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
        SectionHeader(
          title: AppStrings.recentReadings,
          accentColor: AppColors.teal,
          action: onViewAll != null
              ? GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'View All →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        if (readings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timeline_rounded,
                    size: 28, color: AppColors.textHint),
                const SizedBox(height: 8),
                AppText.bodySm(AppStrings.noReadingsYet),
              ]),
            ),
          )
        else
          ...readings.take(10).map((reading) {
            // Prefer the backend's server-raised alert (authoritative — it's
            // what triggered notifications). Fall back to client-side bands.
            final serverAlert = _severityStyle(reading.alertSeverity);
            Color worstColor = AppColors.success;
            String worstLabel = AppStrings.normal;
            IconData? badgeIcon;
            if (serverAlert != null) {
              worstColor = serverAlert.color;
              worstLabel = serverAlert.label;
              badgeIcon = serverAlert.icon;
            } else {
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
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: divider, width: 0.5)),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          children: reading.values.map((rv) {
                            final inp = config.inputs
                                .firstWhere((i) => i.id == rv.inputId);
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
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textHint,
                                )),
                          ),
                      ]),
                ),
                AppStatusChip(
                  label: worstLabel,
                  color: worstColor,
                  icon: badgeIcon,
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: context.secondaryText),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.only(left: 6),
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit',
                    onPressed: () => onEdit!(reading),
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
  // When non-null, the sheet is in EDIT mode (pre-filled, saves an update).
  final _VitalReading? existing;
  const _LogReadingSheet({
    required this.config,
    required this.onSaved,
    this.existing,
  });

  @override
  State<_LogReadingSheet> createState() => _LogReadingSheetState();
}

class _LogReadingSheetState extends State<_LogReadingSheet> {
  late final Map<String, TextEditingController> _ctrls;
  final _notesCtrl = TextEditingController();
  DateTime _measuredAt = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _ctrls = {
      for (final inp in widget.config.inputs) inp.id: TextEditingController()
    };
    // Pre-fill when editing an existing reading.
    final ex = widget.existing;
    if (ex != null) {
      for (final v in ex.values) {
        final isWhole = v.value % 1 == 0;
        _ctrls[v.inputId]?.text =
            isWhole ? v.value.toInt().toString() : v.value.toString();
      }
      _notesCtrl.text = ex.notes ?? '';
      _measuredAt = ex.measuredAt;
    }
  }

  Future<void> _pickMeasuredAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_measuredAt),
    );
    if (!mounted) return;
    var picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? _measuredAt.hour,
      time?.minute ?? _measuredAt.minute,
    );
    // Never allow a future timestamp.
    if (picked.isAfter(now)) picked = now;
    setState(() => _measuredAt = picked);
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
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
      measuredAt: _measuredAt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      values: values,
    );

    try {
      await widget.onSaved(reading);
      if (!mounted) return;
      context.pop();
      AppSnackbar.success(
          context, _isEdit ? 'Reading updated' : 'Reading logged');
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration:
            BoxDecoration(color: bg, borderRadius: AppBorderRadius.topXxl),
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: border, borderRadius: AppBorderRadius.pill)),
              ),
              const SizedBox(height: 20),

              Text('${_isEdit ? 'Edit' : 'Log'} ${widget.config.name}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText)),
              const SizedBox(height: 16),

              // Measured-at picker (schema: measuredAt)
              Text(AppStrings.measuredAt,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: context.secondaryText)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _saving ? null : _pickMeasuredAt,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isDark ? context.inputBg : AppColors.light100,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.event_rounded,
                        size: 16, color: AppColors.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_fmtDateTime(_measuredAt),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.primaryText)),
                    ),
                    Icon(Icons.expand_more_rounded,
                        size: 18, color: context.secondaryText),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Input fields — one per config input (schema-driven)
              ...widget.config.inputs.map((inp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: StatefulBuilder(
                    builder: (_, setLocal) {
                      final raw = _ctrls[inp.id]!.text;
                      final status = raw.isNotEmpty
                          ? _valueStatus(
                              double.tryParse(raw) ?? inp.normalMin, inp)
                          : null;
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(inp.label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                      color: context.secondaryText)),
                              const Spacer(),
                              if (status != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: status.color.withValues(alpha: 0.12),
                                    borderRadius: AppBorderRadius.pill,
                                  ),
                                  child: Text(status.label,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: status.color,
                                          letterSpacing: 0.3)),
                                ),
                            ]),
                            const SizedBox(height: 6),
                            AppTextField(
                              controller: _ctrls[inp.id],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              hint: '${inp.normalMin}–${inp.normalMax}',
                              helperText:
                                  '${AppStrings.normalRange}: ${inp.normalMin}–${inp.normalMax} ${inp.unit}',
                              suffix: Text(inp.unit,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.secondaryText)),
                              onChanged: (_) => setLocal(() {}),
                            ),
                          ]);
                    },
                  ),
                );
              }),

              // Notes
              AppTextField(
                controller: _notesCtrl,
                label: AppStrings.notes,
                hint: '${AppStrings.optional}…',
                minLines: 2,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Buttons (shared components)
              Row(children: [
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.secondary,
                    label: AppStrings.cancel,
                    isFullWidth: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ListenableBuilder(
                    listenable: Listenable.merge(_ctrls.values.toList()),
                    builder: (_, __) => AppButton(
                      variant: AppButtonVariant.primary,
                      label: _saving ? AppStrings.saving : AppStrings.save,
                      isFullWidth: true,
                      isLoading: _saving,
                      onPressed: (_canSave && !_saving) ? _save : null,
                    ),
                  ),
                ),
              ]),
            ]),
      ),
    );
  }
}

// ─── Axis label helpers ───────────────────────────────────────────────────────

const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _fmtHour(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  return '$h ${dt.hour >= 12 ? 'PM' : 'AM'}';
}

/// X-axis label formatted for the selected range:
///   today → time (9 AM), 7 days → weekday (Mon), 30 days → date (Jun 5).
String _axisLabel(DateTime dt, _Range range) => switch (range) {
      _Range.today => _fmtHour(dt),
      _Range.week => _weekdaysShort[dt.weekday - 1],
      _Range.month => _fmtDate(dt),
    };

/// Evenly-spaced, DE-DUPLICATED axis labels keyed by reading index. Skips a
/// label when it repeats the previous one (so two readings on the same day in
/// the 7-day view show "Mon" once, not twice).
Map<int, String> _buildAxisLabels(List<_VitalReading> sorted, _Range range) {
  final labels = <int, String>{};
  if (sorted.isEmpty) return labels;
  final step = (sorted.length / 5).ceil().clamp(1, 99);
  String? last;
  for (int i = 0; i < sorted.length; i++) {
    if (i % step != 0 && i != sorted.length - 1) continue;
    final lbl = _axisLabel(sorted[i].measuredAt, range);
    if (lbl == last) continue;
    labels[i] = lbl;
    last = lbl;
  }
  return labels;
}

// ─── Date helpers ─────────────────────────────────────────────────────────────

String _fmtDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}';
}

String _fmtDateTime(DateTime dt) {
  final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${_fmtDate(dt)}, $h:$m $ampm';
}
