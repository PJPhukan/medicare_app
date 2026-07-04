import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/medicine_model.dart';

class MedicinesRemoteDataSource {
  const MedicinesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<UserMedicine>> getMyMedicines() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.myMedicines);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(UserMedicine.fromJson)
        .toList();
  }

  Future<List<CatalogMedicine>> searchCatalog(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.medicinesCatalog,
      queryParameters: query.isNotEmpty ? {'search': query} : null,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => CatalogMedicine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserMedicine> addPersonalMedicine({
    required String medicineId,
    String? customName,
    String? patientProfileId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.myMedicines,
      data: {
        'medicineId': medicineId,
        if (customName != null) 'customName': customName,
        if (patientProfileId != null) 'patientProfileId': patientProfileId,
      },
    );
    return UserMedicine.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteMedicine(String id) async {
    await _dio.delete<void>('${ApiConstants.myMedicines}/$id');
  }
}
