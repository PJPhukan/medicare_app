import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

/// Google + Apple side-by-side social login buttons.
///
/// ```dart
/// AuthSocialButtons(
///   onGooglePressed: _signInWithGoogle,
///   onApplePressed:  _signInWithApple,
/// )
/// ```
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label:     AppStrings.google,
            leading:   const AuthGoogleIcon(),
            variant:   AppButtonVariant.secondary,
            onPressed: onGooglePressed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            label:     AppStrings.apple,
            leading:   const AuthAppleIcon(),
            variant:   AppButtonVariant.secondary,
            onPressed: onApplePressed,
          ),
        ),
      ],
    );
  }
}
