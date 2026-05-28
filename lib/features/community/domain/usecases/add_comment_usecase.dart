import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class AddCommentUseCase {
  const AddCommentUseCase(this._repo);

  final CommunityRepository _repo;

  Future<CommentEntity> call({
    required String postId,
    required String body,
  }) =>
      _repo.addComment(postId: postId, body: body);
}
