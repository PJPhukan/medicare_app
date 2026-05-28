import '../../domain/entities/post_entity.dart';
import 'comment_model.dart';

class PostAuthor extends PostAuthorEntity {
  const PostAuthor({
    required super.id,
    required super.name,
    super.profilePicture,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
      );
}

class Post extends PostEntity {
  const Post({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    required PostAuthor author,
    required super.likesCount,
    required super.commentsCount,
    required List<Comment> comments,
    super.imageUrl,
    super.updatedAt,
    super.isLikedByMe,
  }) : super(author: author, comments: comments);

  @override
  PostAuthor get author => super.author as PostAuthor;

  @override
  List<Comment> get comments => super.comments.cast<Comment>();

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String?,
        imageUrl: json['imageUrl'] as String?,
        likesCount: json['likesCount'] as int? ?? 0,
        commentsCount: json['commentsCount'] as int? ?? 0,
        isLikedByMe: json['isLikedByMe'] as bool? ?? false,
        author: PostAuthor.fromJson(
          json['author'] as Map<String, dynamic>,
        ),
        comments: (json['comments'] as List<dynamic>? ?? [])
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
