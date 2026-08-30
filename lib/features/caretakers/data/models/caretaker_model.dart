import '../../domain/entities/caretaker_entity.dart';

class TabGrantModel extends TabGrantEntity {
  const TabGrantModel({
    required super.tabId,
    required super.tabSlug,
    required super.tabLabel,
    required super.granted,
    required super.opView,
    required super.opAdd,
    required super.opEdit,
    required super.opDelete,
    required super.opShare,
  });

  // patient.repository.ts findCaretakersOfPatient: { tabId, state, op*, tab: { id, slug, label } }
  factory TabGrantModel.fromJson(Map<String, dynamic> json) {
    final tab = json['tab'] as Map<String, dynamic>?;
    return TabGrantModel(
      tabId: json['tabId'] as String? ?? tab?['id'] as String? ?? '',
      tabSlug: tab?['slug'] as String? ?? '',
      tabLabel: tab?['label'] as String? ?? '',
      granted: (json['state'] as String? ?? 'GRANTED') == 'GRANTED',
      opView: json['opView'] as bool? ?? false,
      opAdd: json['opAdd'] as bool? ?? false,
      opEdit: json['opEdit'] as bool? ?? false,
      opDelete: json['opDelete'] as bool? ?? false,
      opShare: json['opShare'] as bool? ?? false,
    );
  }
}

class CaretakerModel extends CaretakerEntity {
  const CaretakerModel({
    required super.relationshipId,
    required super.granteeId,
    required super.name,
    super.phone,
    super.email,
    super.avatarUrl,
    required super.role,
    required super.createdAt,
    super.tabGrants,
  });

  // GET /api/patients/my-caretakers → patient.repository.ts findCaretakersOfPatient:
  // { id, status, granteeRole, createdAt, grantee: {...}, tabGrants: [...] }
  factory CaretakerModel.fromJson(Map<String, dynamic> json) {
    final grantee = json['grantee'] as Map<String, dynamic>? ?? const {};
    final grants = (json['tabGrants'] as List<dynamic>? ?? [])
        .map((e) => TabGrantModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CaretakerModel(
      relationshipId: json['id'] as String,
      granteeId: grantee['id'] as String? ?? '',
      name: grantee['name'] as String? ?? 'Unknown',
      phone: grantee['phone'] as String?,
      email: grantee['email'] as String?,
      avatarUrl: grantee['avatarUrl'] as String?,
      role: granteeRoleFromApi(json['granteeRole'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      tabGrants: grants,
    );
  }
}
