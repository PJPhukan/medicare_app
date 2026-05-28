import '../entities/patient_detail_entity.dart';
import '../entities/patient_entity.dart';

abstract interface class PatientsRepository {
  Future<List<PatientEntity>> getPatients();
  Future<PatientDetailEntity> getPatientDetail(String patientId);
}
