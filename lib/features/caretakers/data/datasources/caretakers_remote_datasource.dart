import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../models/caretaker_model.dart';
import '../models/pending_caretaker_invite_model.dart';
import '../models/grantable_tab_model.dart';
import '../models/manageable_patient_model.dart';

class CaretakersRemoteDataSource {
  const CaretakersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CaretakerModel>> getCaretakers() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.myCaretakers);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => CaretakerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PendingCaretakerInviteModel>> getPendingInvites() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.caretakerInvites);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => PendingCaretakerInviteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Only GRANTABLE tabs are meaningful here — CORE/DEFAULT tabs are already
  // visible to any linked user without an explicit grant (see the backend's
  // getResolvedPermissionsForPatient hierarchy), and ROLE_ONLY tabs aren't
  // patient-grantable at all.
  Future<List<GrantableTabModel>> getGrantableTabs() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.myTabs,
      queryParameters: {'platform': 'APP'},
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => GrantableTabModel.fromJson(e as Map<String, dynamic>))
        .where((t) => t.tabType == 'GRANTABLE')
        .toList();
  }

  Future<List<ManageablePatientModel>> getManageablePatients() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.manageablePatients);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ManageablePatientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// One invite can target several patients at once (e.g. the same relative
  /// added as caretaker for two parents in one go) — each resolves
  /// independently to either immediate access or a pending invite.
  Future<InviteCaretakerResult> inviteCaretaker({
    required String name,
    String? phone,
    String? email,
    required GranteeRole role,
    required List<String> patientIds,
    DateTime? expiresAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.myCaretakers,
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'role': granteeRoleToApi(role),
        'patientIds': patientIds,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      },
    );
    final results = (res.data?['data'] as List<dynamic>?) ?? [];
    final addedCount = results.where((r) => (r as Map<String, dynamic>)['pending'] == false).length;
    return InviteCaretakerResult(addedCount: addedCount, pendingCount: results.length - addedCount);
  }

  Future<void> cancelInvite(String inviteId) async {
    await _dio.delete<void>(ApiConstants.cancelCaretakerInvite(inviteId));
  }

  Future<void> revokeCaretaker(String relationshipId) async {
    await _dio.delete<void>(ApiConstants.revokeCaretaker(relationshipId));
  }

  Future<void> saveTabGrant({
    required String relationshipId,
    required String tabId,
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  }) async {
    await _dio.post<void>(
      ApiConstants.permissionTabGrants,
      data: {
        'relationshipId': relationshipId,
        'tabId': tabId,
        'opView': opView,
        'opAdd': opAdd,
        'opEdit': opEdit,
        'opDelete': opDelete,
        'opShare': opShare,
      },
    );
  }
}
