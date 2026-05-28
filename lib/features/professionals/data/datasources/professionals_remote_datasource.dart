import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/professional_category_model.dart';
import '../models/professional_model.dart';

class ProfessionalsRemoteDataSource {
  const ProfessionalsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ProfessionalCategory>> getCategories() async {
    final res = await _dio
        .get<Map<String, dynamic>>(ApiConstants.professionalCategories);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) =>
            ProfessionalCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Professional>> listProfessionals({
    String? categoryId,
    String? search,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.professionals,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (verified != null) 'verified': verified.toString(),
      },
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = data['items'] as List<dynamic>;
    return list
        .map((e) => Professional.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Professional> getProfessional(String id) async {
    final res = await _dio
        .get<Map<String, dynamic>>('${ApiConstants.professionals}/$id');
    return Professional.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
