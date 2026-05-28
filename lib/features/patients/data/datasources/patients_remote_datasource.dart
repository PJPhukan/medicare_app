import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/patient_detail_model.dart';
import '../models/patient_model.dart';

class PatientsRemoteDataSource {
  const PatientsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Patient>> getPatients() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.patientProfiles,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientDetail> getPatientDetail(String patientId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.patientProfiles}/$patientId',
    );
    return PatientDetail.fromJson(
        res.data!['data'] as Map<String, dynamic>);
  }
}
