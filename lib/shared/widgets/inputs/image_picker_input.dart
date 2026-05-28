import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Image picker input. Triggers [onTap] to open the OS picker and displays
/// a preview via [imageBytes] when provided.
class AppImagePickerInput extends StatelessWidget {
  const AppImagePickerInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.imageBytes,
    this.imageUrl,
    this.onTap,
    this.onClear,
    this.enabled = true,
    this.shape = BoxShape.rectangle,
    this.size = 120,
    this.color,
  });

  final String? label;
  final String? hint;
  final String? error;
  final String? helper;

  /// Raw bytes of the selected image (takes priority over [imageUrl]).
  final Uint8List? imageBytes;

  /// Remote URL shown as a network image preview.
  final String? imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool enabled;
  final BoxShape shape;
  final double size;
  final Color? color;

  bool get _hasImage => imageBytes != null || imageUrl != null;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final activeCol = color ?? AppColors.teal;

    Widget preview;
    if (imageBytes != null) {
      preview = Image.memory(imageBytes!, fit: BoxFit.cover,
          width: size, height: size);
    } else if (imageUrl != null) {
      preview = Image.network(imageUrl!, fit: BoxFit.cover,
          width: size, height: size);
    } else {
      preview = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded,
              size: 28, color: activeCol),
          const SizedBox(height: 6),
          Text(
            hint ?? 'Upload image',
            style: AppTypography.bodyXs
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            GestureDetector(
              onTap: enabled ? onTap : null,
              child: Container(
                width: size,
                height: size,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  shape: shape,
                  color: context.inputBg,
                  borderRadius: shape == BoxShape.circle
                      ? null
                      : AppBorderRadius.mdAll,
                  border: Border.all(
                    color: hasError ? AppColors.error : context.borderCol,
                  ),
                ),
                child: _hasImage
                    ? preview
                    : Center(child: preview),
              ),
            ),
            if (_hasImage && onClear != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
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
