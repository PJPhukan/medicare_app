import '../entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile(Map<String, dynamic> data);
  Future<ProfileEntity> uploadAvatar(String filePath);
}
