abstract class ApiConstants {
  // Configure at build/run time:
  // `flutter run --dart-define=API_BASE_URL=http://localhost:4000`
  // or for a LAN device: `--dart-define=API_BASE_URL=http://192.168.x.x:4000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://curaleecore-api-production.up.railway.app',
      // defaultValue: 'http://192.168.29.210:4000', // Home
       defaultValue: 'http://192.168.29.232:4000', // Ofice
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
  // POST /api/stock/:userMedicineId — creates or tops up a medicine's stock.
  static const String medicineStock = '/api/stock';

  // ── Vitals ────────────────────────────────────────────────────────────────
  static const String vitalConfigs = '/api/vitals';
  static const String myVitals = '/api/vitals/me';
  static String vitalHistory(String configId) => '/api/vitals/me/$configId/history';

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
  static const String professionalCategoryRequest = '/api/professionals/categories/request';
  static const String professionals = '/api/professionals';
  static const String professionalsByLocation = '/api/professionals/by-location';
  static const String profPincodeResolve = '/api/professionals/pincode';
  static const String myProfProfile = '/api/professionals/profile/me';
  static const String profProfile = '/api/professionals/profile';
  static const String profServiceAreas = '/api/professionals/service-areas';
  // Area-based service areas (pincode model)
  static const String profAreasSearch = '/api/professionals/areas/search';
  static const String profMyAreas = '/api/professionals/my-areas';
  static const String profMyDistricts = '/api/professionals/my-districts';
  static const String profPayoutDetails = '/api/professionals/payout-details';
  static const String profAreaRequest = '/api/professionals/areas/request';
  static const String profMyAreaRequests = '/api/professionals/areas/my-requests';

  // ── Reports ───────────────────────────────────────────────────────────────
  static const String reports = '/api/reports';

  // ── Patients ──────────────────────────────────────────────────────────────
  static const String patientProfiles = '/api/patients/profiles/mine';
  static const String addPatient = '/api/patients/add';
  static const String myCaretakers = '/api/patients/my-caretakers';
  static const String myMedicalProfile = '/api/patients/my-profile';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboard = '/api/dashboard';

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
  static const String availableCoupons = '/api/subscriptions/coupons/available';
  static const String createSubscriptionOrder = '/api/subscriptions/create-order';
  static const String confirmSubscriptionPayment = '/api/subscriptions/confirm-payment';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String users = '/api/users';
  static const String myTabs = '/api/users/tabs';
  static const String userProfile = '/api/users/me';
  static const String userAvatar = '/api/users/me/avatar';

  // ── Emergency ─────────────────────────────────────────────────────────────
  static const String emergencyProfile  = '/api/emergency/profile';
  static const String emergencyContacts = '/api/emergency/contacts';
  static const String emergencySos      = '/api/emergency/sos';

  // ── Messages ──────────────────────────────────────────────────────────────
  static const String conversations = '/api/messages/conversations';

  // ── Professional connections ──────────────────────────────────────────────
  static const String professionalConnections = '/api/professional-connections';

  // ── Event log ─────────────────────────────────────────────────────────────
  static const String events = '/api/events';
}
