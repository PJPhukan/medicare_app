import '../../domain/entities/caretaker_entity.dart';

class PendingCaretakerInviteModel extends PendingCaretakerInviteEntity {
  const PendingCaretakerInviteModel({
    required super.id,
    required super.name,
    super.phone,
    super.email,
    required super.role,
    required super.createdAt,
  });

  // GET /api/patients/caretaker-invites → CaretakerInvite rows:
  // { id, granteeRole, inviteeName, invitePhone, inviteEmail, createdAt }
  factory PendingCaretakerInviteModel.fromJson(Map<String, dynamic> json) =>
      PendingCaretakerInviteModel(
        id: json['id'] as String,
        name: json['inviteeName'] as String? ?? 'Unknown',
        phone: json['invitePhone'] as String?,
        email: json['inviteEmail'] as String?,
        role: granteeRoleFromApi(json['granteeRole'] as String?),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
