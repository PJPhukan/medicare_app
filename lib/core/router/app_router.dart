import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/biometric_service.dart';
import '../utils/logger.dart';
import '../local_db/local_cache.dart';
import '../constants/prefs_keys.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_flow.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/appearance_screen.dart';
import '../../features/settings/presentation/screens/language_region_screen.dart';
import '../../features/settings/presentation/screens/security_login_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/health_profile_screen.dart';
import '../../features/settings/presentation/screens/notification_setting_screen.dart';
import '../../features/settings/presentation/screens/become_professional_screen.dart' as settings_pro;
import '../../features/professionals/presentation/screens/become_professional_screen.dart';
import '../../features/professionals/presentation/screens/pro_hub_screen.dart';
import '../../features/professionals/presentation/screens/service_areas_screen.dart';
import '../../features/professionals/presentation/screens/payout_details_screen.dart';
import '../../features/premium/presentation/screens/subscription_management_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/support/presentation/screens/submit_ticket_screen.dart';
import '../../features/support/presentation/screens/help_center_screen.dart';
import '../../features/vitals/presentation/screens/vital_history_screen.dart';
import '../../features/vitals/presentation/screens/add_vital_screen.dart';
import '../../features/medicines/presentation/screens/add_medicine_screen.dart';
import '../../features/medicines/presentation/screens/medicine_detail_screen.dart';
import '../../features/professionals/presentation/screens/professionals_screen.dart' show ProData;
import '../../features/professionals/presentation/screens/professional_detail_screen.dart';
import '../../features/professionals/presentation/screens/professional_connections_screen.dart' as pro_conn;
import '../../features/professionals/presentation/screens/map_picker_screen.dart';
import '../../features/message/presentation/screens/thread_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart' show NoteData;
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/caretakers/presentation/screens/invite_caretaker_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/community/presentation/screens/create_post_screen.dart';
import '../../features/community/presentation/screens/post_detail_screen.dart';
import '../../features/connections/presentation/screens/chat_screen.dart';
import '../../features/patients/presentation/screens/patient_detail_screen.dart';
import '../../features/reports/presentation/screens/report_viewer_screen.dart';
import '../../shared/widgets/feedback/not_found_page.dart';
import 'route_args.dart';

// ── Route paths ───────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';

  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const healthProfile = '/health-profile';
  static const proApplication = '/pro-application';
  static const settings = '/settings';
  static const settingsEdit = '/settings/edit';
  static const settingsAppearance = '/settings/appearance';
  static const settingsLanguageRegion = '/settings/language-region';
  static const settingsSecurityLogin = '/settings/security-login';
  static const settingsChangePassword = '/settings/change-password';
  static const settingsPro = '/settings/pro';
  static const settingsProHub = '/settings/pro-hub';
  static const settingsProHubAreas = '/settings/pro-hub/areas';
  static const settingsProHubPayout = '/settings/pro-hub/payout';
  static const settingsPremium = '/settings/premium';

  static const support = '/support';
  static const supportTicket = '/support/ticket';
  static const supportHelpCenter = '/support/help-center';

  static const vitalHistory = '/vitals/history';
  static const vitalAdd = '/vitals/add';

  static const medicineAdd = '/medicines/add';
  static const medicineDetail = '/medicines/detail';

  static const professionalDetail = '/professionals/detail';
  static const professionalsConnections = '/professionals/connections';
  static const professionalsMapPicker = '/professionals/map-picker';

  static const thread = '/messages/thread';

  static const noteEditor = '/notes/editor';

  static const caretakerInvite = '/caretakers/invite';

  static const communityCreate = '/community/create';
  static const communityPost = '/community/post';

  static const chat = '/connections/chat';

  static const patientDetail = '/patients/detail';

  static const reportViewer = '/reports/viewer';

  static const community = '/community';
}

// ── Auth-guard refresh notifier ───────────────────────────────────────────────

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<bool>(
      authProvider.select((s) => s.isAuthenticated),
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = _ref.read(authProvider).isAuthenticated;
    final loc = state.matchedLocation;

    final isPublic = loc == AppRoutes.splash ||
        loc == AppRoutes.onboarding ||
        loc == AppRoutes.auth;

    // Session lost while on a protected route → back to login
    if (!isPublic && !isAuthenticated) return AppRoutes.auth;
    return null;
  }
}

// ── Router provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    errorBuilder: (context, state) => NotFoundPage(path: state.uri.toString()),
    routes: [
      // ── Public ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(
          // Splash is a dead end: if this callback throws or awaits something
          // that never settles, the user sits on the logo forever with no
          // error shown. So every path out is guarded and time-boxed, and any
          // failure falls through to the auth screen.
          onDone: () async {
            try {
              final prefs = ref.read(sharedPreferencesProvider);
              final seen = prefs.getBool(PrefsKeys.onboardingSeen) ?? false;
              if (!context.mounted) return;
              if (!seen) {
                context.go(AppRoutes.onboarding);
                return;
              }
              // Secure-storage reads go over a platform channel that can wedge;
              // don't let that pin us to the splash screen.
              await ref.read(authProvider.notifier).initialized.timeout(
                    const Duration(seconds: 5),
                    onTimeout: () => AppLogger.w(
                        'Auth init timed out — routing as signed out',
                        tag: 'Splash'),
                  );
              if (!context.mounted) return;
              final auth = ref.read(authProvider);
              if (!auth.isAuthenticated) {
                context.go(AppRoutes.auth);
                return;
              }
              final pendingStep =
                  await ref.read(authRepositoryProvider).getOnboardingStep();
              if (!context.mounted) return;
              if (pendingStep != null) {
                context.go(AppRoutes.auth);
                return;
              }
              final bio = ref.read(biometricServiceProvider);
              if (!bio.isEnabled) {
                context.go(AppRoutes.home);
                return;
              }
              final ok = await bio.authenticate(reason: 'Unlock to continue');
              if (!context.mounted) return;
              context.go(ok ? AppRoutes.home : AppRoutes.auth);
            } catch (e, s) {
              AppLogger.e('Splash routing failed — falling back to auth',
                  tag: 'Splash', error: e, stack: s);
              if (context.mounted) context.go(AppRoutes.auth);
            }
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          onDone: () => context.go(AppRoutes.auth),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => AuthFlow(
          onAuthenticated: () => context.go(AppRoutes.home),
        ),
      ),

      // ── App shell ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AppShell(),
      ),

      // ── Top-level screens (push over shell) ──────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthProfile,
        builder: (context, state) => const HealthProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'appearance',
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'language-region',
            builder: (context, state) => const LanguageRegionScreen(),
          ),
          GoRoute(
            path: 'security-login',
            builder: (context, state) => const SecurityLoginScreen(),
          ),
          GoRoute(
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: 'pro',
            builder: (context, state) => const settings_pro.BecomeAProfessionalScreen(),
          ),
          GoRoute(
            path: 'pro-hub',
            builder: (context, state) => const ProHubScreen(),
            routes: [
              GoRoute(
                path: 'areas',
                builder: (context, state) => const ServiceAreasScreen(),
              ),
              GoRoute(
                path: 'payout',
                builder: (context, state) => const PayoutDetailsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'premium',
            builder: (context, state) => const SubscriptionManagementScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
        routes: [
          GoRoute(
            path: 'ticket',
            builder: (context, state) => const SubmitTicketScreen(),
          ),
          GoRoute(
            path: 'help-center',
            builder: (context, state) => const HelpCenterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const CommunityScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: 'post',
            builder: (context, state) {
              final args = state.extra as PostArgs;
              return PostDetailScreen(post: args);
            },
          ),
        ],
      ),

      // ── Vitals ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.vitalHistory,
        builder: (context, state) {
          final args = state.extra as VitalHistoryArgs;
          return VitalHistoryScreen(configId: args.configId, configName: args.configName);
        },
      ),
      GoRoute(
        path: AppRoutes.vitalAdd,
        builder: (context, state) => AddVitalScreen(
          initialTypeId: state.extra as String?,
        ),
      ),

      // ── Medicines ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.medicineAdd,
        builder: (context, state) => const AddMedicineScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicineDetail,
        builder: (context, state) {
          final args = state.extra as MedicineDetailArgs;
          return MedicineDetailScreen(med: args);
        },
      ),

      // ── Professionals ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.professionalDetail,
        builder: (context, state) {
          final args = state.extra as ProData;
          return ProfessionalDetailScreen(pro: args);
        },
      ),
      GoRoute(
        path: AppRoutes.professionalsConnections,
        builder: (context, state) => const pro_conn.ProfessionalConnectionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.professionalsMapPicker,
        builder: (context, state) => const MapPickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.proApplication,
        builder: (context, state) => const BecomeProfessionalScreen(),
      ),

      // ── Messages ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.thread,
        builder: (context, state) {
          final args = state.extra as ThreadArgs;
          return ThreadScreen(
            conversationId: args.conversationId,
            contactName: args.contactName,
          );
        },
      ),

      // ── Notes ────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.noteEditor,
        builder: (context, state) {
          final args = state.extra as NoteData;
          return NoteEditorScreen(note: args);
        },
      ),

      // ── Caretakers ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.caretakerInvite,
        builder: (context, state) => const InviteCaretakerScreen(),
      ),

      // ── Connections ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final args = state.extra as ChatArgs;
          return ChatScreen(
            connectionId: args.connectionId,
            professionalName: args.professionalName,
            professionalSpecialty: args.professionalSpecialty,
          );
        },
      ),

      // ── Patients ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.patientDetail,
        builder: (context, state) {
          final args = state.extra as PatientDetailArgs;
          return PatientDetailScreen(patient: args);
        },
      ),

      // ── Reports ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.reportViewer,
        builder: (context, state) {
          final args = state.extra as ReportViewerArgs;
          return ReportViewerScreen(report: args);
        },
      ),

      // ── Dashboard (direct push) ──────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        redirect: (_, __) => AppRoutes.home,
      ),
    ],
  );
});
