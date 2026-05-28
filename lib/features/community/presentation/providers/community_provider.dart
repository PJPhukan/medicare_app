import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/fetch_posts_usecase.dart';
import '../../domain/usecases/like_post_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _communityDsProvider = Provider<CommunityRemoteDataSource>(
  (ref) => CommunityRemoteDataSource(ref.read(dioProvider)),
);

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepositoryImpl(ref.read(_communityDsProvider)),
);

final createPostProvider = Provider<CreatePostUseCase>((ref) {
  ref.watch(authTokenProvider);
  return CreatePostUseCase(ref.read(communityRepositoryProvider));
});

class _CommunityState {
  const _CommunityState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PostEntity> posts;
  final bool isLoading;
  final String? error;

  _CommunityState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    String? error,
  }) =>
      _CommunityState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _CommunityNotifier extends StateNotifier<_CommunityState> {
  _CommunityNotifier(this._fetch, this._like) : super(const _CommunityState()) {
    load();
  }

  final FetchPostsUseCase _fetch;
  final LikePostUseCase _like;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(posts: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> likePost(String postId) async {
    AppLogger.i('Post like toggle → id:$postId', tag: 'Community');
    final prev = state.posts;
    state = state.copyWith(
      posts: prev.map((p) {
        if (p.id != postId) return p;
        return PostEntity(
          id: p.id,
          title: p.title,
          body: p.body,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
          imageUrl: p.imageUrl,
          author: p.author,
          likesCount: p.isLikedByMe ? p.likesCount - 1 : p.likesCount + 1,
          commentsCount: p.commentsCount,
          comments: p.comments,
          isLikedByMe: !p.isLikedByMe,
        );
      }).toList(),
    );
    try {
      await _like(postId);
      AppLogger.i('Post like toggled ✓', tag: 'Community');
    } catch (e, s) {
      AppLogger.e('Post like failed', tag: 'Community', error: e, stack: s);
      state = state.copyWith(posts: prev, error: e.toString());
    }
  }
}

final communityProvider =
    StateNotifierProvider<_CommunityNotifier, _CommunityState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(communityRepositoryProvider);
  return _CommunityNotifier(
    FetchPostsUseCase(repo),
    LikePostUseCase(repo),
  );
});
