import '../repositories/community_repository.dart';

class LikePostUseCase {
  const LikePostUseCase(this._repo);

  final CommunityRepository _repo;

  Future<void> call(String postId) => _repo.likePost(postId);
}
