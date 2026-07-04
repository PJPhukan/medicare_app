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

  final results = await Future.wait([
    AppLogger.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SharedPreferences.getInstance(),
  ]);
  final prefs = results[2] as SharedPreferences;

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MediForzeApp(),
    ),
  );

  await NotificationService.init();
  try {
    await FirebaseMessagingService.initialize();
  } catch (e) {
    AppLogger.e('FCM initialization failed: $e', tag: 'FCM');
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
      routerConfig: router,
    );
  }
}
