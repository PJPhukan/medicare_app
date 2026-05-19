import '../constants/app_strings.dart';

abstract class Validators {
  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppStrings.fieldRequired;
    if (s.length < 2) return AppStrings.nameTooShort;
    return null;
  }

  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppStrings.fieldRequired;
    if (!_emailRe.hasMatch(s)) return AppStrings.invalidEmail;
    return null;
  }

  static String? phone(String? v) {
    final digits = (v?.trim() ?? '').replaceAll(RegExp(r'[\s\-+()]'), '');
    if (digits.isEmpty) return AppStrings.fieldRequired;
    if (digits.length < 10) return AppStrings.invalidPhone;
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return AppStrings.fieldRequired;
    if (s.length < 8) return AppStrings.passwordTooShort;
    return null;
  }

  // Valid email OR phone with ≥10 digits
  static String? emailOrPhone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppStrings.fieldRequired;
    final isEmail = RegExp(r'[A-Za-z]').hasMatch(s);
    if (isEmail) return _emailRe.hasMatch(s) ? null : AppStrings.invalidEmail;
    final digits = s.replaceAll(RegExp(r'[\s\-+()]'), '');
    if (digits.length < 10) return AppStrings.invalidPhone;
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if ((v ?? '').isEmpty) return AppStrings.fieldRequired;
    if (v != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? age(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppStrings.fieldRequired;
    final n = int.tryParse(s);
    if (n == null || n < 1 || n > 120) return 'Please enter a valid age (1–120)';
    return null;
  }
}
