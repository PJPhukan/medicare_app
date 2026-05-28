import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import 'quiz_screen.dart';
import 'biometric_screen.dart';
import 'emergency_screen.dart';
import 'subscription_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';

enum _AuthStep {
  login,
  otp,
  register,
  quiz,
  biometric,
  emergency,
  subscription,
  forgotPassword,
  forgotOtp,
  resetPassword,
}

// ─── Shared data passed between steps ────────────────────────────────────────

class AuthDraft {
  String identifier = '';
  String password = '';
  bool useOtp = false;
  // register fields
  String name = '';
  String email = '';
  String phone = '';
  // health
  String age = '';
  String bloodGroup = '';
  // emergency
  String allergies = '';
  String emergencyName = '';
  String emergencyPhone = '';
  // forgot password
  String resetIdentifier = '';
  String resetOtp = '';
}

// ─── Flow coordinator ─────────────────────────────────────────────────────────

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, this.onAuthenticated});
  final VoidCallback? onAuthenticated;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _AuthStep _step = _AuthStep.login;
  final _draft = AuthDraft();

  void _go(_AuthStep step) => setState(() => _step = step);

  void _back() {
    switch (_step) {
      case _AuthStep.otp:           _go(_AuthStep.login);
      case _AuthStep.register:      _go(_AuthStep.login);
      case _AuthStep.quiz:          _go(_AuthStep.register);
      case _AuthStep.biometric:     _go(_AuthStep.quiz);
      case _AuthStep.emergency:     _go(_AuthStep.biometric);
      case _AuthStep.subscription:  _go(_AuthStep.emergency);
      case _AuthStep.forgotPassword:_go(_AuthStep.login);
      case _AuthStep.forgotOtp:     _go(_AuthStep.forgotPassword);
      case _AuthStep.resetPassword: _go(_AuthStep.forgotOtp);
      default: break;
    }
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
        );
      case _AuthStep.quiz:
        return QuizScreen(
          draft: _draft,
          onContinue: () => _go(_AuthStep.biometric),
          onBack: _back,
        );
      case _AuthStep.biometric:
        return BiometricScreen(
          onContinue: () => _go(_AuthStep.emergency),
          onSkip: () => _go(_AuthStep.emergency),
          onBack: _back,
        );
      case _AuthStep.emergency:
        return EmergencyScreen(
          draft: _draft,
          onContinue: () => _go(_AuthStep.subscription),
          onSkip: () => _go(_AuthStep.subscription),
          onBack: _back,
        );
      case _AuthStep.subscription:
        return SubscriptionScreen(
          onDone: widget.onAuthenticated,
          onBack: _back,
        );
      case _AuthStep.forgotPassword:
        return ForgotPasswordScreen(
          onSent: (id) {
            _draft.resetIdentifier = id;
            _go(_AuthStep.forgotOtp);
          },
          onBack: _back,
        );
      case _AuthStep.forgotOtp:
        _draft.identifier = _draft.resetIdentifier;
        return OtpScreen(
          draft: _draft,
          purpose: 'RESET_PASSWORD',
          verifyWithApi: false,
          onOtpCollected: (otp) => _draft.resetOtp = otp,
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
