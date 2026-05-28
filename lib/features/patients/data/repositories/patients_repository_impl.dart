import '../../domain/entities/patient_detail_entity.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_datasource.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  const PatientsRepositoryImpl(this._ds);

  final PatientsRemoteDataSource _ds;

  @override
  Future<List<PatientEntity>> getPatients() async {
    final List<PatientEntity> list = await _ds.getPatients();
    return list;
  }

  @override
  Future<PatientDetailEntity> getPatientDetail(String patientId) async {
    final PatientDetailEntity detail =
        await _ds.getPatientDetail(patientId);
    return detail;
  }
}
