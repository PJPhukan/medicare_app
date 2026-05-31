abstract class ApiConstants {
  // Configure at build/run time:
  // `flutter run --dart-define=API_BASE_URL=http://localhost:4000`
  // or for a LAN device: `--dart-define=API_BASE_URL=http://192.168.x.x:4000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.29.210:4000',
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String otpSend = '/api/auth/otp/send';
  static const String otpVerify = '/api/auth/otp/verify';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String refresh = '/api/auth/refresh';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // ── Medicines ─────────────────────────────────────────────────────────────
  static const String medicinesCatalog = '/api/medicines';
  static const String myMedicines = '/api/medicines/me';
  static const String sharedMedicines = '/api/medicines/shared';
  static const String medicineRequests = '/api/medicines/requests';

  // ── Vitals ────────────────────────────────────────────────────────────────
  static const String vitalConfigs = '/api/vitals';
  static const String myVitals = '/api/vitals/me';

  // ── Reminders / Schedule ──────────────────────────────────────────────────
  static const String reminderSchedules = '/api/reminders/schedules';
  static const String todayDoses = '/api/reminders/today';
  static const String doseLogs = '/api/reminders/logs';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/api/notifications';
  static const String notifReadAll = '/api/notifications/read-all';
  static const String pushTokens = '/api/notifications/tokens';

  // ── Professionals ─────────────────────────────────────────────────────────
  static const String professionalCategories = '/api/professionals/categories';
  static const String professionals = '/api/professionals';
  static const String myProfProfile = '/api/professionals/profile/me';
  static const String profProfile = '/api/professionals/profile';
  static const String profServiceAreas = '/api/professionals/service-areas';

  // ── Reports ───────────────────────────────────────────────────────────────
  static const String reports = '/api/reports';

  // ── Patients ──────────────────────────────────────────────────────────────
  static const String patientProfiles = '/api/patients/profiles/mine';
  static const String addPatient = '/api/patients/add';
  static const String myCaretakers = '/api/patients/my-caretakers';
  static const String myMedicalProfile = '/api/patients/my-profile';

  // ── Banners ───────────────────────────────────────────────────────────────
  static const String bannerConfig = '/api/banners/config';

  // ── Subscriptions ─────────────────────────────────────────────────────────
  static const String subscriptionPlans = '/api/subscriptions';
  static const String subscriptionSettings = '/api/subscriptions/settings';
  static const String mySubscription = '/api/subscriptions/me';
  static const String selectPlan = '/api/subscriptions/select';
  static const String purchasePlan = '/api/subscriptions/purchase';
  static const String cancelSubscription = '/api/subscriptions/cancel';
  static const String autoRenew = '/api/subscriptions/auto-renew';
  static const String validateCoupon = '/api/subscriptions/coupon/validate';
  static const String applyCoupon = '/api/subscriptions/coupon/apply';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String users = '/api/users';
  static const String myTabs = '/api/users/me/tabs';
  static const String userProfile = '/api/users/me';
  static const String userAvatar = '/api/users/me/avatar';

  // ── Emergency contacts ────────────────────────────────────────────────────
  static const String emergencyContacts = '/api/emergency/contacts';

  // ── Messages ──────────────────────────────────────────────────────────────
  static const String conversations = '/api/messages/conversations';

  // ── Professional connections ──────────────────────────────────────────────
  static const String professionalConnections = '/api/professional-connections';

  // ── Event log ─────────────────────────────────────────────────────────────
  static const String events = '/api/events';
}
