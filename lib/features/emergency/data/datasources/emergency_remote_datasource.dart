import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_profile_model.dart';

class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource(this._dio);

  final Dio _dio;

  /// Null when the user has no emergency profile yet.
  Future<EmergencyProfile?> getProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.emergencyProfile);
    final data = res.data?['data'] as Map<String, dynamic>?;
    return data == null ? null : EmergencyProfile.fromJson(data);
  }

  /// `null` for [bloodGroup]/[notes] clears the field; `null` for the list
  /// fields is treated the same as an empty list (clears it). Omitted (not
  /// passed) fields are left unchanged server-side.
  Future<EmergencyProfile> updateProfile({
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medications,
    List<String>? conditions,
    String? notes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.emergencyProfile,
      data: {
        'bloodGroup': bloodGroup,
        'allergies': allergies ?? const <String>[],
        'medications': medications ?? const <String>[],
        'conditions': conditions ?? const <String>[],
        'notes': notes,
      },
    );
    return EmergencyProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
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
    int priority = 0,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.emergencyContacts,
      data: {
        'name': name,
        'phone': phone,
        if (relation != null) 'relation': relation,
        'priority': priority,
      },
    );
    return EmergencyContact.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<EmergencyContact> updateContact({
    required String id,
    String? name,
    String? phone,
    String? relation,
    int? priority,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.emergencyContacts}/$id',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (relation != null) 'relation': relation,
        if (priority != null) 'priority': priority,
      },
    );
    return EmergencyContact.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteContact(String id) async {
    await _dio.delete<void>('${ApiConstants.emergencyContacts}/$id');
  }

  /// Logs the SOS on the backend, which also fans out FCM pushes to any
  /// emergency contacts who are registered Curalee users.
  /// Returns the created SosLog (id, status, notifiedContacts, ...).
  Future<Map<String, dynamic>> triggerSos({
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.emergencySos,
      data: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationName != null) 'locationName': locationName,
      },
    );
    return (res.data?['data'] as Map<String, dynamic>?) ?? {};
  }

  /// Marks the SOS cancelled; backend pushes the "false alarm" follow-up.
  Future<void> cancelSos(String sosId) async {
    await _dio.post<void>('${ApiConstants.emergencySos}/$sosId/cancel');
  }
}
