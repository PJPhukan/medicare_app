import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/constants/app_strings.dart';
import 'core/local_db/local_cache.dart';
import 'core/sync/sync_engine.dart';
import 'core/services/biometric_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/event_log_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/auth_flow.dart';
import 'features/shell/presentation/screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init();
  final prefs = await SharedPreferences.getInstance();
  await NotificationService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MediForzeApp(),
    ),
  );
}

// ── Route observer ────────────────────────────────────────────────────────────

final _routeObserver = _AppRouteObserver();

class _AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name ?? route.runtimeType.toString();
    AppLogger.i('→ $name', tag: 'Nav');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final prev = previousRoute?.settings.name ?? previousRoute?.runtimeType.toString() ?? '?';
    AppLogger.i('← back to $prev', tag: 'Nav');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final name = newRoute?.settings.name ?? newRoute?.runtimeType.toString() ?? '?';
    AppLogger.i('⇒ $name', tag: 'Nav');
  }
}

// ── App root ──────────────────────────────────────────────────────────────────

class MediForzeApp extends ConsumerWidget {
  const MediForzeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncEngineProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Wire EventLogService → AppLogger once so AppLogger.track() reaches the backend.
    AppLogger.setRemoteTracker(ref.read(eventLogServiceProvider).track);

    // Keep logger in sync with auth state — log only the user ID (UUID), never PII.
    ref.listen(authProvider, (prev, next) {
      if (next.user?.id != prev?.user?.id) {
        AppLogger.setUser(next.user?.id);
      }
    });

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      navigatorObservers: [_routeObserver],
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends ConsumerStatefulWidget {
  const _AppEntry();

  @override
  ConsumerState<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends ConsumerState<_AppEntry>
    with WidgetsBindingObserver {
  Widget _current = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _current = SplashScreen(onDone: _afterSplash);
    AppLogger.i('App launched', tag: 'Lifecycle');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.i('App foregrounded', tag: 'Lifecycle');
      case AppLifecycleState.paused:
        AppLogger.i('App backgrounded', tag: 'Lifecycle');
      case AppLifecycleState.detached:
        AppLogger.i('App detached', tag: 'Lifecycle');
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to logout: when auth drops to unauthenticated while showing the
    // main shell, redirect to login without waiting for a callback.
    ref.listen<bool>(
      authProvider.select((s) => s.isAuthenticated),
      (previous, next) {
        if (previous == true && !next && _current is AppShell) {
          setState(() => _current = AuthFlow(onAuthenticated: _afterAuth));
        }
      },
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: KeyedSubtree(
        key: ValueKey(_current.runtimeType),
        child: _current,
      ),
    );
  }

  Future<void> _afterSplash() async {
    final seen = await hasSeenOnboarding();
    if (!mounted) return;

    if (!seen) {
      setState(() => _current = OnboardingScreen(onDone: _afterOnboarding));
      return;
    }

    // Wait for secure-storage token load to finish before reading auth state.
    await ref.read(authProvider.notifier).initialized;
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      final biometric = ref.read(biometricServiceProvider);
      if (biometric.isEnabled) {
        final ok = await biometric.authenticate(
          reason: 'Unlock MediForze to continue',
        );
        if (!mounted) return;
        if (ok) {
          setState(() => _current = const AppShell());
        } else {
          // Biometric failed/cancelled — fall back to login
          setState(() => _current = AuthFlow(onAuthenticated: _afterAuth));
        }
      } else {
        // Token valid, biometric not set up — go straight to app
        setState(() => _current = const AppShell());
      }
      return;
    }

    // No valid token — require login
    setState(() => _current = AuthFlow(onAuthenticated: _afterAuth));
  }

  void _afterOnboarding() {
    if (!mounted) return;
    setState(() => _current = AuthFlow(onAuthenticated: _afterAuth));
  }

  void _afterAuth() {
    if (!mounted) return;
    setState(() => _current = const AppShell());
  }

}
