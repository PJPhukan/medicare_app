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

  /// One page of the merged medicine + product catalog. Browse mode (empty
  /// [query]) walks the whole catalog A-Z; a search returns the ranked matches.
  Future<CatalogPage> searchCatalog(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.medicinesCatalog,
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'page': page,
        'limit': limit,
      },
    );
    return CatalogPage.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// The catalog serves Medicine and Product rows together, and the endpoint
  /// takes exactly one of `medicineId` / `productId` — sending a product's id
  /// as `medicineId` fails the foreign key and the entry is never created.
  Future<UserMedicine> addPersonalMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    String? patientProfileId,
  }) async {
    assert((medicineId == null) != (productId == null),
        'provide exactly one of medicineId or productId');
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.myMedicines,
      data: {
        if (medicineId != null) 'medicineId': medicineId,
        if (productId != null) 'productId': productId,
        if (customName != null) 'customName': customName,
        if (patientProfileId != null) 'patientProfileId': patientProfileId,
      },
    );
    return UserMedicine.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// Creates the first stock entry, or tops up an existing one.
  /// [minThreshold] is the refill-alert level; null leaves it untouched.
  /// Zero is meaningful (alerts off), so it must be sent when chosen.
  Future<MedicineStock> addStock(
    String userMedicineId, {
    required int quantity,
    String? expiryDate,
    int? minThreshold,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.medicineStock}/$userMedicineId',
      data: {
        'quantity': quantity,
        if (expiryDate != null) 'expiryDate': expiryDate,
        if (minThreshold != null) 'minThreshold': minThreshold,
      },
    );
    return MedicineStock.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// Changes who a PERSONAL medicine is for. Null means "back to me" and is
  /// meaningful, so it is always sent rather than omitted.
  Future<UserMedicine> reassignMedicine(
    String userMedicineId, {
    required String? patientProfileId,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.myMedicines}/$userMedicineId',
      data: {'patientProfileId': patientProfileId},
    );
    return UserMedicine.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// Creates a shared bottle: one master the caller owns, plus a member entry
  /// per patient profile. A different endpoint from a personal add.
  Future<UserMedicine> addSharedMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    required List<String> memberPatientProfileIds,
  }) async {
    assert((medicineId == null) != (productId == null),
        'provide exactly one of medicineId or productId');
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.sharedMedicines,
      data: {
        if (medicineId != null) 'medicineId': medicineId,
        if (productId != null) 'productId': productId,
        if (customName != null) 'customName': customName,
        'memberPatientProfileIds': memberPatientProfileIds,
      },
    );
    return UserMedicine.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// Asks an admin to add a medicine the catalog doesn't carry yet.
  Future<void> requestMedicine({
    required String medicineName,
    String? details,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConstants.medicineRequests,
      data: {
        'medicineName': medicineName,
        if (details != null && details.isNotEmpty) 'details': details,
      },
    );
  }

  Future<void> deleteMedicine(String id) async {
    await _dio.delete<void>('${ApiConstants.myMedicines}/$id');
  }
}
