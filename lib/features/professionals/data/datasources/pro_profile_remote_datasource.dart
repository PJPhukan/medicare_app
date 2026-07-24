import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pro_profile_model.dart';
import '../models/service_area_model.dart';

class ProProfileRemoteDataSource {
  const ProProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProProfile> getMyProProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.myProfProfile,
    );
    return ProProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<ProProfile> createProProfile(Map<String, dynamic> data) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.profProfile,
      data: data,
    );
    return ProProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<ProProfile> updateProProfile(Map<String, dynamic> data) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.profProfile,
      data: data,
    );
    return ProProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<ServiceArea> addServiceArea({
    required String city,
    required String state,
    required String country,
    String? pincode,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.profServiceAreas,
      data: {
        'city': city,
        'state': state,
        'country': country,
        if (pincode != null) 'pincode': pincode,
      },
    );
    return ServiceArea.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> removeServiceArea(String serviceAreaId) async {
    await _dio.delete<void>('${ApiConstants.profServiceAreas}/$serviceAreaId');
  }

  Future<void> requestNewArea({
    required String name,
    required String pincodes,
    required String state,
    required String district,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/professionals/areas/request',
      data: {
        'name': name,
        'pincodes': pincodes,
        'state': state,
        'district': district,
      },
    );
  }
}
