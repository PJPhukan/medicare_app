import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  const CommunityRepositoryImpl(this._ds);

  final CommunityRemoteDataSource _ds;

  @override
  Future<List<PostEntity>> getPosts({int page = 1, int limit = 20}) async {
    final List<PostEntity> list =
        await _ds.getPosts(page: page, limit: limit);
    return list;
  }

  @override
  Future<PostEntity> createPost({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final PostEntity post =
        await _ds.createPost(title: title, body: body, imageUrl: imageUrl);
    return post;
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String body,
  }) async {
    final CommentEntity comment =
        await _ds.addComment(postId: postId, body: body);
    return comment;
  }

  @override
  Future<void> likePost(String postId) => _ds.likePost(postId);
}
