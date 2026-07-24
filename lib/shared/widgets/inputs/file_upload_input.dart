import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// File upload input that displays the chosen file name and triggers [onTap].
///
/// This widget provides the UI only — wire [onTap] to a file picker package
/// (e.g. file_picker) to actually open the OS picker and pass the result back
/// via [selectedFileName].
class AppFileUploadInput extends StatelessWidget {
  const AppFileUploadInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.selectedFileName,
    this.onTap,
    this.onClear,
    this.enabled = true,
    this.allowedExtensions,
    this.color,
  });

  final String? label;
  final String? hint;
  final String? error;
  final String? helper;

  /// Name of the currently selected file (shown in the field).
  final String? selectedFileName;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool enabled;

  /// Optional list of accepted extensions shown as helper text (e.g. ['pdf','docx']).
  final List<String>? allowedExtensions;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final hasError  = error != null && error!.isNotEmpty;
    final borderCol = hasError ? AppColors.error : context.borderCol;
    final activeCol = color ?? AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTypography.labelSm.copyWith(
                  letterSpacing: 0.2, color: context.secondaryText)),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(
                color: borderCol,
                style: selectedFileName == null
                    ? BorderStyle.none
                    : BorderStyle.solid,
              ),
            ),
            child: selectedFileName != null
                ? Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined,
                          size: 18, color: activeCol),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(selectedFileName!,
                            style: AppTypography.bodyMd
                                .copyWith(color: context.primaryText),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (onClear != null)
                        GestureDetector(
                          onTap: onClear,
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: AppColors.textSecondary),
                        ),
                    ],
                  )
                : DottedBorder(
                    color: borderCol,
                    borderRadius: AppBorderRadius.mdAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded,
                              size: 20, color: activeCol),
                          const SizedBox(width: 8),
                          Text(
                            hint ?? 'Tap to choose a file',
                            style: AppTypography.bodyMd
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        if (allowedExtensions != null && !hasError) ...[
          const SizedBox(height: 5),
          Text(
            'Accepted: ${allowedExtensions!.map((e) => '.$e').join(', ')}',
            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
          ),
        ],
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Expanded(child: Text(error!,
                style: AppTypography.bodyXs.copyWith(color: AppColors.error))),
          ]),
        ] else if (helper != null) ...[
          const SizedBox(height: 5),
          Text(helper!,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ],
    );
  }
}

/// Minimal dashed-border container used by [AppFileUploadInput].
class DottedBorder extends StatelessWidget {
  const DottedBorder({
    super.key,
    required this.child,
    required this.color,
    required this.borderRadius,
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: color, style: BorderStyle.solid),
      ),
      child: child,
    );
  }
}
