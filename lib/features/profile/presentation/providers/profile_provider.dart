import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _profileDsProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.read(dioProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(_profileDsProvider)),
);

final updateProfileProvider = Provider<UpdateProfileUseCase>((ref) {
  ref.watch(authTokenProvider);
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
});
