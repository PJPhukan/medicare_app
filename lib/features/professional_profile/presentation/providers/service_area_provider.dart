import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../professionals/data/models/location_models.dart';

// ─── Area with pincode count (search result) ──────────────────────────────────

class SelectableArea {
  const SelectableArea({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    this.pincodeCount = 0,
  });

  final String id;
  final String name;
  final String district;
  final String state;
  final int pincodeCount;

  factory SelectableArea.fromJson(Map<String, dynamic> json) => SelectableArea(
        id:       json['id'] as String,
        name:     json['name'] as String,
        district: json['district'] as String,
        state:    json['state'] as String,
        pincodeCount: (json['_count']?['pincodes'] as int?) ?? 0,
      );

  AreaInfo toAreaInfo() =>
      AreaInfo(id: id, name: name, district: district, state: state);
}

// ─── My service area (with optional per-area rate overrides) ──────────────────

class MyArea {
  const MyArea({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    this.hourlyRate,
    this.dailyRate,
    this.monthlyRate,
  });

  final String id;
  final String name;
  final String district;
  final String state;
  final int? hourlyRate;
  final int? dailyRate;
  final int? monthlyRate;

  bool get hasRates => hourlyRate != null || dailyRate != null || monthlyRate != null;

  factory MyArea.fromJson(Map<String, dynamic> json) => MyArea(
        id:          json['id'] as String,
        name:        json['name'] as String,
        district:    json['district'] as String,
        state:       json['state'] as String,
        hourlyRate:  (json['hourlyRate'] as num?)?.toInt(),
        dailyRate:   (json['dailyRate'] as num?)?.toInt(),
        monthlyRate: (json['monthlyRate'] as num?)?.toInt(),
      );
}

// ─── Whole-district coverage (with optional rate overrides) ───────────────────

class MyDistrict {
  const MyDistrict({
    required this.id,
    required this.state,
    required this.district,
    this.hourlyRate,
    this.dailyRate,
    this.monthlyRate,
  });

  final String id;
  final String state;
  final String district;
  final int? hourlyRate;
  final int? dailyRate;
  final int? monthlyRate;

  factory MyDistrict.fromJson(Map<String, dynamic> json) => MyDistrict(
        id:          json['id'] as String,
        state:       json['state'] as String,
        district:    json['district'] as String,
        hourlyRate:  (json['hourlyRate'] as num?)?.toInt(),
        dailyRate:   (json['dailyRate'] as num?)?.toInt(),
        monthlyRate: (json['monthlyRate'] as num?)?.toInt(),
      );
}

// ─── Area request (a locality the pro asked us to add) ────────────────────────

class AreaRequest {
  const AreaRequest({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.status,
    this.adminNotes,
  });

  final String id;
  final String name;
  final String district;
  final String state;
  final String status; // PENDING | APPROVED | REJECTED
  final String? adminNotes;

  factory AreaRequest.fromJson(Map<String, dynamic> json) => AreaRequest(
        id:        json['id'] as String,
        name:      json['name'] as String,
        district:  json['district'] as String,
        state:     json['state'] as String,
        status:    (json['status'] as String?) ?? 'PENDING',
        adminNotes: json['adminNotes'] as String?,
      );
}

// ─── State ────────────────────────────────────────────────────────────────────

class ServiceAreaState {
  const ServiceAreaState({
    this.myAreas = const [],
    this.myDistricts = const [],
    this.searchResults = const [],
    this.myRequests = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.isSaving = false,
    this.error,
  });

  final List<MyArea> myAreas;
  final List<MyDistrict> myDistricts;
  final List<SelectableArea> searchResults;
  final List<AreaRequest> myRequests;
  final bool isLoading;
  final bool isSearching;
  final bool isSaving;
  final String? error;

  bool isSelected(String areaId) => myAreas.any((a) => a.id == areaId);

  ServiceAreaState copyWith({
    List<MyArea>? myAreas,
    List<MyDistrict>? myDistricts,
    List<SelectableArea>? searchResults,
    List<AreaRequest>? myRequests,
    bool? isLoading,
    bool? isSearching,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      ServiceAreaState(
        myAreas:       myAreas       ?? this.myAreas,
        myDistricts:   myDistricts   ?? this.myDistricts,
        searchResults: searchResults ?? this.searchResults,
        myRequests:    myRequests    ?? this.myRequests,
        isLoading:     isLoading     ?? this.isLoading,
        isSearching:   isSearching   ?? this.isSearching,
        isSaving:      isSaving      ?? this.isSaving,
        error:         clearError    ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ServiceAreaNotifier extends StateNotifier<ServiceAreaState> {
  ServiceAreaNotifier(this._ref) : super(const ServiceAreaState()) {
    loadMyAreas();
    loadMyDistricts();
    loadMyRequests();
  }

  final Ref _ref;

  List<MyArea> _parseAreas(dynamic data) =>
      (data as List).map((e) => MyArea.fromJson(e as Map<String, dynamic>)).toList();

  Future<void> loadMyAreas() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(ApiConstants.profMyAreas);
      state = state.copyWith(myAreas: _parseAreas(res.data!['data']), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMyDistricts() async {
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(ApiConstants.profMyDistricts);
      final list = (res.data!['data'] as List)
          .map((e) => MyDistrict.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(myDistricts: list);
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<void> loadMyRequests() async {
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(ApiConstants.profMyAreaRequests);
      final list = (res.data!['data'] as List)
          .map((e) => AreaRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(myRequests: list);
    } catch (_) {
      // Non-fatal: the requests strip just stays empty.
    }
  }

  Future<void> search({String? query, String? pincode}) async {
    if ((query == null || query.trim().length < 2) && pincode == null) {
      state = state.copyWith(searchResults: []);
      return;
    }
    state = state.copyWith(isSearching: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(
        ApiConstants.profAreasSearch,
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
          if (pincode != null) 'pincode': pincode,
        },
      );
      final list = (res.data!['data'] as List)
          .map((e) => SelectableArea.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(searchResults: list, isSearching: false);
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  void clearSearch() => state = state.copyWith(searchResults: []);

  /// Add an area, or update its per-area rate overrides (upsert). Null rates
  /// fall back to the professional's profile-level rate.
  Future<void> addArea(
    SelectableArea area, {
    int? hourlyRate,
    int? dailyRate,
    int? monthlyRate,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.post<Map<String, dynamic>>(
        ApiConstants.profMyAreas,
        data: {
          'areaId': area.id,
          'hourlyRate': hourlyRate,
          'dailyRate': dailyRate,
          'monthlyRate': monthlyRate,
        },
      );
      state = state.copyWith(myAreas: _parseAreas(res.data!['data']), isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  /// Update rates for an area already in the list.
  Future<void> setAreaRates(
    String areaId, {
    int? hourlyRate,
    int? dailyRate,
    int? monthlyRate,
  }) =>
      addArea(
        SelectableArea(id: areaId, name: '', district: '', state: ''),
        hourlyRate: hourlyRate,
        dailyRate: dailyRate,
        monthlyRate: monthlyRate,
      );

  Future<void> removeArea(String areaId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.delete<Map<String, dynamic>>(
        '${ApiConstants.profMyAreas}/$areaId',
      );
      state = state.copyWith(myAreas: _parseAreas(res.data!['data']), isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  /// Add or update whole-district coverage (with optional rate overrides).
  Future<void> addDistrict({
    required String state_,
    required String district,
    int? hourlyRate,
    int? dailyRate,
    int? monthlyRate,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.post<Map<String, dynamic>>(
        ApiConstants.profMyDistricts,
        data: {
          'state': state_,
          'district': district,
          'hourlyRate': hourlyRate,
          'dailyRate': dailyRate,
          'monthlyRate': monthlyRate,
        },
      );
      final list = (res.data!['data'] as List)
          .map((e) => MyDistrict.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(myDistricts: list, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeDistrict(String districtId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.delete<Map<String, dynamic>>(
        '${ApiConstants.profMyDistricts}/$districtId',
      );
      final list = (res.data!['data'] as List)
          .map((e) => MyDistrict.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(myDistricts: list, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> requestNewArea({
    required String name,
    required String pincodes,
    required String stateName,
    required String district,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post<Map<String, dynamic>>(
        ApiConstants.profAreaRequest,
        data: {
          'name': name,
          'pincodes': pincodes,
          'state': stateName,
          'district': district,
        },
      );
      state = state.copyWith(isSaving: false);
      await loadMyRequests(); // surface the new request under "Requested Areas"
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final serviceAreaProvider =
    StateNotifierProvider<ServiceAreaNotifier, ServiceAreaState>(
  (ref) => ServiceAreaNotifier(ref),
);
