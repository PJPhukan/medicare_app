import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/tabs_remote_datasource.dart';
import '../../data/models/tab_config_model.dart';

final _tabsDsProvider = Provider<TabsRemoteDataSource>(
  (ref) => TabsRemoteDataSource(ref.read(dioProvider)),
);

final tabsProvider = FutureProvider<List<TabConfigModel>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(_tabsDsProvider).getMyTabs();
});

/// Per-operation permissions for a single tab.
class TabPerms {
  const TabPerms({
    this.view = true,
    this.add = true,
    this.edit = true,
    this.delete = true,
    this.share = true,
  });

  final bool view, add, edit, delete, share;

  /// Default while tabs are loading / on error / slug not found — permissive so
  /// a transient state never blocks the user. An explicit allowX:false from the
  /// backend (when the slug is present) IS respected.
  static const all = TabPerms();
}

/// Resolves a tab's per-operation permissions by slug (e.g. 'vitals').
/// Screens use this to gate add/edit/delete/share actions:
///   final canAdd = ref.watch(tabPermissionsProvider('vitals')).add;
final tabPermissionsProvider = Provider.family<TabPerms, String>((ref, slug) {
  return ref.watch(tabsProvider).maybeWhen(
        data: (tabs) {
          for (final t in tabs) {
            if (t.slug == slug) {
              return TabPerms(
                view: t.allowView,
                add: t.allowAdd,
                edit: t.allowEdit,
                delete: t.allowDelete,
                share: t.allowShare,
              );
            }
          }
          return TabPerms.all; // slug not in list → don't block
        },
        orElse: () => TabPerms.all, // loading / error → don't block
      );
});
