import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/local_cache.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/location_models.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(
    ref.read(dioProvider),
    ref.read(sharedPreferencesProvider),
  );
});

// ─── State ────────────────────────────────────────────────────────────────────

enum LocationStatus { idle, detecting, resolved, permissionDenied, error }

class LocationState {
  const LocationState({
    this.status = LocationStatus.idle,
    this.savedLocation,
    this.error,
  });

  final LocationStatus status;
  final SavedLocation? savedLocation;
  final String? error;

  bool get hasLocation => savedLocation != null;
  AreaInfo? get area    => savedLocation?.area;
  String?  get pincode  => savedLocation?.pincode;

  LocationState copyWith({
    LocationStatus? status,
    SavedLocation? savedLocation,
    String? error,
    bool clearError = false,
    bool clearLocation = false,
  }) =>
      LocationState(
        status:        status        ?? this.status,
        savedLocation: clearLocation ? null : (savedLocation ?? this.savedLocation),
        error:         clearError    ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._service) : super(const LocationState()) {
    _initializeLocation();
  }

  final LocationService _service;

  // Clear saved location on app startup (fresh location on each app launch)
  Future<void> _initializeLocation() async {
    await _service.clearSavedLocation();
  }

  // Auto-detect via GPS
  Future<void> detectFromGps() async {
    state = state.copyWith(status: LocationStatus.detecting, clearError: true);
    try {
      final location = await _service.detectFromGps();
      state = state.copyWith(
        status: LocationStatus.resolved,
        savedLocation: location,
      );
    } on LocationPermissionDeniedException catch (e) {
      state = state.copyWith(
        status: LocationStatus.permissionDenied,
        error: e.message,
      );
    } on LocationServiceDisabledException {
      state = state.copyWith(
        status: LocationStatus.error,
        error: 'Location services are disabled. Please enable them in Settings.',
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        error: e.toString(),
      );
    }
  }

  // Manual pincode entry
  Future<void> resolveFromPincode(String pincode) async {
    state = state.copyWith(status: LocationStatus.detecting, clearError: true);
    try {
      final location = await _service.resolveFromPincode(pincode);
      state = state.copyWith(
        status: LocationStatus.resolved,
        savedLocation: location,
      );
    } on PincodeNotFoundException {
      state = state.copyWith(
        status: LocationStatus.error,
        error: 'No service area found for pincode $pincode. Please try a different pincode.',
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        error: e.toString(),
      );
    }
  }

  // Map-picked coordinates (select on map)
  Future<void> resolveFromCoordinates(double lat, double lng) async {
    state = state.copyWith(status: LocationStatus.detecting, clearError: true);
    try {
      final location = await _service.resolveFromCoordinates(lat, lng);
      state = state.copyWith(
        status: LocationStatus.resolved,
        savedLocation: location,
      );
    } on PincodeNotFoundException {
      state = state.copyWith(
        status: LocationStatus.error,
        error: 'No service area found for that location. Try a different spot or enter a pincode.',
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        error: e.toString(),
      );
    }
  }

  // Search service areas by pincode or name/district.
  Future<List<AreaInfo>> searchAreas(String query) =>
      _service.searchAreas(query);

  // Live preview helpers (no persistence, no state change).
  Future<SavedLocation?> previewCoordinates(double lat, double lng) =>
      _service.previewCoordinates(lat, lng);

  Future<SavedLocation?> previewCurrentLocation() =>
      _service.previewCurrentLocation();

  // Persist an area chosen from search results as the current location.
  Future<void> selectArea(AreaInfo area, {String? pincode}) async {
    final location = await _service.selectArea(area, pincode: pincode);
    state = state.copyWith(
      status: LocationStatus.resolved,
      savedLocation: location,
    );
  }

  // Open system location settings for permanently denied cases
  Future<void> openSettings() => _service.openSettings();

  // True when the OS will no longer show the permission dialog
  Future<bool> isPermanentlyDenied() => _service.isPermanentlyDenied();

  // Clear and let user re-pick
  Future<void> clear() async {
    await _service.clearSavedLocation();
    state = const LocationState();
  }

  // Check if permission is granted, then auto-detect location
  // If not granted, do nothing (let UI show popup)
  Future<void> checkAndDetectLocation() async {
    try {
      final hasPermission = await _service.hasPermission();
      if (hasPermission) {
        // Permission already granted, auto-detect
        await detectFromGps();
      }
      // If no permission, do nothing - let UI show popup
    } catch (e) {
      AppLogger.e('Error checking location permission: $e', tag: 'Location');
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.read(locationServiceProvider));
});
