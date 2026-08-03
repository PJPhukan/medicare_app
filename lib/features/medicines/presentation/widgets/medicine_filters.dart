import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import 'medicine_status.dart';

// ─── Filter model ────────────────────────────────────────────────────────────

enum MedScopeFilter { all, mine, shared, assigned }

extension on MedScopeFilter {
  String get label => switch (this) {
        MedScopeFilter.all => AppStrings.scopeAll,
        MedScopeFilter.mine => AppStrings.scopeMine,
        MedScopeFilter.shared => AppStrings.scopeShared,
        MedScopeFilter.assigned => AppStrings.scopeAssigned,
      };
}

/// Status options in display order. Null is "All".
const kMedStatusOptions = <(MedStatus?, String)>[
  (null, AppStrings.filterAll),
  (MedStatus.active, AppStrings.filterActive),
  (MedStatus.lowStock, AppStrings.filterLowStock),
  (MedStatus.prn, AppStrings.filterPrn),
];

/// The cabinet's view state. Owns the matching rule so the screen only decides
/// what to render, not what qualifies.
class MedicineFilter {
  const MedicineFilter({
    this.status,
    this.scope = MedScopeFilter.all,
    this.search = '',
  });

  /// Null means "all statuses".
  final MedStatus? status;
  final MedScopeFilter scope;
  final String search;

  MedicineFilter copyWith({
    MedStatus? status,
    MedScopeFilter? scope,
    String? search,
    bool clearStatus = false,
  }) =>
      MedicineFilter(
        status: clearStatus ? null : (status ?? this.status),
        scope: scope ?? this.scope,
        search: search ?? this.search,
      );

  /// Search is a live text field, not something the "N filters applied" badge
  /// should count.
  int get activeCount =>
      (status != null ? 1 : 0) + (scope != MedScopeFilter.all ? 1 : 0);

  bool matches(UserMedicineEntity m) {
    if (status != null && m.status != status) return false;
    final scopeOk = switch (scope) {
      MedScopeFilter.all => true,
      MedScopeFilter.mine => !m.isShared,
      MedScopeFilter.shared => m.isSharedMaster,
      MedScopeFilter.assigned => m.isSharedMember,
    };
    if (!scopeOk) return false;

    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    return m.displayName.toLowerCase().contains(q) ||
        m.genericName.toLowerCase().contains(q);
  }

  List<UserMedicineEntity> apply(List<UserMedicineEntity> all) =>
      all.where(matches).toList();
}

// ─── Status segment ──────────────────────────────────────────────────────────

/// Horizontal All / Active / Low stock / As-needed selector.
class MedicineStatusSegment extends StatelessWidget {
  const MedicineStatusSegment({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// Null = "All".
  final MedStatus? selected;
  final ValueChanged<MedStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppChipRow(
      padding: EdgeInsets.zero,
      chips: [
        for (final (status, label) in kMedStatusOptions)
          AppFilterChip(
            label: label,
            selected: status == selected,
            // Tinting each chip to the status it selects makes the filter row
            // and the badges on the cards read as one colour language.
            color: status?.color,
            onTap: () => onSelect(status),
          ),
      ],
    );
  }
}

// ─── Filters button ──────────────────────────────────────────────────────────

class MedicineFilterButton extends StatelessWidget {
  const MedicineFilterButton({
    super.key,
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = activeCount > 0;
    return AnimatedTap(
      onTap: onTap,
      borderRadius: AppBorderRadius.pill,
      child: AppNotificationDot(
        count: activeCount,
        show: on,
        color: AppColors.teal,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.teal.withValues(alpha: 0.10) : context.cardBg,
            borderRadius: AppBorderRadius.pill,
            border: Border.all(
              color: on ? AppColors.teal : context.borderCol,
              width: on ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              AppText.labelSm('Filters',
                  color: AppColors.teal, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filters sheet ───────────────────────────────────────────────────────────

/// Bottom sheet for the status + scope filters. Resolves to the chosen filter,
/// or null when dismissed without applying.
Future<MedicineFilter?> showMedicineFiltersSheet(
  BuildContext context,
  MedicineFilter current,
) {
  return AppBottomSheet.show<MedicineFilter>(
    context,
    title: 'Filters',
    child: _FiltersSheetBody(initial: current),
  );
}

class _FiltersSheetBody extends StatefulWidget {
  const _FiltersSheetBody({required this.initial});

  final MedicineFilter initial;

  @override
  State<_FiltersSheetBody> createState() => _FiltersSheetBodyState();
}

class _FiltersSheetBodyState extends State<_FiltersSheetBody> {
  late MedicineFilter _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeaderText(
          title: 'Status',
          padding: EdgeInsets.zero,
          actionLabel: _draft.activeCount > 0 ? 'Reset' : null,
          // Reset clears the chips but keeps whatever is typed in the search
          // box — that field lives in the app bar, not this sheet.
          onAction: _draft.activeCount > 0
              ? () => setState(() =>
                  _draft = MedicineFilter(search: _draft.search))
              : null,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (status, label) in kMedStatusOptions)
              AppFilterChip(
                label: label,
                selected: _draft.status == status,
                color: status?.color,
                onTap: () => setState(() => _draft = status == null
                    ? _draft.copyWith(clearStatus: true)
                    : _draft.copyWith(status: status)),
              ),
          ],
        ),
        const SizedBox(height: 22),
        const AppSectionHeaderText(
            title: 'Medicines', padding: EdgeInsets.zero),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final scope in MedScopeFilter.values)
              AppFilterChip(
                label: scope.label,
                selected: _draft.scope == scope,
                onTap: () => setState(() => _draft = _draft.copyWith(scope: scope)),
              ),
          ],
        ),
        const SizedBox(height: 28),
        AppButton(
          variant: AppButtonVariant.primary,
          label: 'Apply Filters',
          isFullWidth: true,
          onPressed: () => Navigator.of(context).pop(_draft),
        ),
      ],
    );
  }
}
