import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/caretaker_model.dart';

class CaretakersRemoteDataSource {
  const CaretakersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Caretaker>> getCaretakers() async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiConstants.myCaretakers);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Caretaker.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> inviteCaretaker({
    required String phone,
    required String relationshipId,
    required List<String> permissions,
  }) async {
    await _dio.post<void>(
      ApiConstants.myCaretakers,
      data: {
        'phone': phone,
        'relationshipId': relationshipId,
        'permissions': permissions,
      },
    );
  }

  Future<void> removeCaretaker(String id) async {
    await _dio.delete<void>('${ApiConstants.myCaretakers}/$id');
  }
}
