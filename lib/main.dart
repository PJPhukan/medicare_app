import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/constants/app_strings.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/auth_flow.dart';
import 'features/shell/presentation/screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: MediForzeApp()));
}

class MediForzeApp extends ConsumerWidget {
  const MediForzeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _AppEntry(),
    );
  }
}

// Decides: splash → onboarding (first launch) or splash → auth (returning).
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  Widget _current = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _current = SplashScreen(onDone: _afterSplash);
  }

  Future<void> _afterSplash() async {
    final seen = await hasSeenOnboarding();
    if (!mounted) return;
    setState(() {
      if (seen) {
        _current = AuthFlow(onAuthenticated: _afterAuth);
      } else {
        _current = OnboardingScreen(onDone: _afterOnboarding);
      }
    });
  }

  void _afterOnboarding() {
    if (!mounted) return;
    setState(() {
      _current = AuthFlow(onAuthenticated: _afterAuth);
    });
  }

  void _afterAuth() {
    if (!mounted) return;
    setState(() {
      _current = const AppShell();
    });
  }

  @override
  Widget build(BuildContext context) {
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
}

