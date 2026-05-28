import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_db/local_cache.dart';
import '../utils/logger.dart';

class BiometricService {
  BiometricService(this._prefs);

  final SharedPreferences _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  static const _kEnabled = 'biometric_enabled';

  /// Whether the device supports biometric or device-credential authentication.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Which biometric types are enrolled (fingerprint, face, iris).
  Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Whether the user has opted in to biometric login.
  bool get isEnabled => _prefs.getBool(_kEnabled) ?? false;

  Future<void> setEnabled(bool enabled) {
    AppLogger.i('Biometric ${enabled ? 'enabled' : 'disabled'}', tag: 'Biometric');
    return _prefs.setBool(_kEnabled, enabled);
  }

  /// Prompt the user. Returns true on success, false on failure/cancel.
  Future<bool> authenticate({
    String reason = 'Verify your identity to continue',
  }) async {
    AppLogger.i('Biometric authenticate', tag: 'Biometric');
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN/pattern as fallback
        ),
      );
      AppLogger.i('Biometric result → ${ok ? 'success' : 'failed/cancelled'}', tag: 'Biometric');
      return ok;
    } catch (e, s) {
      AppLogger.e('Biometric error', tag: 'Biometric', error: e, stack: s);
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) =>
    BiometricService(ref.read(sharedPreferencesProvider)));
