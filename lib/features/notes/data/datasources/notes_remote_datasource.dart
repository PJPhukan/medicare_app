import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/note_model.dart';

class NotesRemoteDataSource {
  const NotesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Note>> getNotes() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/notes',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Note> createNote({
    required String title,
    required String body,
    String? color,
    List<String> tags = const [],
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.users}/notes',
      data: {
        'title': title,
        'body': body,
        if (color != null) 'color': color,
        'tags': tags,
      },
    );
    return Note.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<Note> updateNote({
    required String id,
    String? title,
    String? body,
    String? color,
    List<String>? tags,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.users}/notes/$id',
      data: {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (color != null) 'color': color,
        if (tags != null) 'tags': tags,
      },
    );
    return Note.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteNote(String id) async {
    await _dio.delete<void>('${ApiConstants.users}/notes/$id');
  }
}
