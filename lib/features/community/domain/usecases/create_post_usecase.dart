import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class CreatePostUseCase {
  const CreatePostUseCase(this._repo);

  final CommunityRepository _repo;

  Future<PostEntity> call({
    required String title,
    required String body,
    String? imageUrl,
  }) =>
      _repo.createPost(title: title, body: body, imageUrl: imageUrl);
}
