import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../providers/caretakers_provider.dart';

/// Per-tab access editor for one caretaker relationship, backed by the real
/// TabGrant system (view toggle switches the tab on/off; Add/Edit/Delete/Share
/// chips only appear for the ops that tab's TabConfig actually allows).
Future<void> showManageCaretakerPermissionsSheet(BuildContext context, CaretakerEntity caretaker) =>
    AppBottomSheet.show<void>(
      context,
      title: AppStrings.managePermissions,
      subtitle: caretaker.name,
      child: _PermissionsSheet(relationshipId: caretaker.relationshipId),
    );

class _PermissionsSheet extends ConsumerStatefulWidget {
  const _PermissionsSheet({required this.relationshipId});

  final String relationshipId;

  @override
  ConsumerState<_PermissionsSheet> createState() => _PermissionsSheetState();
}

class _PermissionsSheetState extends ConsumerState<_PermissionsSheet> {
  String? _savingTabId;

  TabGrantEntity? _grantFor(CaretakerEntity caretaker, String tabId) {
    for (final g in caretaker.tabGrants) {
      if (g.tabId == tabId) return g;
    }
    return null;
  }

  Future<void> _save(
    GrantableTabEntity tab, {
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  }) async {
    setState(() => _savingTabId = tab.id);
    final ok = await ref.read(caretakersProvider.notifier).saveTabGrant(
          relationshipId: widget.relationshipId,
          tabId: tab.id,
          opView: opView,
          opAdd: opAdd,
          opEdit: opEdit,
          opDelete: opDelete,
          opShare: opShare,
        );
    if (!mounted) return;
    setState(() => _savingTabId = null);
    if (!ok) AppSnackbar.error(context, AppStrings.permissionUpdateFailed);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caretakersProvider);
    final tabs = state.grantableTabs;
    final caretaker = state.caretakers.where((c) => c.relationshipId == widget.relationshipId).firstOrNull;

    if (caretaker == null) {
      // Removed from underneath this sheet (e.g. revoked in another tab) —
      // nothing left to manage.
      return const SizedBox.shrink();
    }

    if (tabs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: AppEmptyState(
          icon: Icons.lock_outline_rounded,
          title: AppStrings.noPermissionsAvailable,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: tabs.length,
      itemBuilder: (_, i) {
        final tab = tabs[i];
        final grant = _grantFor(caretaker, tab.id);
        final hasAccess = grant?.hasAccess ?? false;
        final isSaving = _savingTabId == tab.id;

        final extraOps = <(String, bool, bool)>[
          if (tab.allowAdd) ('Add', grant?.opAdd ?? false, true),
          if (tab.allowEdit) ('Edit', grant?.opEdit ?? false, true),
          if (tab.allowDelete) ('Delete', grant?.opDelete ?? false, true),
          if (tab.allowShare) ('Share', grant?.opShare ?? false, true),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AppListTile(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            color: Colors.transparent,
            title: tab.label,
            subtitleWidget: hasAccess && extraOps.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: AppChipRow(
                      chips: extraOps
                          .map((op) => AppFilterChip(
                                label: op.$1,
                                selected: op.$2,
                                color: AppColors.teal,
                                onTap: isSaving
                                    ? () {}
                                    : () => _save(
                                          tab,
                                          opView: true,
                                          opAdd: op.$1 == 'Add' ? !op.$2 : (grant?.opAdd ?? false),
                                          opEdit: op.$1 == 'Edit' ? !op.$2 : (grant?.opEdit ?? false),
                                          opDelete: op.$1 == 'Delete' ? !op.$2 : (grant?.opDelete ?? false),
                                          opShare: op.$1 == 'Share' ? !op.$2 : (grant?.opShare ?? false),
                                        ),
                              ))
                          .toList(),
                    ),
                  )
                : null,
            trailing: isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: AppLoadingSpinner(size: 20, strokeWidth: 2))
                : Switch(
                    value: hasAccess,
                    onChanged: (v) => _save(
                      tab,
                      opView: v,
                      opAdd: v ? (grant?.opAdd ?? false) : false,
                      opEdit: v ? (grant?.opEdit ?? false) : false,
                      opDelete: v ? (grant?.opDelete ?? false) : false,
                      opShare: v ? (grant?.opShare ?? false) : false,
                    ),
                    activeThumbColor: AppColors.teal,
                    activeTrackColor: AppColors.teal.withValues(alpha: 0.25),
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                  ),
          ),
        );
      },
    );
  }
}
