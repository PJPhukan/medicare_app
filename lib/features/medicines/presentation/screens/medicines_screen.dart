import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicines_provider.dart';
import '../widgets/widgets.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
  final _searchCtrl = TextEditingController();
  bool _isGrid = true;
  MedicineFilter _filter = const MedicineFilter();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAdd() => context.push(AppRoutes.medicineAdd);

  Future<void> _openFilters() async {
    final applied = await showMedicineFiltersSheet(context, _filter);
    if (applied != null && mounted) setState(() => _filter = applied);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicinesProvider);
    final visible = _filter.apply(state.medicines);
    final failedToLoad =
        state.error != null && !state.isLoading && state.medicines.isEmpty;

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(medicinesProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: AppStrings.myMedicines,
                subtitle: 'Manage all your medicines in one place',
                actions: [
                  AppIconButton(
                    icon: Icon(_isGrid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded),
                    iconSize: 18,
                    color: context.primaryText,
                    size: 36,
                    borderColor: context.borderCol,
                    backgroundColor: context.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isGrid = !_isGrid);
                    },
                    tooltip: _isGrid ? 'List view' : 'Grid view',
                  ),
                  const SizedBox(width: 6,),
                  AppIconButton(
                    icon: const Icon(Icons.add_rounded),
                    iconSize: 20,
                    color: Colors.white,
                    size: 36,
                    backgroundColor: AppColors.teal,
                    borderColor: AppColors.teal,
                    borderRadius: AppBorderRadius.mdAll,
                    onPressed: _openAdd,
                    tooltip: AppStrings.addMedicine,
                  ),
                  const SizedBox(width: 8,)
                ],
              ),
            ),

            // ── Search + filters ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchTextVoiceInput(
                            controller: _searchCtrl,
                            hint: AppStrings.searchMedicines,
                            backgroundColor: context.cardBg,
                            borderColor: context.borderCol,
                            onChanged: (v) => setState(
                                () => _filter = _filter.copyWith(search: v)),
                            onClear: () => setState(
                                () => _filter = _filter.copyWith(search: '')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        MedicineFilterButton(
                          activeCount: _filter.activeCount,
                          onTap: _openFilters,
                        ),
                      ],
                    ),
               
                  ],
                ),
              ),
            ),

            // ── Results ──────────────────────────────────────────────────────
            if (failedToLoad)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Could not load medicines',
                    subtitle: state.error,
                    action: () => ref.read(medicinesProvider.notifier).load(),
                    actionLabel: 'Retry',
                  ),
                ),
              )
            else if (state.isLoading && state.medicines.isEmpty)
              const _LoadingGrid()
            else if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.medication_rounded,
                    title: state.medicines.isEmpty
                        ? AppStrings.noMedicinesInView
                        : 'Nothing matches these filters',
                    action: state.medicines.isEmpty
                        ? _openAdd
                        : () =>
                            setState(() => _filter = const MedicineFilter()),
                    actionLabel: state.medicines.isEmpty
                        ? '+ ${AppStrings.addMedicine}'
                        : 'Clear filters',
                  ),
                ),
              )
            else if (_isGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: _MedicineMasonry(
                    medicines: visible,
                    onTap: (m) => showMedicineDetailSheet(context, m),
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
                      child: MedicineListRow(
                        medicine: visible[i],
                        onTap: () =>
                            showMedicineDetailSheet(context, visible[i]),
                      ),
                    ),
                    childCount: visible.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _cardGap = 12.0;

/// Two columns of cards, each sized to its own content.
///
/// A [SliverGrid] gives every tile the same height, so the tallest case (a
/// two-line name plus four dose-time chips) sets the height for all of them
/// and every simpler card carries a visible void above its footer. Laying the
/// columns out by hand lets each card be exactly as tall as it needs to be.
///
/// Not lazy — it builds every card up front. Fine for a medicine cabinet,
/// which is tens of entries; reach for a real masonry sliver if that ever
/// stops being true.
class _MedicineMasonry extends StatelessWidget {
  const _MedicineMasonry({required this.medicines, required this.onTap});

  final List<UserMedicineEntity> medicines;
  final void Function(UserMedicineEntity) onTap;

  @override
  Widget build(BuildContext context) {
    // Alternating keeps the on-screen order close to the underlying list, so
    // the sort the user chose still reads left-to-right, top-to-bottom.
    final left = <UserMedicineEntity>[];
    final right = <UserMedicineEntity>[];
    for (final (i, m) in medicines.indexed) {
      (i.isEven ? left : right).add(m);
    }

    Widget column(List<UserMedicineEntity> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final m in items)
              Padding(
                padding: const EdgeInsets.only(bottom: _cardGap),
                child: MedicineGridCard(medicine: m, onTap: () => onTap(m)),
              ),
          ],
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(left)),
        const SizedBox(width: _cardGap),
        Expanded(child: column(right)),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => AppSkeleton(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppBorderRadius.xlAll,
              ),
            ),
          ),
          childCount: 6,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: _cardGap,
          crossAxisSpacing: _cardGap,
          childAspectRatio: 1.05,
        ),
      ),
    );
  }
}
