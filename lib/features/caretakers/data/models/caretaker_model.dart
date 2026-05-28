import '../../domain/entities/caretaker_entity.dart';
import 'relationship_model.dart';

class CaretakerUser extends CaretakerUserEntity {
  const CaretakerUser({
    required super.id,
    required super.name,
    required super.phone,
    super.profilePicture,
  });

  factory CaretakerUser.fromJson(Map<String, dynamic> json) => CaretakerUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
      );
}

class Caretaker extends CaretakerEntity {
  const Caretaker({
    required super.id,
    required CaretakerUser caretakerUser,
    required CaretakerRelationship relationship,
    required super.permissions,
    required super.createdAt,
    super.notes,
  }) : super(
          caretakerUser: caretakerUser,
          relationship: relationship,
        );

  @override
  CaretakerUser get caretakerUser => super.caretakerUser as CaretakerUser;

  @override
  CaretakerRelationship get relationship =>
      super.relationship as CaretakerRelationship;

  factory Caretaker.fromJson(Map<String, dynamic> json) => Caretaker(
        id: json['id'] as String,
        caretakerUser: CaretakerUser.fromJson(
          json['caretakerUser'] as Map<String, dynamic>,
        ),
        relationship: CaretakerRelationship.fromJson(
          json['relationship'] as Map<String, dynamic>,
        ),
        permissions:
            (json['permissions'] as List<dynamic>? ?? []).cast<String>(),
        createdAt: json['createdAt'] as String,
        notes: json['notes'] as String?,
      );
}
