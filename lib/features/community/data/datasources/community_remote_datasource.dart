import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class CommunityRemoteDataSource {
  const CommunityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/community/posts',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = data['items'] as List<dynamic>;
    return list
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Post> createPost({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.users}/community/posts',
      data: {
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );
    return Post.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<Comment> addComment({
    required String postId,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.users}/community/posts/$postId/comments',
      data: {'body': body},
    );
    return Comment.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> likePost(String postId) async {
    await _dio.post<void>(
      '${ApiConstants.users}/community/posts/$postId/like',
    );
  }
}
