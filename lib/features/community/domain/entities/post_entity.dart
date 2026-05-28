// Pure domain entities for community posts.
// No Flutter, no JSON, no Dio.

import 'comment_entity.dart';

class PostAuthorEntity {
  const PostAuthorEntity({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String? profilePicture;
}

class PostEntity {
  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.comments,
    this.imageUrl,
    this.updatedAt,
    this.isLikedByMe = false,
  });

  final String id;
  final String title;
  final String body;
  final String createdAt;
  final String? updatedAt;
  final String? imageUrl;
  final PostAuthorEntity author;
  final int likesCount;
  final int commentsCount;
  final List<CommentEntity> comments;
  final bool isLikedByMe;

  DateTime get createdAtDate => DateTime.parse(createdAt);
  bool get hasImage => imageUrl != null;
}
