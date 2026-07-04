import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/emergency_contact_model.dart';

class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> updateProfile({
    String? bloodGroup,
    List<String>? allergies,
    List<String>? conditions,
  }) async {
    await _dio.patch<void>(
      ApiConstants.emergencyProfile,
      data: {
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (allergies != null) 'allergies': allergies,
        if (conditions != null) 'conditions': conditions,
      },
    );
  }

  Future<List<EmergencyContact>> getContacts() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.emergencyContacts);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? relation,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.emergencyContacts,
      data: {
        'name': name,
        'phone': phone,
        if (relation != null) 'relation': relation,
      },
    );
    return EmergencyContact.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteContact(String id) async {
    await _dio.delete<void>('${ApiConstants.emergencyContacts}/$id');
  }
}
