import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/patients_remote_datasource.dart';
import '../../data/repositories/patients_repository_impl.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patients_repository.dart';

final _patientsDsProvider = Provider<PatientsRemoteDataSource>(
  (ref) => PatientsRemoteDataSource(ref.read(dioProvider)),
);

final patientsRepositoryProvider = Provider<PatientsRepository>(
  (ref) => PatientsRepositoryImpl(ref.read(_patientsDsProvider)),
);

/// The patient profiles this user owns — everyone they act as caretaker for.
///
/// Used by any flow that has to ask "who is this for": the add-medicine
/// wizard, and anything else that writes a `patientProfileId`. An empty list
/// is a normal state (most users have no patients), not an error.
final patientProfilesProvider =
    FutureProvider.autoDispose<List<PatientEntity>>((ref) {
  ref.watch(authTokenProvider);
  return ref.read(patientsRepositoryProvider).getPatients();
});
