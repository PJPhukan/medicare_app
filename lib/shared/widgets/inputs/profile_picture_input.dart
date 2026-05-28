import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Circular profile picture picker.
///
/// Shows a avatar with a camera-badge overlay. Tap anywhere on the avatar
/// to trigger [onTap] — wire it to your image picker package, then pass
/// the result back via [imageBytes] or [imageUrl].
///
/// Pass [initials] (e.g. "PJ") to show a lettered placeholder when no image
/// is selected. Falls back to a person icon when [initials] is null.
class AppProfilePictureInput extends StatelessWidget {
  const AppProfilePictureInput({
    super.key,
    this.imageBytes,
    this.imageUrl,
    this.initials,
    this.label,
    this.sublabel,
    this.onTap,
    this.onRemove,
    this.enabled = true,
    this.size = 96,
    this.color,
    this.badgeIcon = Icons.camera_alt_rounded,
    this.showRemoveBadge = true,
    this.borderWidth = 3,
    this.error,
  });

  /// Raw bytes of the picked image (takes priority over [imageUrl]).
  final Uint8List? imageBytes;

  /// Remote URL shown as a network image.
  final String? imageUrl;

  /// 1–2 character initials shown when no image is set (e.g. "PJ").
  final String? initials;

  /// Optional label rendered below the avatar (e.g. "Profile photo").
  final String? label;

  /// Optional smaller text below [label] (e.g. "Tap to change").
  final String? sublabel;

  /// Called when the avatar or camera badge is tapped.
  final VoidCallback? onTap;

  /// Called when the × remove badge is tapped. Supply to show the badge.
  final VoidCallback? onRemove;

  final bool enabled;

  /// Diameter of the avatar circle in logical pixels.
  final double size;

  /// Accent colour used for the camera badge background and initials bg.
  /// Defaults to [AppColors.teal].
  final Color? color;

  /// Icon shown inside the camera badge.
  final IconData badgeIcon;

  /// Whether to show the × remove badge when an image is present.
  final bool showRemoveBadge;

  /// Width of the white border ring around the avatar.
  final double borderWidth;

  final String? error;

  bool get _hasImage => imageBytes != null || imageUrl != null;

  @override
  Widget build(BuildContext context) {
    final accentCol  = color ?? AppColors.teal;
    final hasError   = error != null && error!.isNotEmpty;
    final ringColor  = hasError ? AppColors.error : accentCol;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Outer ring ──────────────────────────────────────────────
              Container(
                width: size + borderWidth * 2,
                height: size + borderWidth * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ringColor.withValues(alpha: 0.18),
                  border: Border.all(
                    color: ringColor.withValues(alpha: 0.4),
                    width: borderWidth,
                  ),
                ),
                child: Center(
                  // ── Avatar circle ────────────────────────────────────────
                  child: ClipOval(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: _hasImage
                          ? _ImageView(
                              bytes: imageBytes,
                              url: imageUrl,
                              size: size,
                            )
                          : _Placeholder(
                              initials: initials,
                              size: size,
                              color: accentCol,
                            ),
                    ),
                  ),
                ),
              ),

              // ── Camera badge (bottom-right) ──────────────────────────────
              Positioned(
                bottom: 0,
                right: 0,
                child: _Badge(
                  icon: badgeIcon,
                  color: accentCol,
                  size: size * 0.28,
                ),
              ),

              // ── Remove badge (top-right) ─────────────────────────────────
              if (_hasImage && showRemoveBadge && onRemove != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: _Badge(
                      icon: Icons.close_rounded,
                      color: AppColors.error,
                      size: size * 0.26,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Labels ────────────────────────────────────────────────────────
        if (label != null) ...[
          const SizedBox(height: 10),
          Text(
            label!,
            style: AppTypography.labelSm.copyWith(
              color: context.primaryText,
              letterSpacing: 0.2,
            ),
          ),
        ],
        if (sublabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              sublabel!,
              style: AppTypography.bodyXs.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

        // ── Error ─────────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 12, color: AppColors.error),
              const SizedBox(width: 4),
              Text(error!,
                  style: AppTypography.bodyXs
                      .copyWith(color: AppColors.error)),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Image view ───────────────────────────────────────────────────────────────

class _ImageView extends StatelessWidget {
  const _ImageView({this.bytes, this.url, required this.size});
  final Uint8List? bytes;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Image.memory(bytes!,
          width: size, height: size, fit: BoxFit.cover);
    }
    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.teal,
              ),
            ),
      errorBuilder: (_, __, ___) => const _Placeholder(
        size: 0,
        color: AppColors.teal,
      ),
    );
  }
}

// ─── Placeholder ──────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    this.initials,
    required this.size,
    required this.color,
  });

  final String? initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.12);

    return Container(
      color: bg,
      child: initials != null
          ? Center(
              child: Text(
                initials!.toUpperCase().characters.take(2).string,
                style: TextStyle(
                  fontSize: size > 0 ? size * 0.32 : 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.person_rounded,
                size: size > 0 ? size * 0.5 : 24,
                color: color.withValues(alpha: 0.6),
              ),
            ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: Colors.white),
    );
  }
}
