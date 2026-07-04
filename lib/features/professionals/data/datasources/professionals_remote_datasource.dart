import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/location_models.dart';
import '../models/professional_category_model.dart';
import '../models/professional_model.dart';

class ProfessionalsRemoteDataSource {
  const ProfessionalsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ProfessionalCategory>> getCategories() async {
    final res = await _dio
        .get<Map<String, dynamic>>(ApiConstants.professionalCategories);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ProfessionalCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit a custom category for admin approval. Returns it (PENDING) so it can
  /// be selected immediately.
  Future<ProfessionalCategory> requestCategory(String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.professionalCategoryRequest,
      data: {'name': name},
    );
    return ProfessionalCategory.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  // General listing (no location filter)
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

  // Location-based listing — returns full paginated response with fallback info
  Future<ProfessionalsLocationPage> listByLocation({
    String? pincode,
    String? areaId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.professionalsByLocation,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (pincode != null) 'pincode': pincode,
        if (areaId != null) 'areaId': areaId,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );

    final data = res.data!['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final areaJson = data['area'];
    final area = areaJson != null
        ? AreaInfo.fromJson(areaJson as Map<String, dynamic>)
        : null;

    final fallbackAreaList = (data['fallbackAreas'] as List? ?? [])
        .map((e) => AreaInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProfessionalsLocationPage(
      items: items,
      total: data['total'] as int? ?? 0,
      page:  data['page']  as int? ?? page,
      pages: data['pages'] as int? ?? 1,
      isFallback:      data['isFallback'] as bool? ?? false,
      area:            area,
      fallbackDistrict: data['fallbackDistrict'] as String?,
      fallbackAreas:   fallbackAreaList,
    );
  }

  Future<Professional> getProfessional(String id) async {
    final res = await _dio
        .get<Map<String, dynamic>>('${ApiConstants.professionals}/$id');
    return Professional.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
