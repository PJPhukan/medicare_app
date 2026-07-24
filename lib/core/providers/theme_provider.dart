import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_db/local_cache.dart';

const _kThemeMode = 'theme_mode';

/// Persisted theme mode — restored from SharedPreferences on startup and
/// saved on every change.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_kThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.dark,
    );
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_kThemeMode, mode.name);
  }
}
