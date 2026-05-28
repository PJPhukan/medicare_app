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
