import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/client.dart';
import '../../../../core/api/session_events.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  final String? token;
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool clearToken = false,
    bool clearError = false,
  }) =>
      AuthState(
        token: clearToken ? null : (token ?? this.token),
        user: clearToken ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// ── Auth notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._login, this._logout, this._verifyOtp, this._repo)
      : super(const AuthState()) {
    initialized = _init();
  }

  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final VerifyOtpUseCase _verifyOtp;
  final AuthRepository _repo;

  /// Completes once the cached token/user have been loaded from secure storage.
  late final Future<void> initialized;

  Future<void> _init() async {
    final token = await _repo.getCachedToken();
    final user = await _repo.getCachedUser();
    if (token != null && user != null) {
      state = AuthState(token: token, user: user);
      AppLogger.i('Session restored → uid:${user.id}', tag: 'Auth');
    } else {
      AppLogger.i('No cached session', tag: 'Auth');
    }
  }

  Future<void> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    AppLogger.i('Login attempt (password)', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _login(identifier: identifier, password: password);
      state = AuthState(token: result.token, user: result.user);
      AppLogger.i('Login success → uid:${result.user.id}', tag: 'Auth');
      AppLogger.track('auth.login');
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('Login failed', tag: 'Auth', error: e, stack: s);
      AppLogger.track('auth.login_failed', error: _msg(e));
      rethrow;
    }
  }

  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  }) async {
    AppLogger.i('OTP send → purpose:$purpose', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.sendOtp(identifier: identifier, purpose: purpose);
      state = state.copyWith(isLoading: false);
      AppLogger.i('OTP sent ✓', tag: 'Auth');
      AppLogger.track('auth.otp_sent', meta: {'purpose': purpose});
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('OTP send failed', tag: 'Auth', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    AppLogger.i('OTP verify attempt', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _verifyOtp(identifier: identifier, otp: otp);
      state = AuthState(token: result.token, user: result.user);
      AppLogger.i('OTP verified → uid:${result.user.id}', tag: 'Auth');
      AppLogger.track('auth.otp_verified');
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('OTP verify failed', tag: 'Auth', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    AppLogger.i('Register attempt', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthState(token: result.token, user: result.user);
      AppLogger.i('Register success → uid:${result.user.id}', tag: 'Auth');
      AppLogger.track('auth.register');
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('Register failed', tag: 'Auth', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> forgotPassword(String identifier) async {
    AppLogger.i('Forgot password request', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.forgotPassword(identifier);
      state = state.copyWith(isLoading: false);
      AppLogger.i('Forgot password OTP sent ✓', tag: 'Auth');
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('Forgot password failed', tag: 'Auth', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    AppLogger.i('Password reset attempt', tag: 'Auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.resetPassword(identifier: identifier, otp: otp, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      AppLogger.i('Password reset success ✓', tag: 'Auth');
    } on Exception catch (e, s) {
      state = state.copyWith(isLoading: false, error: _msg(e));
      AppLogger.e('Password reset failed', tag: 'Auth', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> logout() async {
    AppLogger.i('Logout → uid:${state.user?.id}', tag: 'Auth');
    AppLogger.track('auth.logout');
    await _logout();
    state = const AuthState();
    AppLogger.i('Logged out ✓', tag: 'Auth');
  }

  bool _sessionExpiring = false;

  /// Called when an API returns 401 (invalid/expired token). Clears the session
  /// so the app redirects to login. Guarded against re-entrancy and only acts
  /// when currently authenticated.
  Future<void> handleSessionExpired() async {
    if (_sessionExpiring || !state.isAuthenticated) return;
    _sessionExpiring = true;
    AppLogger.i('Session expired (401) → signing out', tag: 'Auth');
    try {
      try {
        await _logout(); // best-effort server logout; ignore failures
      } catch (_) {}
      state = const AuthState();
    } finally {
      _sessionExpiring = false;
    }
  }

  String _msg(Exception e) {
    if (e is DioException) {
      return e.message ?? 'An unexpected error occurred';
    }
    return e.toString();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _authSecureStorage = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final _authLocalProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.read(_authSecureStorage)),
);

final _authRemoteProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.read(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(_authLocalProvider),
    ref.read(_authRemoteProvider),
  ),
);

final _loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final _logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);

final _verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.read(authRepositoryProvider)),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final notifier = AuthNotifier(
      ref.read(_loginUseCaseProvider),
      ref.read(_logoutUseCaseProvider),
      ref.read(_verifyOtpUseCaseProvider),
      ref.read(authRepositoryProvider),
    );
    // Sign out automatically when any request reports an expired session (401).
    SessionEvents.instance.onUnauthorized = notifier.handleSessionExpired;
    return notifier;
  },
);

/// Convenience provider — other feature providers watch this to invalidate on logout/login.
final authTokenProvider = Provider<String?>(
  (ref) => ref.watch(authProvider).token,
);
