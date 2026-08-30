// Pure domain entity for patient profiles — the dependents a caretaker
// manages (added via addPatient, possibly without their own login).
// No Flutter, no JSON, no Dio.

class PatientEntity {
  const PatientEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.relation,
    this.selfUserId,
    this.invitePhone,
    this.inviteEmail,
    this.selfUserName,
    this.selfUserPhone,
    this.selfUserEmail,
    this.avatarUrl,
    this.dateOfBirth,
    this.bloodGroup,
  });

  final String id;
  final String name;
  final String createdAt;

  /// Free-form relationship label the owner chose, e.g. "Mother", "Son".
  final String? relation;

  /// Set once the invited contact registers and links to this profile —
  /// from then on this patient has their own account and can be reached
  /// directly instead of only through the owner's proxy.
  final String? selfUserId;

  /// Contact the owner supplied when creating this profile — cleared once
  /// [selfUserId] links, so these and the selfUser* fields are mutually
  /// exclusive in practice.
  final String? invitePhone;
  final String? inviteEmail;

  final String? selfUserName;
  final String? selfUserPhone;
  final String? selfUserEmail;
  final String? avatarUrl;

  final String? dateOfBirth;
  final String? bloodGroup;

  /// True once the invited contact has registered and linked to this
  /// profile. Until then it's a pending, owner-managed placeholder.
  bool get isJoined => selfUserId != null;

  /// Best contact string to show — the linked account's, falling back to
  /// whatever was used to invite them.
  String? get contact => selfUserPhone ?? selfUserEmail ?? invitePhone ?? inviteEmail;

  DateTime get createdAtDate => DateTime.parse(createdAt);

  int? get age {
    if (dateOfBirth == null) return null;
    final dob = DateTime.tryParse(dateOfBirth!);
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
