import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../buttons/primary_button.dart';
import '../buttons/outline_button.dart';
import '../buttons/danger_button.dart';
import '../buttons/ghost_button.dart';

// ─── Confirm button style ─────────────────────────────────────────────────────

enum AppDialogAction { primary, danger }

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Shows an [AppBaseDialog] with the app's standard dialog settings.
///
/// ```dart
/// // Simple confirm
/// showAppDialog(
///   context: context,
///   title: 'Delete appointment',
///   child: Text('This cannot be undone.'),
///   confirmLabel: 'Delete',
///   confirmStyle: AppDialogAction.danger,
///   onConfirm: _delete,
/// );
///
/// // Custom footer
/// showAppDialog(
///   context: context,
///   title: 'Share',
///   footer: SocialButtons(...),
///   child: ShareContent(),
/// );
/// ```
Future<T?> showAppDialog<T>({
  required BuildContext context,
  String? title,
  String? subtitle,
  Widget? child,
  bool showClose = true,
  String? cancelLabel,
  String? confirmLabel,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  AppDialogAction confirmStyle = AppDialogAction.primary,
  Widget? footer,
  bool barrierDismissible = true,
  double maxWidth = 400,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black54,
    builder: (_) => AppBaseDialog(
      title: title,
      subtitle: subtitle,
      showClose: showClose,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onCancel: onCancel,
      onConfirm: onConfirm,
      confirmStyle: confirmStyle,
      footer: footer,
      maxWidth: maxWidth,
      child: child,
    ),
  );
}

// ─── Base dialog ──────────────────────────────────────────────────────────────

/// Layout shell for all app dialogs.
///
/// Provides:
/// - Optional header (title + subtitle + close button)
/// - Scrollable [child] content area
/// - Built-in cancel / confirm button row (or a custom [footer])
///
/// Use [showAppDialog] to display it, or embed in a [Builder] for manual
/// control over the [showDialog] call.
class AppBaseDialog extends StatelessWidget {
  const AppBaseDialog({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.showClose = true,
    this.onClose,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.confirmStyle = AppDialogAction.primary,
    this.footer,
    this.maxWidth = 400,
    this.contentPadding,
  });

  final String? title;
  final String? subtitle;

  /// Scrollable body — any widget or column of widgets.
  final Widget? child;

  /// × button in the top-right corner of the header.
  final bool showClose;

  /// Override the default [Navigator.pop] close action.
  final VoidCallback? onClose;

  // ── Built-in footer buttons ─────────────────────────────────────────────────

  /// Label for the secondary/cancel button. Hidden when null.
  final String? cancelLabel;

  /// Label for the primary/confirm button. Hidden when null.
  final String? confirmLabel;

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  /// Controls the confirm button colour: [AppDialogAction.primary] → teal,
  /// [AppDialogAction.danger] → red.
  final AppDialogAction confirmStyle;

  /// Replaces the built-in button row with a fully custom footer widget.
  final Widget? footer;

  /// Max dialog width. Default 400.
  final double maxWidth;

  /// Padding around [child]. Defaults to 20 h / 16 v.
  final EdgeInsets? contentPadding;

  bool get _hasHeader => title != null || showClose;
  bool get _hasBuiltInFooter =>
      footer == null && (cancelLabel != null || confirmLabel != null);

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = context.cardBg;
    final borderCol = context.borderCol;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppBorderRadius.lgAll,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ────────────────────────────────────────────────────
              if (_hasHeader) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style: AppTypography.h3.copyWith(fontSize: 17),
                              ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle!,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (showClose)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: onClose ?? () => Navigator.pop(context),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderCol),
              ],

              // ── Scrollable content ─────────────────────────────────────────
              if (child != null)
                Flexible(
                  child: SingleChildScrollView(
                    padding: contentPadding ??
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                    child: child,
                  ),
                ),

              // ── Footer ─────────────────────────────────────────────────────
              if (footer != null || _hasBuiltInFooter) ...[
                Divider(height: 1, color: borderCol),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: footer ?? _buildButtons(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final hasBoth = cancelLabel != null && confirmLabel != null;

    if (hasBoth) {
      return Row(
        children: [
          Expanded(
            child: AppOutlineButton(
              label: cancelLabel!,
              onPressed: onCancel ?? () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _confirmButton(context)),
        ],
      );
    }

    if (confirmLabel != null) {
      return _confirmButton(context);
    }

    return AppGhostButton(
      label: cancelLabel!,
      onPressed: onCancel ?? () => Navigator.pop(context),
    );
  }

  Widget _confirmButton(BuildContext context) {
    if (confirmStyle == AppDialogAction.danger) {
      return AppDangerButton(
        label: confirmLabel!,
        onPressed: onConfirm,
        isFullWidth: true,
      );
    }
    return AppPrimaryButton(
      label: confirmLabel!,
      onPressed: onConfirm,
      isFullWidth: true,
    );
  }
}
