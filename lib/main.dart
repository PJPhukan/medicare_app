import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/constants/app_strings.dart';
import 'core/local_db/local_cache.dart';
import 'core/services/notification_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/event_log_service.dart';
import 'core/api/client.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_engine.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/professionals/presentation/providers/location_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Only await what the first frame truly needs. Everything else is deferred
  // below runApp — awaiting Firebase/device-info here kept the native launch
  // window (black in dark mode) on screen for 1–2s before the splash rendered.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MediForzeApp(),
    ),
  );

  // Deferred initialisation — interleaves with the splash animation instead of
  // delaying it. Firebase must complete before anything touches FCM; the
  // dashboard's requestPermission() only runs after splash + routing.
  AppLogger.init();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.init();
    await FirebaseMessagingService.initialize();
  } catch (e) {
    AppLogger.e('Startup services init failed: $e', tag: 'Init');
  }
}

// ── App root ──────────────────────────────────────────────────────────────────

class MediForzeApp extends ConsumerStatefulWidget {
  const MediForzeApp({super.key});

  @override
  ConsumerState<MediForzeApp> createState() => _MediForzeAppState();
}

class _MediForzeAppState extends ConsumerState<MediForzeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLogger.i('App launched', tag: 'Lifecycle');
    // Pre-warm auth so secure-storage reads run during the splash animation.
    ref.read(authProvider.notifier).initialized;
    AppLogger.setRemoteTracker(ref.read(eventLogServiceProvider).track);
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
        ref.read(locationProvider.notifier).clear();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && mounted) {
        final dio = ref.read(dioProvider);
        final platform = Platform.isAndroid ? 'ANDROID' : 'IOS';
        await dio.post(
          '/api/notifications/tokens',
          data: {'token': fcmToken, 'platform': platform},
        );
        AppLogger.i('FCM token registered ($platform)', tag: 'FCM');
      }
    } catch (e) {
      AppLogger.e('Failed to register FCM token: $e', tag: 'FCM');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(syncEngineProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.user?.id != prev?.user?.id) {
        AppLogger.setUser(next.user?.id);
      }
      if (prev?.isAuthenticated != true && next.isAuthenticated) {
        _registerFcmToken();
      }
    });

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Default AnimatedTheme lerps the whole ThemeData and rebuilds every
      // mounted screen each frame for 200ms — with all visited tabs alive in
      // the shell's IndexedStack that drops frames on the dark/light toggle.
      // An instant switch reads as snappier.
      themeAnimationDuration: Duration.zero,
      routerConfig: router,
    );
  }
}
