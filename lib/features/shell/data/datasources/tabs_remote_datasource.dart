import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/tab_config_model.dart';

class TabsRemoteDataSource {
  const TabsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TabConfigModel>> getMyTabs() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.myTabs);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => TabConfigModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
