import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'app_base_button.dart';

/// Button that manages its own async loading state.
///
/// Pass an async [onPressed] — the button shows a spinner while the future
/// is in-flight and re-enables itself when it completes (or throws).
///
/// ```dart
/// AppLoadingButton(
///   label: 'Submit',
///   onPressed: () async {
///     await api.submitForm(data);
///   },
/// )
/// ```
class AppLoadingButton extends StatefulWidget {
  const AppLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
    this.foregroundColor,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.isFullWidth = true,
    this.enabled = true,
    this.padding,
  });

  final String label;

  /// Optional label shown while loading (e.g. "Saving…"). Falls back to [label].
  final String? loadingLabel;

  final Future<void> Function() onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? color;
  final Color? foregroundColor;
  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppLoadingButton> createState() => _AppLoadingButtonState();
}

class _AppLoadingButtonState extends State<AppLoadingButton> {
  bool _loading = false;

  Future<void> _handle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppColors.teal;
    return AppBaseButton(
      label: _loading && widget.loadingLabel != null
          ? widget.loadingLabel!
          : widget.label,
      onPressed: widget.enabled && !_loading ? _handle : null,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      backgroundColor: bg,
      foregroundColor: widget.foregroundColor ?? AppColors.textInverse,
      isLoading: _loading,
      size: widget.size,
      borderRadius: widget.borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: widget.isFullWidth,
      enabled: widget.enabled,
      padding: widget.padding,
      shadow: AppShadows.button,
    );
  }
}
