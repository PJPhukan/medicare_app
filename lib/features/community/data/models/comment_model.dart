import '../../domain/entities/comment_entity.dart';

class CommentAuthor extends CommentAuthorEntity {
  const CommentAuthor({
    required super.id,
    required super.name,
    super.profilePicture,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
      );
}

class Comment extends CommentEntity {
  const Comment({
    required super.id,
    required super.postId,
    required super.body,
    required super.createdAt,
    required CommentAuthor author,
    super.updatedAt,
  }) : super(author: author);

  @override
  CommentAuthor get author => super.author as CommentAuthor;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        postId: json['postId'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String?,
        author: CommentAuthor.fromJson(
          json['author'] as Map<String, dynamic>,
        ),
      );
}
