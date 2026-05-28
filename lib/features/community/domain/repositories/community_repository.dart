import '../entities/comment_entity.dart';
import '../entities/post_entity.dart';

abstract interface class CommunityRepository {
  Future<List<PostEntity>> getPosts({int page, int limit});
  Future<PostEntity> createPost({
    required String title,
    required String body,
    String? imageUrl,
  });
  Future<CommentEntity> addComment({
    required String postId,
    required String body,
  });
  Future<void> likePost(String postId);
}
