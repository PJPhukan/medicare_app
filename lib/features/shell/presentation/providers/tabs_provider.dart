import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/local_cache.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/tabs_remote_datasource.dart';
import '../../data/models/tab_config_model.dart';

final _tabsDsProvider = Provider<TabsRemoteDataSource>(
  (ref) => TabsRemoteDataSource(
    ref.read(dioProvider),
    ref.read(sharedPreferencesProvider),
  ),
);

/// Cache-first: a returning user's last-known tabs render immediately from
/// local storage while a fresh copy is fetched silently in the background.
/// Only a genuine first-time load (nothing cached yet) waits on the network
/// and surfaces as [AsyncLoading] / [AsyncError] — the shell shows a loading
/// spinner or a retry state for that case instead of any hardcoded default.
class TabsNotifier extends StateNotifier<AsyncValue<List<TabConfigModel>>> {
  TabsNotifier(this._ref)
      : _ds = _ref.read(_tabsDsProvider),
        super(const AsyncLoading()) {
    _load();
    _ref.listen<String?>(authTokenProvider, (prev, next) {
      if (prev != next) _load();
    });
  }

  final Ref _ref;
  final TabsRemoteDataSource _ds;

  Future<void> _load() async {
    final cached = _ds.getCachedTabs();
    if (cached != null) {
      // Show the cached config right away, then refresh quietly.
      state = AsyncData(cached);
      try {
        final fresh = await _ds.getMyTabs();
        state = AsyncData(fresh);
      } catch (_) {
        // Keep showing the cached tabs — a silent background refresh
        // failure shouldn't disturb what's already on screen.
      }
      return;
    }

    // First-time load: nothing cached, so the loading/error state is real
    // and the shell should reflect it instead of masking it with defaults.
    state = const AsyncLoading();
    try {
      final tabs = await _ds.getMyTabs();
      state = AsyncData(tabs);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> retry() => _load();
}

final tabsProvider =
    StateNotifierProvider<TabsNotifier, AsyncValue<List<TabConfigModel>>>(
  (ref) => TabsNotifier(ref),
);

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
