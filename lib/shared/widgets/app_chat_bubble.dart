import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_typography.dart';

enum BubbleType { sent, received }

class AppChatBubble extends StatelessWidget {
  const AppChatBubble({
    super.key,
    required this.message,
    required this.type,
    this.timestamp,
    this.status,
    this.imageUrl,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  final String message;
  final BubbleType type;
  final String? timestamp;
  final MessageStatus? status;
  final String? imageUrl;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  bool get isSent => type == BubbleType.sent;

  @override
  Widget build(BuildContext context) {
    final sentRadius = BorderRadius.only(
      topLeft:     const Radius.circular(18),
      topRight:    Radius.circular(isFirstInGroup ? 18 : 4),
      bottomLeft:  const Radius.circular(18),
      bottomRight: Radius.circular(isLastInGroup ? 4 : 18),
    );
    final receivedRadius = BorderRadius.only(
      topLeft:     Radius.circular(isFirstInGroup ? 18 : 4),
      topRight:    const Radius.circular(18),
      bottomLeft:  Radius.circular(isLastInGroup ? 4 : 18),
      bottomRight: const Radius.circular(18),
    );

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isSent ? AppColors.teal : AppColors.dark700,
                borderRadius: isSent ? sentRadius : receivedRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  message,
                  style: AppTypography.bodyMd.copyWith(
                    color: isSent ? AppColors.textInverse : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (timestamp != null || status != null)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (timestamp != null)
                      Text(timestamp!, style: AppTypography.bodyXs),
                    if (status != null) ...[
                      const SizedBox(width: 4),
                      _StatusIcon(status: status!),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum MessageStatus { sending, sent, delivered, seen }

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MessageStatus.sending   => const SizedBox(width: 10, height: 10,
          child: CircularProgressIndicator(strokeWidth: 1.2, color: AppColors.textHint)),
      MessageStatus.sent      => const Icon(Icons.check_rounded, size: 12, color: AppColors.textHint),
      MessageStatus.delivered => const Icon(Icons.done_all_rounded, size: 12, color: AppColors.textHint),
      MessageStatus.seen      => const Icon(Icons.done_all_rounded, size: 12, color: AppColors.teal),
    };
  }
}

// ─── Chat input bar ───────────────────────────────────────────────────────────

class AppChatInput extends StatefulWidget {
  const AppChatInput({
    super.key,
    required this.onSend,
    this.onAttach,
    this.hint,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;
  final String? hint;

  @override
  State<AppChatInput> createState() => _AppChatInputState();
}

class _AppChatInputState extends State<AppChatInput> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.trim().isNotEmpty));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.dark800,
        border: Border(top: BorderSide(color: AppColors.dark600)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 12, right: 12,
          top: 10,
          bottom: MediaQuery.paddingOf(context).bottom + 10,
        ),
        child: Row(
          children: [
            if (widget.onAttach != null)
              IconButton(
                onPressed: widget.onAttach,
                icon: const Icon(Icons.attach_file_rounded, size: 20, color: AppColors.textHint),
              ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: AppTypography.bodyMd,
                cursorColor: AppColors.teal,
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Type a message…',
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.dark700,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.xxlAll,
                    borderSide: const BorderSide(color: AppColors.dark600),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.xxlAll,
                    borderSide: const BorderSide(color: AppColors.dark600),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.xxlAll,
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: _hasText ? 1 : 0.7,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: _hasText ? _send : null,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _hasText ? AppColors.teal : AppColors.dark600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, size: 18, color: AppColors.textInverse),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
