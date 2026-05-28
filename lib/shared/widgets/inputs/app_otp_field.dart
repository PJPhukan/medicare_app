import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.errorText,
    this.controller,
    this.autoFocus = true,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;
  final String? errorText;
  final TextEditingController? controller;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: length,
          controller: controller,
          autoDismissKeyboard: true,
          autoFocus: autoFocus,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          animationDuration: const Duration(milliseconds: 150),
          enableActiveFill: true,
          textStyle: AppTypography.h3.copyWith(color: context.primaryText),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: AppBorderRadius.lgAll,
            fieldHeight: 56,
            fieldWidth: 48,
            activeFillColor: context.inputBg,
            inactiveFillColor: context.inputBg,
            selectedFillColor: context.inputBg,
            activeColor: AppColors.teal,
            inactiveColor: context.borderCol,
            selectedColor: AppColors.teal,
            errorBorderColor: AppColors.error,
          ),
          onCompleted: onCompleted,
          onChanged: onChanged ?? (_) {},
          beforeTextPaste: (_) => true,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
