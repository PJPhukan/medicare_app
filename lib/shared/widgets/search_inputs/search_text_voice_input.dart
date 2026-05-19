import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Pill-shaped search input with both text entry and a voice/mic button.
///
/// Wire [onMicTap] to a speech-to-text package. While recording, pass
/// [isRecording] = true and update [controller] text with the live
/// transcription. The widget handles all visual state automatically.
class AppSearchTextVoiceInput extends StatefulWidget {
  const AppSearchTextVoiceInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onMicTap,
    this.isRecording = false,
    this.enabled = true,
    this.autofocus = false,
    this.backgroundColor,
    this.borderColor,
    this.micColor,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  /// Called when the user taps the mic button.
  /// Toggle your STT recording here and flip [isRecording] accordingly.
  final VoidCallback? onMicTap;

  /// Set to true while voice recording is active. The mic icon turns red
  /// and a pulsing ring animates around it.
  final bool isRecording;

  final bool enabled;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? micColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppSearchTextVoiceInput> createState() =>
      _AppSearchTextVoiceInputState();
}

class _AppSearchTextVoiceInputState extends State<AppSearchTextVoiceInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final AnimationController _pulse;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(_onTextChange);

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  void _onTextChange() {
    final has = _ctrl.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void didUpdateWidget(AppSearchTextVoiceInput old) {
    super.didUpdateWidget(old);
    if (widget.isRecording && !old.isRecording) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isRecording && old.isRecording) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChange);
    if (widget.controller == null) _ctrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final micColor  = widget.micColor ?? AppColors.teal;

    final bg = widget.backgroundColor ??
        (isDark ? context.inputBg : const Color(0xFFF1F5F9));
    final borderCol = widget.borderColor ??
        (widget.isRecording
            ? AppColors.error
            : (isDark ? context.borderCol : const Color(0xFFE2E8F0)));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(
          color: borderCol,
          width: widget.isRecording ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // ── Search icon ──────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),

          // ── Text field ───────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: widget.textStyle ??
                  AppTypography.bodyMd.copyWith(
                    color: context.primaryText,
                    fontStyle: widget.isRecording
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
              decoration: InputDecoration(
                hintText: widget.isRecording
                    ? 'Listening…'
                    : (widget.hint ?? 'Search…'),
                hintStyle: widget.hintStyle ??
                    AppTypography.bodyMd.copyWith(
                      color: widget.isRecording
                          ? AppColors.error.withValues(alpha: 0.7)
                          : AppColors.textHint,
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              ),
            ),
          ),

          // ── Clear button (shown when text exists and not recording) ───────
          if (_hasText && !widget.isRecording)
            GestureDetector(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // ── Mic button ───────────────────────────────────────────────────
          GestureDetector(
            onTap: widget.enabled ? widget.onMicTap : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _MicButton(
                isRecording: widget.isRecording,
                pulseController: _pulse,
                color: micColor,
                enabled: widget.enabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mic button with pulse ring ────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isRecording,
    required this.pulseController,
    required this.color,
    required this.enabled,
  });

  final bool isRecording;
  final AnimationController pulseController;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconColor = !enabled
        ? AppColors.textHint
        : isRecording
            ? Colors.white
            : color;

    final bgColor = !enabled
        ? AppColors.textHint.withValues(alpha: 0.1)
        : isRecording
            ? AppColors.error
            : color.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, child) {
        final pulseRadius = isRecording ? (4.0 * pulseController.value) : 0.0;
        return Container(
          width: 36 + pulseRadius * 2,
          height: 36 + pulseRadius * 2,
          margin: EdgeInsets.all(4 - pulseRadius.clamp(0, 4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: isRecording
                ? [
                    BoxShadow(
                      color: AppColors.error
                          .withValues(alpha: 0.35 - pulseController.value * 0.25),
                      blurRadius: 8 + pulseRadius * 3,
                      spreadRadius: pulseRadius,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            size: 18,
            color: iconColor,
          ),
        );
      },
    );
  }
}
