// Pure domain entities for caretakers.
// No Flutter, no JSON, no Dio.

import 'relationship_entity.dart';

class CaretakerUserEntity {
  const CaretakerUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String phone;
  final String? profilePicture;
}

class CaretakerEntity {
  const CaretakerEntity({
    required this.id,
    required this.caretakerUser,
    required this.relationship,
    required this.permissions,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final CaretakerUserEntity caretakerUser;
  final CaretakerRelationshipEntity relationship;
  final List<String> permissions;
  final String createdAt;
  final String? notes;

  bool hasPermission(String permission) => permissions.contains(permission);
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
