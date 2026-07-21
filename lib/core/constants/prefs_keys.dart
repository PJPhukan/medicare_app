/// Centralized SharedPreferences key constants
abstract final class PrefsKeys {
  // Onboarding
  static const onboardingSeen = 'onboarding_seen';
  static const lastSeenVersion = 'last_seen_version';

  // Biometric
  static const biometricEnabled = 'biometric_enabled';
  static const biometricReason = 'biometric_reason';

  // Sync
  static const syncLastTimestamp = 'sync_last_timestamp';
  static const syncStatus = 'sync_status';

  // User preferences
  static const lastSelectedLanguage = 'last_selected_language';
  static const lastProfileUpdate = 'last_profile_update';

  // Theme
  static const themeMode = 'theme_mode';

  // Feature flags
  static const premiumEnabled = 'premium_enabled';
  static const adminModeEnabled = 'admin_mode_enabled';
}
