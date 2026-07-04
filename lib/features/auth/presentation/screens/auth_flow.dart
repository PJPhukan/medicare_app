import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import 'quiz_screen.dart';
import 'emergency_screen.dart';
import '../../../premium/presentation/screens/subscription_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';

enum _AuthStep {
  login,
  otp,
  register,
  quiz,
  emergency,
  subscription,
  forgotPassword,
  forgotOtp,
  resetPassword,
}

// Steps that are part of post-registration onboarding (persisted locally).
const _onboardingSteps = {
  _AuthStep.quiz,
  _AuthStep.emergency,
  _AuthStep.subscription,
};

// ─── Shared data passed between steps ────────────────────────────────────────

class AuthDraft {
  const AuthDraft({
    this.identifier = '',
    this.password = '',
    this.useOtp = false,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.age = '',
    this.bloodGroup = '',
    this.dob = '',
    this.conditions = const [],
    this.allergies = const [],
    this.emergencyName = '',
    this.emergencyPhone = '',
    this.resetIdentifier = '',
    this.resetOtp = '',
  });

  final String identifier;
  final String password;
  final bool useOtp;
  final String name;
  final String email;
  final String phone;
  final String age;
  final String bloodGroup;
  final String dob;
  final List<String> conditions;
  final List<String> allergies;
  final String emergencyName;
  final String emergencyPhone;
  final String resetIdentifier;
  final String resetOtp;

  AuthDraft copyWith({
    String? identifier,
    String? password,
    bool? useOtp,
    String? name,
    String? email,
    String? phone,
    String? age,
    String? bloodGroup,
    String? dob,
    List<String>? conditions,
    List<String>? allergies,
    String? emergencyName,
    String? emergencyPhone,
    String? resetIdentifier,
    String? resetOtp,
  }) =>
      AuthDraft(
        identifier: identifier ?? this.identifier,
        password: password ?? this.password,
        useOtp: useOtp ?? this.useOtp,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        age: age ?? this.age,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        dob: dob ?? this.dob,
        conditions: conditions ?? this.conditions,
        allergies: allergies ?? this.allergies,
        emergencyName: emergencyName ?? this.emergencyName,
        emergencyPhone: emergencyPhone ?? this.emergencyPhone,
        resetIdentifier: resetIdentifier ?? this.resetIdentifier,
        resetOtp: resetOtp ?? this.resetOtp,
      );
}

// ─── Flow coordinator ─────────────────────────────────────────────────────────

class AuthFlow extends ConsumerStatefulWidget {
  const AuthFlow({super.key, this.onAuthenticated});
  final VoidCallback? onAuthenticated;

  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow> {
  _AuthStep _step = _AuthStep.login;
  AuthDraft _draft = const AuthDraft();

  @override
  void initState() {
    super.initState();
    _restoreOnboardingStep();
  }

  Future<void> _restoreOnboardingStep() async {
    final saved = await ref.read(authRepositoryProvider).getOnboardingStep();
    if (saved == null || !mounted) return;
    final step = _AuthStep.values.where((s) => s.name == saved).firstOrNull;
    if (step != null && _onboardingSteps.contains(step)) {
      setState(() => _step = step);
    }
  }

  void _go(_AuthStep step) {
    if (_onboardingSteps.contains(step)) {
      ref.read(authRepositoryProvider).saveOnboardingStep(step.name);
    }
    setState(() => _step = step);
  }

  void _updateDraft(AuthDraft draft) => setState(() => _draft = draft);

  void _back() {
    switch (_step) {
      case _AuthStep.otp:           _go(_AuthStep.login);
      case _AuthStep.register:      _go(_AuthStep.login);
      case _AuthStep.quiz:          _go(_AuthStep.register);
      case _AuthStep.emergency:     _go(_AuthStep.quiz);
      case _AuthStep.subscription:  _go(_AuthStep.emergency);
      case _AuthStep.forgotPassword: _go(_AuthStep.login);
      case _AuthStep.forgotOtp:     _go(_AuthStep.forgotPassword);
      case _AuthStep.resetPassword: _go(_AuthStep.forgotOtp);
      default: break;
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(authRepositoryProvider).clearOnboardingStep();
    widget.onAuthenticated?.call();
  }

  Widget _buildStep() {
    switch (_step) {
      case _AuthStep.login:
        return LoginScreen(
          draft: _draft,
          onSentOtp: () => _go(_AuthStep.otp),
          onLoggedIn: widget.onAuthenticated,
          onRegister: () => _go(_AuthStep.register),
          onForgotPassword: () => _go(_AuthStep.forgotPassword),
          onDraftChanged: _updateDraft,
        );
      case _AuthStep.otp:
        return OtpScreen(
          draft: _draft,
          onVerified: widget.onAuthenticated,
          onBack: _back,
        );
      case _AuthStep.register:
        return RegisterScreen(
          draft: _draft,
          onContinue: () => _go(_AuthStep.quiz),
          onLogin: () => _go(_AuthStep.login),
          onBack: _back,
          onDraftChanged: _updateDraft,
        );
      case _AuthStep.quiz:
        return QuizScreen(
          draft: _draft,
          onContinue: () => _go(_AuthStep.emergency),
          onBack: _back,
          onDraftChanged: _updateDraft,
        );
      case _AuthStep.emergency:
        return EmergencyScreen(
          draft: _draft,
          onContinue: () => _go(_AuthStep.subscription),
          onSkip: () => _go(_AuthStep.subscription),
          onBack: _back,
          onDraftChanged: _updateDraft,
        );
      case _AuthStep.subscription:
        return SubscriptionScreen(
          onDone: _finishOnboarding,
          onBack: _back,
        );
      case _AuthStep.forgotPassword:
        return ForgotPasswordScreen(
          onSent: (id) => setState(() {
            _draft = _draft.copyWith(resetIdentifier: id);
            _step = _AuthStep.forgotOtp;
          }),
          onBack: _back,
        );
      case _AuthStep.forgotOtp:
        final forgotOtpDraft = _draft.copyWith(identifier: _draft.resetIdentifier);
        return OtpScreen(
          draft: forgotOtpDraft,
          purpose: 'RESET_PASSWORD',
          verifyWithApi: false,
          onOtpCollected: (otp) =>
              setState(() => _draft = _draft.copyWith(resetOtp: otp)),
          onVerified: () => _go(_AuthStep.resetPassword),
          onBack: _back,
        );
      case _AuthStep.resetPassword:
        return ResetPasswordScreen(
          identifier: _draft.resetIdentifier,
          otp: _draft.resetOtp,
          onReset: () => _go(_AuthStep.login),
          onBack: _back,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
    );
  }
}
