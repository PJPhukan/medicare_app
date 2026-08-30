// Pure domain entities for caretakers.
// No Flutter, no JSON, no Dio.

/// Mirrors the backend's `PermissionRole` enum (Relationship.granteeRole /
/// CaretakerInvite.granteeRole) — the only two kinds of grantee a patient
/// can link.
enum GranteeRole { caretaker, family }

GranteeRole granteeRoleFromApi(String? value) =>
    value == 'FAMILY' ? GranteeRole.family : GranteeRole.caretaker;

String granteeRoleToApi(GranteeRole role) =>
    role == GranteeRole.family ? 'FAMILY' : 'CARETAKER';

/// A single tab's access grant for one caretaker relationship — mirrors the
/// backend TabGrant row (op* flags gated by what the tab's TabConfig allows
/// at all; see `requireGrantableTab` server-side).
class TabGrantEntity {
  const TabGrantEntity({
    required this.tabId,
    required this.tabSlug,
    required this.tabLabel,
    required this.granted,
    required this.opView,
    required this.opAdd,
    required this.opEdit,
    required this.opDelete,
    required this.opShare,
  });

  final String tabId;
  final String tabSlug;
  final String tabLabel;

  /// `state == GRANTED` on the backend row (a `REVOKED` grant reads as no
  /// access regardless of the op flags underneath it).
  final bool granted;
  final bool opView;
  final bool opAdd;
  final bool opEdit;
  final bool opDelete;
  final bool opShare;

  bool get hasAccess => granted && opView;
}

/// A caretaker/family member with real (ACTIVE) access — backed by a
/// Relationship row.
class CaretakerEntity {
  const CaretakerEntity({
    required this.relationshipId,
    required this.granteeId,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.tabGrants = const [],
  });

  final String relationshipId;
  final String granteeId;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final GranteeRole role;
  final DateTime createdAt;
  final List<TabGrantEntity> tabGrants;

  String get contact => phone ?? email ?? '';
}

/// A caretaker invite that hasn't been accepted yet — the invitee's
/// phone/email hasn't registered, so no Relationship exists (CaretakerInvite
/// row on the backend).
class PendingCaretakerInviteEntity {
  const PendingCaretakerInviteEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final GranteeRole role;
  final DateTime createdAt;

  String get contact => phone ?? email ?? '';
}

/// Outcome of an invite that may target several patients at once — some may
/// resolve immediately (contact already registered), others may sit pending.
class InviteCaretakerResult {
  const InviteCaretakerResult({required this.addedCount, required this.pendingCount});

  final int addedCount;
  final int pendingCount;

  int get total => addedCount + pendingCount;
}

/// A patient the current user may invite further caretakers for: themselves,
/// or anyone who's already granted them ACTIVE caretaker/family access.
class ManageablePatientEntity {
  const ManageablePatientEntity({
    required this.id,
    required this.name,
    required this.isSelf,
  });

  final String id;
  final String name;
  final bool isSelf;
}

/// A tab the patient can grant a caretaker access to — a `GRANTABLE`
/// TabConfig. `allow*` are the admin-configured ceiling: an op the tab
/// doesn't allow can't be granted regardless of what the patient toggles.
class GrantableTabEntity {
  const GrantableTabEntity({
    required this.id,
    required this.slug,
    required this.label,
    required this.tabType,
    required this.allowView,
    required this.allowAdd,
    required this.allowEdit,
    required this.allowDelete,
    required this.allowShare,
  });

  final String id;
  final String slug;
  final String label;
  final String tabType;
  final bool allowView;
  final bool allowAdd;
  final bool allowEdit;
  final bool allowDelete;
  final bool allowShare;
}
