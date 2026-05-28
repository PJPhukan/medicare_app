import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/emergency_remote_datasource.dart';
import '../../data/repositories/emergency_repository_impl.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/delete_contact_usecase.dart';
import '../../domain/usecases/fetch_contacts_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _emergencyDsProvider = Provider<EmergencyRemoteDataSource>(
  (ref) => EmergencyRemoteDataSource(ref.read(dioProvider)),
);

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => EmergencyRepositoryImpl(ref.read(_emergencyDsProvider)),
);

class _EmergencyState {
  const _EmergencyState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<EmergencyContactEntity> contacts;
  final bool isLoading;
  final String? error;

  _EmergencyState copyWith({
    List<EmergencyContactEntity>? contacts,
    bool? isLoading,
    String? error,
  }) =>
      _EmergencyState(
        contacts: contacts ?? this.contacts,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _EmergencyNotifier extends StateNotifier<_EmergencyState> {
  _EmergencyNotifier(this._fetch, this._add, this._delete)
      : super(const _EmergencyState()) {
    load();
  }

  final FetchContactsUseCase _fetch;
  final AddContactUseCase _add;
  final DeleteContactUseCase _delete;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(contacts: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    AppLogger.i('Emergency contact add', tag: 'Emergency');
    try {
      final contact = await _add(
        name: name,
        phone: phone,
        relationship: relationship,
        isPrimary: isPrimary,
      );
      state = state.copyWith(contacts: [...state.contacts, contact]);
      AppLogger.i('Emergency contact added ✓ → id:${contact.id}', tag: 'Emergency');
    } on Exception catch (e, s) {
      AppLogger.e('Emergency contact add failed', tag: 'Emergency', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    AppLogger.i('Emergency contact delete → id:$id', tag: 'Emergency');
    final prev = state.contacts;
    state = state.copyWith(contacts: prev.where((c) => c.id != id).toList());
    try {
      await _delete(id);
      AppLogger.i('Emergency contact deleted ✓', tag: 'Emergency');
    } catch (e, s) {
      AppLogger.e('Emergency contact delete failed', tag: 'Emergency', error: e, stack: s as StackTrace?);
      state = state.copyWith(contacts: prev, error: e.toString());
    }
  }
}

final emergencyProvider =
    StateNotifierProvider<_EmergencyNotifier, _EmergencyState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(emergencyRepositoryProvider);
  return _EmergencyNotifier(
    FetchContactsUseCase(repo),
    AddContactUseCase(repo),
    DeleteContactUseCase(repo),
  );
});
