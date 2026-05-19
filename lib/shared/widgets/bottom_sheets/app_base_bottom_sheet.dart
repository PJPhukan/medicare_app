import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Shows an [AppBaseBottomSheet] with the app's standard modal settings.
///
/// Pass [child] for the scrollable body and [footer] for a sticky action area.
///
/// ```dart
/// showAppBottomSheet(
///   context: context,
///   title: 'Select option',
///   footer: AppPrimaryButton(label: 'Confirm', onPressed: _confirm),
///   child: MyContent(),
/// );
/// ```
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  String? subtitle,
  bool showDragHandle = true,
  bool showClose = true,
  Widget? footer,
  double maxHeightFactor = 0.92,
  bool isDismissible = true,
  bool enableDrag = true,
  EdgeInsets? contentPadding,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (_) => AppBaseBottomSheet(
      title: title,
      subtitle: subtitle,
      showDragHandle: showDragHandle,
      showClose: showClose,
      footer: footer,
      maxHeightFactor: maxHeightFactor,
      contentPadding: contentPadding,
      backgroundColor: backgroundColor,
      child: child,
    ),
  );
}

// ─── Base sheet ───────────────────────────────────────────────────────────────

/// Layout shell for all app bottom sheets.
///
/// Provides:
/// - Optional drag handle
/// - Optional header (title + subtitle + close button)
/// - Scrollable [child] content area
/// - Optional sticky [footer] (action buttons, etc.)
///
/// Use [showAppBottomSheet] to display it, or embed directly inside a
/// [DraggableScrollableSheet] for fully dynamic height.
class AppBaseBottomSheet extends StatelessWidget {
  const AppBaseBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showDragHandle = true,
    this.showClose = true,
    this.onClose,
    this.footer,
    this.maxHeightFactor = 0.92,
    this.contentPadding,
    this.backgroundColor,
  });

  /// Scrollable body — pass any widget or column of widgets.
  final Widget child;

  final String? title;
  final String? subtitle;

  /// Drag handle pill shown at the very top.
  final bool showDragHandle;

  /// × icon button in the header. Defaults to [Navigator.pop].
  final bool showClose;

  /// Override the default [Navigator.pop] close action.
  final VoidCallback? onClose;

  /// Sticky widget pinned above the system nav bar (e.g. action buttons).
  final Widget? footer;

  /// Max sheet height as a fraction of screen height. Default 0.92.
  final double maxHeightFactor;

  /// Padding around [child]. Defaults to 20 h / 16 v with extra bottom for
  /// safe area when no footer is present.
  final EdgeInsets? contentPadding;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = backgroundColor ?? (isDark ? context.cardBg : Colors.white);
    final borderCol  = isDark ? context.borderCol : const Color(0xFFE2E8F0);
    final bottomPad  = MediaQuery.paddingOf(context).bottom;
    final hasHeader  = title != null || showClose;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────────
          if (showDragHandle)
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: borderCol,
                  borderRadius: AppBorderRadius.pill,
                ),
              ),
            ),

          // ── Header ──────────────────────────────────────────────────────────
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
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
                          const SizedBox(height: 2),
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

          // ── Scrollable content ───────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: contentPadding ??
                  EdgeInsets.fromLTRB(
                    20, 16, 20,
                    footer != null ? 16 : bottomPad + 20,
                  ),
              child: child,
            ),
          ),

          // ── Sticky footer ────────────────────────────────────────────────────
          if (footer != null) ...[
            Divider(height: 1, color: borderCol),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
