import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserProfile> getProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.userProfile);
    return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.userProfile,
      data: data,
    );
    return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<UserProfile> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.userAvatar,
      data: formData,
    );
    return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
