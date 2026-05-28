// Pure domain entity for community post comments.
// No Flutter, no JSON, no Dio.

class CommentAuthorEntity {
  const CommentAuthorEntity({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String? profilePicture;
}

class CommentEntity {
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.body,
    required this.createdAt,
    required this.author,
    this.updatedAt,
  });

  final String id;
  final String postId;
  final String body;
  final String createdAt;
  final String? updatedAt;
  final CommentAuthorEntity author;

  DateTime get createdAtDate => DateTime.parse(createdAt);
  bool get isEdited => updatedAt != null;
}
