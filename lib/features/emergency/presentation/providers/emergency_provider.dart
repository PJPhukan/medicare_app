import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/emergency_remote_datasource.dart';
import '../../data/repositories/emergency_repository_impl.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/entities/emergency_profile_entity.dart';
import '../../domain/usecases/fetch_profile_usecase.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/delete_contact_usecase.dart';
import '../../domain/usecases/fetch_contacts_usecase.dart';
import '../../domain/usecases/update_contact_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
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
    this.profile,
    this.isLoading = false,
    this.error,
  });

  final List<EmergencyContactEntity> contacts;
  final EmergencyProfileEntity? profile;
  final bool isLoading;
  final String? error;

  _EmergencyState copyWith({
    List<EmergencyContactEntity>? contacts,
    EmergencyProfileEntity? profile,
    bool? isLoading,
    String? error,
  }) =>
      _EmergencyState(
        contacts: contacts ?? this.contacts,
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _EmergencyNotifier extends StateNotifier<_EmergencyState> {
  _EmergencyNotifier(this._fetch, this._fetchProfile, this._add, this._update,
      this._delete, this._updateProfile)
      : super(const _EmergencyState()) {
    load();
  }

  final FetchContactsUseCase _fetch;
  final FetchProfileUseCase _fetchProfile;
  final AddContactUseCase _add;
  final UpdateContactUseCase _update;
  final DeleteContactUseCase _delete;
  final UpdateProfileUseCase _updateProfile;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(contacts: _sorted(list), isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    // Profile is display-only enrichment — its failure must not block contacts.
    try {
      final profile = await _fetchProfile();
      if (!mounted || profile == null) return;
      state = state.copyWith(profile: profile);
    } catch (e) {
      AppLogger.e('Emergency profile fetch failed', tag: 'Emergency', error: e);
    }
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
    int priority = 0,
  }) async {
    AppLogger.i('Emergency contact add', tag: 'Emergency');
    try {
      final contact = await _add(
        name: name,
        phone: phone,
        relationship: relationship,
        isPrimary: isPrimary,
        priority: priority,
      );
      state = state.copyWith(contacts: _sorted([...state.contacts, contact]));
      AppLogger.i('Emergency contact added ✓ → id:${contact.id}', tag: 'Emergency');
    } on Exception catch (e, s) {
      AppLogger.e('Emergency contact add failed', tag: 'Emergency', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> updateContact({
    required String id,
    String? name,
    String? phone,
    String? relationship,
    int? priority,
  }) async {
    AppLogger.i('Emergency contact update → id:$id', tag: 'Emergency');
    try {
      final updated = await _update(
        id: id,
        name: name,
        phone: phone,
        relationship: relationship,
        priority: priority,
      );
      state = state.copyWith(
        contacts: _sorted([
          for (final c in state.contacts) c.id == id ? updated : c,
        ]),
      );
      AppLogger.i('Emergency contact updated ✓', tag: 'Emergency');
    } on Exception catch (e, s) {
      AppLogger.e('Emergency contact update failed', tag: 'Emergency', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? bloodGroup,
    List<String> allergies = const [],
    List<String> medications = const [],
    List<String> conditions = const [],
    String? notes,
  }) async {
    AppLogger.i('Emergency profile update', tag: 'Emergency');
    try {
      final updated = await _updateProfile(
        bloodGroup: bloodGroup,
        allergies: allergies,
        medications: medications,
        conditions: conditions,
        notes: notes,
      );
      if (!mounted) return;
      state = state.copyWith(profile: updated);
      AppLogger.i('Emergency profile updated ✓', tag: 'Emergency');
    } catch (e, s) {
      AppLogger.e('Emergency profile update failed', tag: 'Emergency', error: e, stack: s);
      rethrow;
    }
  }

  static List<EmergencyContactEntity> _sorted(List<EmergencyContactEntity> list) =>
      [...list]..sort((a, b) => a.priority.compareTo(b.priority));

  Future<void> deleteContact(String id) async {
    AppLogger.i('Emergency contact delete → id:$id', tag: 'Emergency');
    final prev = state.contacts;
    state = state.copyWith(contacts: prev.where((c) => c.id != id).toList());
    try {
      await _delete(id);
      AppLogger.i('Emergency contact deleted ✓', tag: 'Emergency');
    } catch (e, s) {
      AppLogger.e('Emergency contact delete failed', tag: 'Emergency', error: e, stack: s as StackTrace?);
            if (!mounted) return;
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
    FetchProfileUseCase(repo),
    AddContactUseCase(repo),
    UpdateContactUseCase(repo),
    DeleteContactUseCase(repo),
    UpdateProfileUseCase(repo),
  );
});
