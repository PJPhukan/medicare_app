import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._ds);

  final ProfileRemoteDataSource _ds;

  @override
  Future<ProfileEntity> getProfile() async {
    final ProfileEntity profile = await _ds.getProfile();
    return profile;
  }

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> data) async {
    final ProfileEntity profile = await _ds.updateProfile(data);
    return profile;
  }

  @override
  Future<ProfileEntity> uploadAvatar(String filePath) async {
    final ProfileEntity profile = await _ds.uploadAvatar(filePath);
    return profile;
  }
}
