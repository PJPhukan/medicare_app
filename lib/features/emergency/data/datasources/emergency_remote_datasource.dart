import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/emergency_contact_model.dart';

class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<EmergencyContact>> getContacts() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.emergencyContacts,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.emergencyContacts,
      data: {
        'name': name,
        'phone': phone,
        'isPrimary': isPrimary,
        if (relationship != null) 'relationship': relationship,
      },
    );
    return EmergencyContact.fromJson(
        res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteContact(String id) async {
    await _dio.delete<void>('${ApiConstants.emergencyContacts}/$id');
  }
}
