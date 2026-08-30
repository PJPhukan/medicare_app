import '../../domain/entities/caretaker_entity.dart';

class ManageablePatientModel extends ManageablePatientEntity {
  const ManageablePatientModel({
    required super.id,
    required super.name,
    required super.isSelf,
  });

  // GET /api/patients/manageable → patient.service.ts listManageablePatients:
  // [{ id, name, self }, ...] — first entry is always the caller themselves.
  factory ManageablePatientModel.fromJson(Map<String, dynamic> json) => ManageablePatientModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Unknown',
        isSelf: json['self'] as bool? ?? false,
      );
}
