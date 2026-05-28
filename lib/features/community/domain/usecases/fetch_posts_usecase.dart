import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class FetchPostsUseCase {
  const FetchPostsUseCase(this._repo);

  final CommunityRepository _repo;

  Future<List<PostEntity>> call({int page = 1, int limit = 20}) =>
      _repo.getPosts(page: page, limit: limit);
}
