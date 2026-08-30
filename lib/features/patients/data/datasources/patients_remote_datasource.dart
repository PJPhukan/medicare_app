import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/patient_model.dart';
import '../models/patient_note_model.dart';

class PatientsRemoteDataSource {
  const PatientsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Patient>> getPatients() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.patientProfiles,
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Patient> addPatient({
    required String name,
    String? phone,
    String? email,
    String? relation,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.addPatient,
      data: {
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (relation != null && relation.isNotEmpty) 'relation': relation,
      },
    );
    return Patient.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> removePatient(String profileId) async {
    await _dio.delete(ApiConstants.removePatient(profileId));
  }

  Future<List<PatientNote>> getNotes(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.patientNotes(profileId),
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => PatientNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientNote> addNote(String profileId, String note) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.patientNotes(profileId),
      data: {'note': note},
    );
    return PatientNote.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
