import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/professionals/data/models/location_models.dart';
import '../constants/api_constants.dart';

// ─── Keys ─────────────────────────────────────────────────────────────────────

const _kSavedLocation = 'saved_professional_location';

// ─── Exceptions ───────────────────────────────────────────────────────────────

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException([this.message = 'Location permission denied']);
  final String message;
  @override String toString() => message;
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
  @override String toString() => 'Location services are disabled';
}

class PincodeNotFoundException implements Exception {
  const PincodeNotFoundException(this.pincode);
  final String pincode;
  @override String toString() => 'No area found for pincode $pincode';
}

// ─── Service ──────────────────────────────────────────────────────────────────

class LocationService {
  const LocationService(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  // ── GPS → pincode → AreaInfo ────────────────────────────────────────────────

  Future<SavedLocation> detectFromGps() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw const LocationServiceDisabledException();

    // 2. Check/request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(
        'Location permission permanently denied — please enable it in app settings',
      );
    }

    // 3. Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // 4. Reverse geocode → postal code
    final pincode = await _pincodeFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // 5. Resolve pincode to area via our backend
    return resolveFromPincode(pincode);
  }

  // ── Map-picked coordinates → AreaInfo ──────────────────────────────────────
  // Used by the "select on map" picker: reverse-geocode the dropped pin to a
  // pincode, then resolve to an area via our backend.

  Future<SavedLocation> resolveFromCoordinates(double lat, double lng) async {
    final pincode = await _pincodeFromCoordinates(lat, lng);
    return resolveFromPincode(pincode);
  }

  // ── Reverse geocode → 6-digit Indian postal code ───────────────────────────

  Future<String> _pincodeFromCoordinates(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    for (final p in placemarks) {
      final code = (p.postalCode ?? '').replaceAll(RegExp(r'\D'), '');
      if (code.length == 6) return code;
    }
    throw const LocationPermissionDeniedException(
      'Could not resolve your location to a pincode — please enter it manually',
    );
  }

  // ── Pincode → AreaInfo via backend ─────────────────────────────────────────

  Future<SavedLocation> resolveFromPincode(String pincode) async {
    final location = await _resolvePincodeNoSave(pincode);
    await saveLocation(location);
    return location;
  }

  // Resolve a pincode to an area WITHOUT persisting — used for live preview.
  Future<SavedLocation> _resolvePincodeNoSave(String pincode) async {
    final clean = pincode.trim().replaceAll(RegExp(r'\D'), '');
    if (clean.length != 6) {
      throw ArgumentError('Pincode must be exactly 6 digits');
    }

    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.profPincodeResolve}/$clean',
    );

    final areas = (res.data!['data']['areas'] as List?)
        ?.map((e) => AreaInfo.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    if (areas.isEmpty) throw PincodeNotFoundException(clean);

    return SavedLocation(pincode: clean, area: areas.first);
  }

  // ── Live preview (no persistence) ───────────────────────────────────────────

  // Reverse-geocode coordinates to an area, without saving. Returns null when
  // the spot can't be resolved (e.g. ocean, or unsupported area).
  Future<SavedLocation?> previewCoordinates(double lat, double lng) async {
    try {
      final pincode = await _pincodeFromCoordinates(lat, lng);
      return await _resolvePincodeNoSave(pincode);
    } catch (_) {
      return null;
    }
  }

  // Resolve the device's current location to an area, without saving — only
  // when permission is already granted (never prompts). Returns null otherwise.
  Future<SavedLocation?> previewCurrentLocation() async {
    if (!await hasPermission()) return null;
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return previewCoordinates(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  // ── Area search (by pincode or name/district) ───────────────────────────────
  // Backed by /api/professionals/areas/search — supports a 6-digit pincode or
  // a free-text area/district name (min 2 chars).

  Future<List<AreaInfo>> searchAreas(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final digits = q.replaceAll(RegExp(r'\D'), '');
    final params = <String, dynamic>{};
    if (digits.length == 6) {
      params['pincode'] = digits;
    } else {
      if (q.length < 2) return [];
      params['search'] = q;
    }

    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.profAreasSearch,
      queryParameters: params,
    );

    return (res.data!['data'] as List?)
            ?.map((e) => AreaInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  // Persist an area chosen from search results as the saved location.
  Future<SavedLocation> selectArea(AreaInfo area, {String? pincode}) async {
    final location = SavedLocation(pincode: pincode, area: area);
    await saveLocation(location);
    return location;
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  SavedLocation? getLastSavedLocation() {
    final raw = _prefs.getString(_kSavedLocation);
    if (raw == null) return null;
    try {
      return SavedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocation(SavedLocation location) async {
    await _prefs.setString(_kSavedLocation, jsonEncode(location.toJson()));
  }

  Future<void> clearSavedLocation() async {
    await _prefs.remove(_kSavedLocation);
  }

  // ── Permission status check (no request) ───────────────────────────────────

  Future<bool> hasPermission() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always ||
        p == LocationPermission.whileInUse;
  }

  // True when the OS will no longer show the permission dialog —
  // the user must enable location from app settings.
  Future<bool> isPermanentlyDenied() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.deniedForever;
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
