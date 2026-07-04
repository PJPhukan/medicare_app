import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../domain/entities/vital_reading_entity.dart';
import '../../domain/usecases/fetch_vital_history_usecase.dart';
import '../providers/vitals_provider.dart';
import '../../data/models/vital_config_model.dart' as vm;

// ─── Filter ───────────────────────────────────────────────────────────────────

enum _Filter { today, sevenDays, thirtyDays, lastMonth, all }

extension _FilterX on _Filter {
  String get key => switch (this) {
        _Filter.today => 'today',
        _Filter.sevenDays => '7d',
        _Filter.thirtyDays => '30d',
        _Filter.lastMonth => '1m',
        _Filter.all => 'all',
      };

  String get label => switch (this) {
        _Filter.today => 'Today',
        _Filter.sevenDays => '7 Days',
        _Filter.thirtyDays => '30 Days',
        _Filter.lastMonth => 'Last Month',
        _Filter.all => 'All Time',
      };
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final _fetchVitalHistoryUseCaseProvider = Provider<FetchVitalHistoryUseCase>(
  (ref) => FetchVitalHistoryUseCase(ref.read(vitalsRepositoryProvider)),
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class VitalHistoryScreen extends ConsumerStatefulWidget {
  const VitalHistoryScreen({
    super.key,
    required this.configId,
    required this.configName,
  });

  final String configId;
  final String configName;

  @override
  ConsumerState<VitalHistoryScreen> createState() => _VitalHistoryScreenState();
}

class _VitalHistoryScreenState extends ConsumerState<VitalHistoryScreen> {
  _Filter _filter = _Filter.all;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  final List<VitalReadingEntity> _readings = [];
  String? _nextCursor;
  bool _hasMore = false;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
      _readings.clear();
      _nextCursor = null;
      _hasMore = false;
    });
    try {
      final result = await ref.read(_fetchVitalHistoryUseCaseProvider).call(
            configId: widget.configId,
            filter: _filter.key,
          );
      if (!mounted) return;
      setState(() {
        _readings.addAll(result.readings);
        _nextCursor = result.nextCursor;
        _hasMore = result.nextCursor != null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _nextCursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final result = await ref.read(_fetchVitalHistoryUseCaseProvider).call(
            configId: widget.configId,
            filter: _filter.key,
            cursor: _nextCursor,
          );
      if (!mounted) return;
      setState(() {
        _readings.addAll(result.readings);
        _nextCursor = result.nextCursor;
        _hasMore = result.nextCursor != null;
      });
    } catch (_) {
      // silently ignore; user can scroll back to retry
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _changeFilter(_Filter f) {
    if (f == _filter) return;
    HapticFeedback.selectionClick();
    setState(() => _filter = f);
    _loadFirst();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;
    final cardBg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    // Grab configs to resolve input metadata for status computation.
    final configs = ref.watch(vitalsProvider).configs;
    final config = configs.cast<vm.VitalConfig?>().firstWhere(
          (c) => c?.id == widget.configId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppText.h3('${widget.configName} History', color: context.primaryText),
          AppText.bodySm('All your recorded readings',
              color: context.secondaryText),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _FilterBar(active: _filter, onChanged: _changeFilter),
        ),
      ),
      body: _loading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSkeleton(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                  ),
                ),
              ),
            )
          : _error != null
              ? AppErrorState(
                  message: _error,
                  onRetry: _loadFirst,
                )
              : _readings.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.timeline_rounded,
                      title: 'No readings found',
                      subtitle: 'No vitals recorded for this period.',
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _readings.length + 1,
                      itemBuilder: (_, i) {
                        if (i == _readings.length) {
                          return _Footer(
                              loadingMore: _loadingMore, hasMore: _hasMore);
                        }
                        return _ReadingTile(
                          reading: _readings[i],
                          config: config,
                          border: border,
                        );
                      },
                    ),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final _Filter active;
  final ValueChanged<_Filter> onChanged;
  const _FilterBar({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: _Filter.values.map((f) {
          final sel = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.teal : Colors.transparent,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(
                    color: sel
                        ? AppColors.teal
                        : context.secondaryText.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : context.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Reading tile ─────────────────────────────────────────────────────────────

class _ReadingTile extends StatelessWidget {
  final VitalReadingEntity reading;
  final vm.VitalConfig? config;
  final Color border;
  const _ReadingTile({
    required this.reading,
    required this.config,
    required this.border,
  });

  ({Color color, String label}) _worstStatus() {
    if (config == null) return (color: AppColors.success, label: 'Normal');
    Color c = AppColors.success;
    String l = 'Normal';
    for (final rv in reading.values) {
      final inp = config!.inputs.cast<vm.VitalInput?>().firstWhere(
            (i) => i?.id == rv.inputId,
            orElse: () => null,
          );
      if (inp == null) continue;
      if (rv.value < inp.warningMin || rv.value > inp.warningMax) {
        return (color: AppColors.error, label: 'High Risk');
      }
      if (rv.value < inp.normalMin || rv.value > inp.normalMax) {
        c = AppColors.warning;
        l = 'Warning';
      }
    }
    return (color: c, label: l);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.cardBg : Colors.white;
    final status = _worstStatus();
    final dt = reading.measuredAtDate;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    final h = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$h:$m $ampm';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: border),
      ),
      child: Row(children: [
        // Date column
        SizedBox(
          width: 72,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateStr,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.primaryText)),
            const SizedBox(height: 2),
            Text(timeStr,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textHint)),
          ]),
        ),
        const SizedBox(width: 12),
        // Values
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 2,
            children: reading.values.map((rv) {
              final inp = config?.inputs.cast<vm.VitalInput?>().firstWhere(
                    (i) => i?.id == rv.inputId,
                    orElse: () => null,
                  );
              final isWhole = rv.value % 1 == 0;
              final valStr = isWhole
                  ? rv.value.toInt().toString()
                  : rv.value.toStringAsFixed(1);
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: valStr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.primaryText),
                    ),
                    if (inp != null)
                      TextSpan(
                        text: ' ${inp.unit}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textHint),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 8),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: AppBorderRadius.pill,
          ),
          child: Text(
            status.label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: status.color),
          ),
        ),
      ]),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool loadingMore;
  final bool hasMore;
  const _Footer({required this.loadingMore, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.teal),
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'All readings loaded',
            style: TextStyle(fontSize: 12, color: context.secondaryText),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
