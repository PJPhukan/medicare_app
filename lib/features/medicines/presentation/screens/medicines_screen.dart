import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../presentation/providers/medicines_provider.dart';
import '../../data/models/medicine_model.dart' as med_model;
import '../../domain/entities/medicine_entity.dart';

// ─── Mock data model ──────────────────────────────────────────────────────────

enum _MedScope { personal, sharedMaster, sharedMember }
enum _MedStatus { active, lowStock, prn }

class _Med {
  final String id, name, genericName, strength, form, usedFor, description;
  final List<String> times;
  final String food;
  final int stock;
  final String? expiry;
  final _MedScope scope;
  final _MedStatus status;

  const _Med({
    required this.id,
    required this.name,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.usedFor,
    required this.description,
    required this.times,
    required this.food,
    required this.stock,
    this.expiry,
    this.scope = _MedScope.personal,
    this.status = _MedStatus.active,
  });
}


// ─── Adapter ──────────────────────────────────────────────────────────────────

_Med _toMed(med_model.UserMedicine um) {
  final stock = um.effectiveStock ?? um.stock;
  final schedule = um.doseSchedules.isNotEmpty ? um.doseSchedules.first : null;
  final times = schedule?.doseTimes.map((d) => d.scheduledTime).toList() ?? [];
  final food = schedule?.doseTimes.isNotEmpty == true
      ? (schedule!.doseTimes.first.foodTiming ?? 'As directed')
      : 'As directed';
  final scope = um.scope == 'SHARED_MASTER'
      ? _MedScope.sharedMaster
      : um.scope == 'SHARED_MEMBER'
          ? _MedScope.sharedMember
          : _MedScope.personal;
  final status = um.isPrn
      ? _MedStatus.prn
      : um.isLowStock
          ? _MedStatus.lowStock
          : _MedStatus.active;
  return _Med(
    id: um.id,
    name: um.displayName,
    genericName: um.medicine.genericName ?? '',
    strength: um.medicine.strength ?? '',
    form: um.medicine.dosageForm ?? '',
    usedFor: '',
    description: um.medicine.description ?? '',
    times: times,
    food: food,
    stock: stock?.quantity ?? 0,
    expiry: stock?.expiryDate,
    scope: scope,
    status: status,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _isGrid = true;
  int _statusFilter = 0; // 0=All, 1=Active, 2=LowStock, 3=PRN
  String _scopeFilter = 'all';
  String _search = '';
  final _speech = SpeechToText();
  bool _isListening = false;

  final _statusLabels = [
    AppStrings.filterAll,
    AppStrings.filterActive,
    AppStrings.filterLowStock,
    AppStrings.filterPrn,
  ];

  final _scopeOptions = [
    ('all', AppStrings.scopeAll),
    ('mine', AppStrings.scopeMine),
    ('shared', AppStrings.scopeShared),
    ('assigned', AppStrings.scopeAssigned),
  ];

  List<_Med> get _visible {
    final q = _search.trim().toLowerCase();
    final meds = ref.watch(medicinesProvider).medicines.map(_toMed).toList();
    return meds.where((m) {
      if (_scopeFilter == 'mine' && m.scope != _MedScope.personal) return false;
      if (_scopeFilter == 'shared' && m.scope != _MedScope.sharedMaster) return false;
      if (_scopeFilter == 'assigned' && m.scope != _MedScope.sharedMember) return false;
      if (_statusFilter == 1 && m.status != _MedStatus.active) return false;
      if (_statusFilter == 2 && m.status != _MedStatus.lowStock) return false;
      if (_statusFilter == 3 && m.status != _MedStatus.prn) return false;
      if (q.isNotEmpty) {
        return m.name.toLowerCase().contains(q) || m.genericName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _speech.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onError: (_) { if (mounted) setState(() => _isListening = false); },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available || !mounted) return;
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      if (!mounted) return;
      _searchCtrl.text = result.recognizedWords;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
      setState(() => _search = result.recognizedWords);
    });
  }

  // ─── Detail sheet ─────────────────────────────────────────────────────────

  void _openDetail(_Med med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(med: med),
    );
  }

  // ─── Add medicine sheet ───────────────────────────────────────────────────

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMedicineSheet(),
    );
  }

  // ─── Filter helpers ───────────────────────────────────────────────────────

  int get _activeFilterCount {
    int n = 0;
    if (_statusFilter != 0) n++;
    if (_scopeFilter != 'all') n++;
    return n;
  }

  void _openFilters() {
    int tempStatus = _statusFilter;
    String tempScope = _scopeFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setLocal) {
          final isDark    = Theme.of(context).brightness == Brightness.dark;
          final bg        = isDark ? context.cardBg : Colors.white;
          final border    = isDark ? context.borderCol : AppColors.light300;
          final bottomPad = MediaQuery.paddingOf(context).bottom;

          Widget filterChip(String label, bool selected, VoidCallback onTap) =>
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : Colors.transparent,
                    borderRadius: AppBorderRadius.pill,
                    border: Border.all(
                      color: selected ? AppColors.teal : border,
                    ),
                  ),
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                        letterSpacing: 0,
                      )),
                ),
              );

          return Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: border, borderRadius: AppBorderRadius.pill,
                    ),
                  ),
                ),
                // Header row
                Row(
                  children: [
                    AppText.h3('Filters'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setLocal(() {
                        tempStatus = 0;
                        tempScope = 'all';
                      }),
                      child: AppText.labelSm('Reset', color: AppColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Status section
                Text('STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _statusLabels.asMap().entries.map((e) =>
                    filterChip(e.value, tempStatus == e.key, () =>
                        setLocal(() => tempStatus = e.key)),
                  ).toList(),
                ),
                const SizedBox(height: 22),

                // Scope section
                Text('MEDICINES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _scopeOptions.map((opt) =>
                    filterChip(opt.$2, tempScope == opt.$1, () =>
                        setLocal(() => tempScope = opt.$1)),
                  ).toList(),
                ),
                const SizedBox(height: 28),

                // Apply button
                AppButton.primary(
                  label: 'Apply Filters',
                  isFullWidth: true,
                  onPressed: () {
                    setState(() {
                      _statusFilter = tempStatus;
                      _scopeFilter  = tempScope;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(medicinesProvider.notifier).load(),
        child: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 68,
            leading: AppIconButton(
              icon: Icon(Icons.menu_rounded, size: 22,
                  color: context.primaryText),
              onPressed: openAppSidebar,
              tooltip: 'Menu',
              backgroundColor: Colors.transparent,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h3(AppStrings.myMedicines,
                    color: context.primaryText),
                AppText.bodySm('Manage all your medicines in one place',
                    color: context.secondaryText),
              ],
            ),
            actions: [
              // Grid / List toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isGrid = !_isGrid);
                },
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Icon(
                    _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    size: 18,
                    color: context.primaryText,
                  ),
                ),
              ),
              // Add button
              GestureDetector(
                onTap: _openAdd,
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: AppBorderRadius.mdAll,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search + Filters ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isDark ? context.inputBg : Colors.white,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: _isListening ? AppColors.teal : border,
                              width: _isListening ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(Icons.search_rounded, size: 18,
                                  color: _isListening ? AppColors.teal : AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: _isListening
                                        ? AppStrings.listeningHint
                                        : AppStrings.searchMedicines,
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: _isListening
                                          ? AppColors.teal.withValues(alpha: 0.8)
                                          : AppColors.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 13),
                                  ),
                                ),
                              ),
                              if (_search.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.close_rounded, size: 16,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              GestureDetector(
                                onTap: _toggleListen,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: _isListening
                                          ? AppColors.teal.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                                      size: 16,
                                      color: _isListening ? AppColors.teal : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filters button with active-count badge
                      GestureDetector(
                        onTap: _openFilters,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: _activeFilterCount > 0
                                    ? AppColors.teal.withValues(alpha: 0.10)
                                    : (isDark ? context.inputBg : Colors.white),
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(
                                  color: _activeFilterCount > 0 ? AppColors.teal : border,
                                  width: _activeFilterCount > 0 ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune_rounded, size: 14, color: AppColors.teal),
                                  const SizedBox(width: 6),
                                  AppText.labelSm('Filters', color: AppColors.teal,
                                      fontWeight: FontWeight.w600),
                                ],
                              ),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                top: -5, right: -5,
                                child: Container(
                                  width: 17, height: 17,
                                  decoration: const BoxDecoration(
                                    color: AppColors.teal, shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('$_activeFilterCount',
                                        style: const TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _SummaryStrip(meds: ref.watch(medicinesProvider).medicines.map(_toMed).toList()),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Medicine list / grid ──────────────────────────────────────────
          if (ref.watch(medicinesProvider).isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => AppSkeleton(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? context.cardBg : Colors.white,
                        borderRadius: AppBorderRadius.lgAll,
                      ),
                    ),
                  ),
                  childCount: 6,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            )
          else if (_visible.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: AppEmptyState(
                  icon: Icons.medication_rounded,
                  title: AppStrings.noMedicinesInView,
                  action: _openAdd,
                  actionLabel: '+ ${AppStrings.addMedicine}',
                ),
              ),
            )
          else if (_isGrid)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _MedCard(med: _visible[i], onTap: () => _openDetail(_visible[i])),
                  childCount: _visible.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MedListRow(med: _visible[i], onTap: () => _openDetail(_visible[i])),
                  ),
                  childCount: _visible.length,
                ),
              ),
            ),
        ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: _openAdd,
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.textInverse,
          icon: const Icon(Icons.add_rounded),
          label: AppText.labelMd(AppStrings.addMedicine, color: AppColors.textInverse),
        ),
      ),
    );
  }
}

// ─── Summary strip ────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final List<_Med> meds;
  const _SummaryStrip({required this.meds});

  @override
  Widget build(BuildContext context) {
    final total = meds.length;
    final active = meds.where((m) => m.status == _MedStatus.active).length;
    final lowStock = meds.where((m) => m.status == _MedStatus.lowStock).length;
    return Row(
      children: [
        _SummaryChip(icon: Icons.medication_rounded, label: 'Total', count: total, color: AppColors.teal),
        const SizedBox(width: 10),
        _SummaryChip(icon: Icons.check_circle_outline_rounded, label: 'Active', count: active, color: AppColors.green),
        const SizedBox(width: 10),
        _SummaryChip(icon: Icons.warning_amber_rounded, label: 'Low Stock', count: lowStock, color: AppColors.amber),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AppContainer.tinted(
              color: color,
              borderRadius: AppBorderRadius.smAll,
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color, height: 1)),
                  AppText.bodyXs(label, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _MedStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _MedStatus.active => _badge(
          AppColors.green,
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(AppStrings.activeStatus,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.green, letterSpacing: 0.3)),
          ]),
        ),
      _MedStatus.lowStock => _badge(
          AppColors.amber,
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.amber),
            const SizedBox(width: 4),
            Text(AppStrings.lowStockStatus,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.amber, letterSpacing: 0.3)),
          ]),
        ),
      _MedStatus.prn => _badge(
          AppColors.purple,
          Text(AppStrings.prnLabel,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.purple, letterSpacing: 0.3)),
        ),
    };
  }

  Widget _badge(Color color, Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppBorderRadius.pill,
        ),
        child: child,
      );
}

// ─── Scope badge ──────────────────────────────────────────────────────────────

class _ScopeBadge extends StatelessWidget {
  final _MedScope scope;
  const _ScopeBadge(this.scope);

  @override
  Widget build(BuildContext context) {
    if (scope == _MedScope.personal) return const SizedBox.shrink();
    final (color, icon, label) = scope == _MedScope.sharedMaster
        ? (AppColors.teal, Icons.share_rounded, 'Shared')
        : (AppColors.blue, Icons.person_add_rounded, 'Caretaker');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: color, letterSpacing: 0.3)),
      ]),
    );
  }
}

// ─── Medicine card (grid) ─────────────────────────────────────────────────────

class _MedCard extends StatelessWidget {
  final _Med med;
  final VoidCallback onTap;
  const _MedCard({required this.med, required this.onTap});

  Color get _statusColor => switch (med.status) {
        _MedStatus.active   => AppColors.teal,
        _MedStatus.lowStock => AppColors.amber,
        _MedStatus.prn      => AppColors.purple,
      };

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final border    = isDark ? context.borderCol : AppColors.light300;
    final stockFill = (med.stock / 60).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: _statusColor.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colored top strip ────────────────────────────────────────
            Container(height: 3, color: _statusColor),

            // ── Card body ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: icon | spacer | status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppContainer.tinted(
                          color: _statusColor,
                          borderRadius: AppBorderRadius.mdAll,
                          padding: const EdgeInsets.all(11),
                          child: Icon(Icons.medication_rounded,
                              color: _statusColor, size: 22),
                        ),
                        const Spacer(),
                        _StatusBadge(med.status),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    AppText.labelMd(med.name,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),

                    // Strength · Form
                    AppText.bodyXs('${med.strength} · ${med.form}',
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),

                    // Schedule chips or PRN chip
                    if (med.status == _MedStatus.prn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.10),
                          borderRadius: AppBorderRadius.pill,
                        ),
                        child: Text(AppStrings.prnNote,
                            style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: AppColors.purple,
                            )),
                      )
                    else if (med.times.isNotEmpty)
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: med.times.map((t) {
                          final hour = int.tryParse(t.split(':')[0]) ?? 0;
                          final isNight = hour >= 18;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? context.inputBg : AppColors.light200,
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNight
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny_rounded,
                                  size: 10,
                                  color: isNight
                                      ? AppColors.purple.withValues(alpha: 0.8)
                                      : AppColors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(t,
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: isDark ? context.primaryText : const Color(0xFF334155),
                                      letterSpacing: 0.3,
                                    )),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const Spacer(),

                    // Stock count + scope badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${med.stock}',
                                style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800,
                                  color: _statusColor, height: 1,
                                ),
                              ),
                              TextSpan(
                                text: '  Units',
                                style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _ScopeBadge(med.scope),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Stock progress bar flush to bottom ───────────────────────
            LinearProgressIndicator(
              value: stockFill,
              minHeight: 6,
              backgroundColor: _statusColor.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Medicine list row ────────────────────────────────────────────────────────

class _MedListRow extends StatelessWidget {
  final _Med med;
  final VoidCallback onTap;
  const _MedListRow({required this.med, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (med.status) {
      _MedStatus.active   => AppColors.teal,
      _MedStatus.lowStock => AppColors.amber,
      _MedStatus.prn      => AppColors.purple,
    };
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  AppContainer.tinted(
                    color: statusColor,
                    borderRadius: AppBorderRadius.mdAll,
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.medication_rounded, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: AppText.labelMd(med.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        _StatusBadge(med.status),
                      ]),
                      const SizedBox(height: 2),
                      AppText.bodySm('${med.strength} · ${med.form}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        AppText.bodyXs('${med.stock} units'),
                        const SizedBox(width: 12),
                        if (med.times.isNotEmpty) ...[
                          Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          AppText.bodyXs(med.times.join(' · ')),
                        ] else
                          AppText.bodyXs(AppStrings.prnNote, color: AppColors.purple),
                        const Spacer(),
                        _ScopeBadge(med.scope),
                      ]),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                ]),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Detail bottom sheet ─────────────────────────────────────────────────────

class _DetailSheet extends ConsumerStatefulWidget {
  final _Med med;
  const _DetailSheet({required this.med});

  @override
  ConsumerState<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends ConsumerState<_DetailSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _confirmRemove() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.removeMedicineTitle,
      message: AppStrings.removeMedicineDesc,
      confirmLabel: AppStrings.remove,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context);
    try {
      await ref.read(medicinesProvider.notifier).deleteMedicine(widget.med.id);
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.medicineDeleted);
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }

  Color _statusColorFor(_MedStatus status) => switch (status) {
    _MedStatus.active   => AppColors.teal,
    _MedStatus.lowStock => AppColors.amber,
    _MedStatus.prn      => AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;
    final m = widget.med;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppBorderRadius.topXxl,
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: AppBorderRadius.pill)),
          const SizedBox(height: 12),

          // Gradient hero header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _statusColorFor(m.status),
                  _statusColorFor(m.status).withValues(alpha: 0.68),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: const Icon(Icons.medication_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${m.genericName} · ${m.strength}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppStrings.edit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9), letterSpacing: 0)),
                  ),
                ]),
                if (m.scope != _MedScope.personal) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: AppBorderRadius.mdAll,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(m.scope == _MedScope.sharedMaster ? Icons.share_rounded : Icons.person_add_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        m.scope == _MedScope.sharedMaster ? 'Shared bottle — stock split with other patients' : 'Stock is managed by your caretaker.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      )),
                    ]),
                  ),
                ],
              ],
            ),
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.teal, letterSpacing: 0),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 0),
              indicatorColor: AppColors.teal,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: AppStrings.overviewTab),
                Tab(text: AppStrings.scheduleTab),
                Tab(text: AppStrings.stockTab),
                Tab(text: AppStrings.infoTab),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(med: m, controller: ctrl, onRemove: _confirmRemove),
                _ScheduleTab(med: m, controller: ctrl),
                _StockTab(med: m, controller: ctrl),
                _InfoTab(med: m, controller: ctrl),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  final VoidCallback onRemove;

  const _OverviewTab({required this.med, required this.controller, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // Primary use
        _Section(
          label: AppStrings.primaryUseLabel,
          child: AppText.bodyMd(med.usedFor),
        ),
        const SizedBox(height: 20),

        // Schedule
        _Section(
          label: AppStrings.scheduleLabel,
          child: med.status == _MedStatus.prn
              ? AppText.bodyMd(AppStrings.prnNote, color: AppColors.purple)
              : med.times.isEmpty
                  ? AppText.bodySm(AppStrings.noScheduleSet)
                  : Column(
                      children: med.times.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: cardBg, borderRadius: AppBorderRadius.mdAll),
                          child: Row(children: [
                            AppText.labelMd(t, color: AppColors.teal),
                            const SizedBox(width: 12),
                            Expanded(child: AppText.bodySm('1 dose')),
                            AppText.bodySm(med.food),
                          ]),
                        ),
                      )).toList(),
                    ),
        ),
        const SizedBox(height: 20),

        // Adherence mini calendar (last 7 days)
        _Section(
          label: AppStrings.adherenceLabel,
          child: Row(
            children: ['M','T','W','T','F','S','S'].asMap().entries.map((e) {
              final i = e.key;
              final todayIdx = DateTime.now().weekday - 1; // Mon=0
              final isFuture = i > todayIdx;
              final isToday = i == todayIdx;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isFuture
                        ? Colors.transparent
                        : isToday
                            ? AppColors.teal.withValues(alpha: 0.15)
                            : AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: AppBorderRadius.smAll,
                    border: isFuture
                        ? Border.all(color: border, width: 1, style: BorderStyle.solid)
                        : null,
                  ),
                  child: Center(
                    child: Text(e.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isFuture
                              ? AppColors.textHint
                              : isToday
                                  ? AppColors.teal
                                  : AppColors.teal.withValues(alpha: 0.6),
                          letterSpacing: 0,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Instructions
        _Section(
          label: AppStrings.instructionsLabel,
          child: Text(med.description,
              style: const TextStyle(fontSize: 14, height: 1.7)),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(children: [
          if (med.status != _MedStatus.prn)
            Expanded(
              child: AppButton.primary(
                label: AppStrings.markTaken,
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          if (med.status != _MedStatus.prn) const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 18),
          ),
        ]),
      ],
    );
  }
}

// ─── Schedule tab ─────────────────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  const _ScheduleTab({required this.med, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        Text(AppStrings.fullScheduleLabel,
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textHint, letterSpacing: 1,
            )),
        const SizedBox(height: 12),
        if (med.status == _MedStatus.prn || med.times.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.purple),
              const SizedBox(width: 10),
              AppText.bodyMd(AppStrings.prnNote, color: AppColors.purple),
            ]),
          )
        else
          ...med.times.asMap().entries.map((e) {
            final labels = {1: ['Morning'], 2: ['Morning', 'Evening'], 3: ['Morning', 'Afternoon', 'Evening'], 4: ['Morning', 'Noon', 'Evening', 'Night']};
            final label = (labels[med.times.length] ?? [])[e.key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: border),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.smAll,
                    ),
                    child: AppText.labelMd(e.value, color: AppColors.teal),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(label, style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0)),
                    AppText.bodySm('1 dose · ${med.food}'),
                  ])),
                ]),
              ),
            );
          }),
      ],
    );
  }
}

// ─── Stock tab ────────────────────────────────────────────────────────────────

class _StockTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  const _StockTab({required this.med, required this.controller});

  @override
  Widget build(BuildContext context) {
    final stockColor = med.status == _MedStatus.lowStock ? AppColors.warning : AppColors.teal;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // Big stock count
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: stockColor.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${med.stock}',
                  style: TextStyle(
                    fontSize: 42, fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  )),
              AppText.bodySm(AppStrings.unitsRemaining),
              if (med.expiry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AppText.bodyXs('Expires: ${med.expiry}'),
                ),
            ]),
            const Spacer(),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: stockColor.withValues(alpha: 0.4), width: 4),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: (med.stock / 60).clamp(0, 1),
                  strokeWidth: 5,
                  backgroundColor: stockColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(stockColor),
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 20),

      ],
    );
  }
}

// ─── Info tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  const _InfoTab({required this.med, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        _AccordionItem(title: 'What is it used for?', body: med.usedFor),
        _AccordionItem(title: 'How to take', body: med.description),
        _AccordionItem(title: 'Side effects', body: 'Common side effects may include nausea, dizziness, or stomach upset. Contact your doctor if symptoms persist.'),
        _AccordionItem(title: 'Precautions', body: 'Inform your doctor of all medications you are taking. Do not stop without consulting your healthcare provider.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Text(AppStrings.infoDisclaimer,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning.withValues(alpha: 0.85),
                height: 1.6,
              )),
        ),
      ],
    );
  }
}

class _AccordionItem extends StatefulWidget {
  final String title, body;
  const _AccordionItem({required this.title, required this.body});

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? context.borderCol : AppColors.light300;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: border),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              Expanded(child: AppText.labelMd(widget.title)),
              Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20, color: AppColors.textSecondary),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(widget.body,
                style: const TextStyle(fontSize: 14, height: 1.65)),
          ),
      ]),
    );
  }
}

// ─── Section label helper ─────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: AppColors.textHint, letterSpacing: 1,
      )),
      const SizedBox(height: 8),
      child,
    ],
  );
}

// ─── Add Medicine sheet (4 steps) ────────────────────────────────────────────

class _AddMedicineSheet extends ConsumerStatefulWidget {
  const _AddMedicineSheet();

  @override
  ConsumerState<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends ConsumerState<_AddMedicineSheet> {
  int _step = 0;
  final _steps = [
    AppStrings.addMedicineStep1,
    AppStrings.addMedicineStep2,
    AppStrings.addMedicineStep3,
    AppStrings.addMedicineStep4,
  ];

  // Step 0
  final _medSearchCtrl = TextEditingController();
  String _medSearch = '';
  CatalogMedicineEntity? _selected;
  List<CatalogMedicineEntity> _catalogItems = [];
  bool _catalogLoading = false;
  bool _showRequest = false;
  final _reqNameCtrl = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;

  // Step 1
  String _whoMode = 'self';

  // Step 2
  String _freq = 'twice';
  final _freqOptions = [
    ('once', AppStrings.onceDaily, ['09:00']),
    ('twice', AppStrings.twiceDaily, ['09:00', '21:00']),
    ('three', AppStrings.threeDaily, ['08:00', '14:00', '21:00']),
    ('prn', AppStrings.asNeeded, <String>[]),
  ];
  List<String> _times = ['09:00', '21:00'];
  String _food = 'with';
  final _doseCtrl = TextEditingController(text: '1 tablet');
  final _foodOptions = [('before', AppStrings.beforeFood), ('with', AppStrings.withFood), ('after', AppStrings.afterFood)];

  // Step 3
  final _qtyCtrl = TextEditingController(text: '30');
  final _expiryCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog('');
  }

  Future<void> _loadCatalog(String query) async {
    setState(() => _catalogLoading = true);
    try {
      final results = await ref.read(medicinesRepositoryProvider).searchCatalog(query);
      if (!mounted) return;
      setState(() { _catalogItems = results; _catalogLoading = false; });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _catalogLoading = false);
    }
  }

  void _setFreq(String f) {
    final opt = _freqOptions.firstWhere((x) => x.$1 == f);
    setState(() { _freq = f; _times = List<String>.from(opt.$3); });
  }

  bool get _canProceed {
    if (_step == 0) return _selected != null;
    if (_step == 1) return true;
    return true;
  }

  void _next() {
    if (!_canProceed) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(medicinesProvider.notifier).addMedicine(
        medicineId: _selected!.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.success(context, 'Medicine saved successfully.');
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _medSearchCtrl.dispose();
    _reqNameCtrl.dispose();
    _doseCtrl.dispose();
    _qtyCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onError: (_) { if (mounted) setState(() => _isListening = false); },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available || !mounted) return;
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      if (!mounted) return;
      _medSearchCtrl.text = result.recognizedWords;
      _medSearchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _medSearchCtrl.text.length),
      );
      setState(() => _medSearch = result.recognizedWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.topXxl),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: AppBorderRadius.pill)),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: AppText.h3(AppStrings.addMedicine)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.close,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0,
                    )),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _steps.asMap().entries.map((e) {
                final i = e.key;
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(children: [
                    Expanded(
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? AppColors.teal
                                : active
                                    ? AppColors.teal.withValues(alpha: 0.15)
                                    : Colors.transparent,
                            border: Border.all(
                              color: done || active ? AppColors.teal : border,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check_rounded, size: 12, color: Colors.black)
                                : Text('${i + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: active ? AppColors.teal : AppColors.textHint,
                                      letterSpacing: 0,
                                    )),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(e.value,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: active || done ? AppColors.teal : AppColors.textHint,
                              letterSpacing: 0,
                            )),
                      ]),
                    ),
                    if (i < _steps.length - 1)
                      Container(width: 20, height: 1,
                          color: i < _step ? AppColors.teal : border),
                  ]),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: border),

          // Step content
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                if (_step == 0) _buildStep0(isDark, border),
                if (_step == 1) _buildStep1(isDark, border),
                if (_step == 2) _buildStep2(isDark, border),
                if (_step == 3) _buildStep3(),
              ],
            ),
          ),

          // Bottom nav
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Row(children: [
              if (_step > 0)
                Expanded(
                  child: AppButton.secondary(
                    label: AppStrings.back,
                    isFullWidth: true,
                    onPressed: () => setState(() => _step--),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton.primary(
                  label: _saving ? AppStrings.saving : (_step == _steps.length - 1 ? AppStrings.save : AppStrings.next),
                  isFullWidth: true,
                  isLoading: _saving,
                  onPressed: (_canProceed && !_saving) ? _next : null,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep0(bool isDark, Color border) {
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Voice search
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? context.inputBg : AppColors.light200,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: _isListening ? AppColors.teal : border,
            width: _isListening ? 1.5 : 1.0,
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 18,
              color: _isListening ? AppColors.teal : AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _medSearchCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: _isListening
                    ? AppStrings.listeningHint
                    : AppStrings.searchMedicines,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: _isListening
                      ? AppColors.teal.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 12),
              ),
              onChanged: (v) {
                setState(() { _medSearch = v; _showRequest = false; });
                _loadCatalog(v);
              },
            ),
          ),
          if (_medSearch.isNotEmpty)
            GestureDetector(
              onTap: () {
                _medSearchCtrl.clear();
                setState(() { _medSearch = ''; _showRequest = false; });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
              ),
            ),
          GestureDetector(
            onTap: _toggleListen,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.teal.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: 16,
                  color: _isListening ? AppColors.teal : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ]),
      ),

      const SizedBox(height: 16),

      if (_catalogLoading)
        const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
        ))
      else ...[
        Text(
          _catalogItems.isEmpty ? AppStrings.noMatchesLabel
              : _medSearch.isEmpty ? AppStrings.popularLabel
                  : AppStrings.resultsLabel,
          style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.textHint, letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 10),

        ..._catalogItems.map((item) {
          final active = _selected?.id == item.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selected = item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? AppColors.teal.withValues(alpha: 0.08) : cardBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: active ? AppColors.teal.withValues(alpha: 0.4) : border,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal.withValues(alpha: 0.15) : (isDark ? context.borderCol : AppColors.light200),
                      borderRadius: AppBorderRadius.smAll,
                    ),
                    child: Icon(Icons.medication_rounded, size: 18,
                        color: active ? AppColors.teal : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AppText.labelMd(item.name),
                    AppText.bodySm([item.genericName, item.strength, item.dosageForm].join(' · '),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  if (active)
                    const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
                ]),
              ),
            ),
          );
        }),
      ],

      const SizedBox(height: 8),

      if (!_showRequest)
        Center(
          child: TextButton(
            onPressed: () => setState(() { _showRequest = true; _reqNameCtrl.text = _medSearch; }),
            child: AppText.bodySm(AppStrings.cantFindIt, color: AppColors.teal),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: AppText.labelMd(AppStrings.requestMedicine)),
              GestureDetector(
                onTap: () => setState(() => _showRequest = false),
                child: AppText.bodySm(AppStrings.cancel, color: AppColors.textSecondary),
              ),
            ]),
            const SizedBox(height: 6),
            AppText.bodySm(AppStrings.requestDesc),
            const SizedBox(height: 14),
            AppTextField(
              label: AppStrings.medicineNameLabel,
              controller: _reqNameCtrl,
              hint: 'e.g. 3 Mix Cream',
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              label: AppStrings.submitRequest,
              isFullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
          ]),
        ),
    ]);
  }

  Widget _buildStep1(bool isDark, Color border) {
    final options = [
      ('self', Icons.person_rounded, AppStrings.whoForYou, AppStrings.whoForYouDesc, AppColors.teal),
      ('patient', Icons.people_rounded, AppStrings.whoForPatient, AppStrings.whoForPatientDesc, AppColors.blue),
      ('shared', Icons.share_rounded, AppStrings.whoShared, AppStrings.whoSharedDesc, AppColors.purple),
    ];
    return Column(children: options.map((opt) {
      final active = _whoMode == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => setState(() => _whoMode = opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active ? opt.$5.withValues(alpha: 0.07) : Colors.transparent,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: active ? opt.$5.withValues(alpha: 0.4) : border),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: active ? opt.$5.withValues(alpha: 0.15) : (isDark ? context.inputBg : AppColors.light200),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Icon(opt.$2, color: active ? opt.$5 : AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppText.labelMd(opt.$3, color: active ? opt.$5 : context.primaryText),
                AppText.bodySm(opt.$4),
              ])),
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? opt.$5 : Colors.transparent,
                  border: Border.all(color: active ? opt.$5 : border, width: 2),
                ),
                child: active ? const Icon(Icons.check_rounded, size: 11, color: Colors.black) : null,
              ),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _buildStep2(bool isDark, Color border) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Frequency', style: const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: AppColors.textHint, letterSpacing: 1,
      )),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _freqOptions.map((f) {
          final active = _freq == f.$1;
          return GestureDetector(
            onTap: () => _setFreq(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: AppBorderRadius.pill,
                border: Border.all(color: active ? AppColors.teal : border),
              ),
              child: Text(f.$2, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? AppColors.teal : AppColors.textSecondary,
                letterSpacing: 0,
              )),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      if (_freq != 'prn') ...[
        Text('Dose times', style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: AppColors.textHint, letterSpacing: 1,
        )),
        const SizedBox(height: 10),
        ..._times.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? context.inputBg : AppColors.light100,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: border),
            ),
            child: Row(children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.teal),
              const SizedBox(width: 10),
              AppText.labelMd(e.value, color: AppColors.teal),
            ]),
          ),
        )),

        const SizedBox(height: 20),

        AppTextField(
          label: AppStrings.doseAmount,
          controller: _doseCtrl,
          hint: AppStrings.doseAmountHint,
        ),

        const SizedBox(height: 16),

        Text(AppStrings.foodRelation, style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: AppColors.textHint, letterSpacing: 1,
        )),
        const SizedBox(height: 10),
        Row(children: _foodOptions.map((f) {
          final active = _food == f.$1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: f.$1 != 'after' ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _food = f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: active ? AppColors.teal : border),
                  ),
                  child: Center(
                    child: Text(f.$2, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: active ? AppColors.teal : AppColors.textSecondary,
                      letterSpacing: 0,
                    )),
                  ),
                ),
              ),
            ),
          );
        }).toList()),
      ] else
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.07),
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
          ),
          child: Text(AppStrings.scheduleOptional,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.purple.withValues(alpha: 0.9),
              )),
        ),
    ]);
  }

  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppText.bodySm(AppStrings.stockOptional),
      const SizedBox(height: 20),
      AppTextField(
        label: AppStrings.quantityLabel,
        controller: _qtyCtrl,
        hint: AppStrings.stockQtyHint,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 14),
      AppTextField(
        label: AppStrings.expiryLabel,
        controller: _expiryCtrl,
        hint: 'e.g. Dec 2026',
      ),
    ]);
  }
}
