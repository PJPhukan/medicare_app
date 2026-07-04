import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../message/presentation/providers/message_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/utils/logger.dart';

// ─── Message model ────────────────────────────────────────────────────────────

class _Msg {
  final String id;
  final String text;
  final bool isMine;
  final DateTime sentAt;

  const _Msg({
    required this.id,
    required this.text,
    required this.isMine,
    required this.sentAt,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

List<_Msg> _buildMockMessages() {
  final now = DateTime.now();
  return [
    _Msg(id: 'm1', text: 'Hello! I reviewed your recent vitals. Things look mostly stable.', isMine: false, sentAt: now.subtract(const Duration(hours: 2, minutes: 15))),
    _Msg(id: 'm2', text: 'Thank you, Doctor. I had some chest discomfort yesterday evening.', isMine: true, sentAt: now.subtract(const Duration(hours: 2, minutes: 10))),
    _Msg(id: 'm3', text: 'That can happen with mild exertion. How long did it last and did it radiate anywhere?', isMine: false, sentAt: now.subtract(const Duration(hours: 2, minutes: 5))),
    _Msg(id: 'm4', text: 'Maybe 5 minutes. Just in the chest, no radiation. It went away after I sat down.', isMine: true, sentAt: now.subtract(const Duration(hours: 2))),
    _Msg(id: 'm5', text: 'Good that it resolved. I would suggest avoiding strenuous activity for a few days. Monitor your BP twice daily and share the readings with me.', isMine: false, sentAt: now.subtract(const Duration(hours: 1, minutes: 45))),
    _Msg(id: 'm6', text: 'Understood. Should I be worried about my blood pressure readings?', isMine: true, sentAt: now.subtract(const Duration(hours: 1, minutes: 30))),
    _Msg(id: 'm7', text: 'Your blood pressure readings look elevated this week. Please rest and recheck after 30 minutes of lying down.', isMine: false, sentAt: now.subtract(const Duration(hours: 1))),
  ];
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerStatefulWidget {
  final String connectionId;
  final String professionalName;
  final String professionalSpecialty;

  const ChatScreen({
    super.key,
    required this.connectionId,
    required this.professionalName,
    required this.professionalSpecialty,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messages = _buildMockMessages();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    if (!_scrollCtrl.hasClients) return;
    if (animate) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _inputCtrl.clear();
    final optimistic = _Msg(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isMine: true,
      sentAt: DateTime.now(),
    );
    AppLogger.i('Message send → conn:${widget.connectionId}', tag: 'Chat');
    setState(() { _sending = true; _messages.add(optimistic); });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: true));
    try {
      await ref.read(sendMessageProvider).call(
        conversationId: widget.connectionId,
        body: text,
      );
      AppLogger.i('Message sent ✓', tag: 'Chat');
    } on Exception catch (e) {
      AppLogger.e('Message send failed', tag: 'Chat', error: e);
      if (!mounted) return;
      _messages.remove(optimistic);
    }
    if (mounted) setState(() => _sending = false);
  }

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingSheet(professionalName: widget.professionalName),
    );
  }

  void _showReportDialog(_Msg msg) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportSheet(
        messageText: msg.text,
        reasonCtrl: reasonCtrl,
        onSubmit: () {
          ctx.pop();
          AppSnackbar.info(context, AppStrings.messageReported);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Chat');
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _ChatHeader(
              professionalName: widget.professionalName,
              specialty: widget.professionalSpecialty,
              onBack: () => context.pop(),
              onRate: _showRatingSheet,
            ),

            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: AppEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: AppStrings.noMessagesYetSayHi,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _MessageBubble(
                        msg: _messages[i],
                        onReport: _showReportDialog,
                      ),
                    ),
            ),

            _InputBar(
              controller: _inputCtrl,
              sending: _sending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat header ──────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final String professionalName;
  final String specialty;
  final VoidCallback onBack;
  final VoidCallback onRate;

  const _ChatHeader({
    required this.professionalName,
    required this.specialty,
    required this.onBack,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(4, topPad + 8, 12, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(bottom: BorderSide(color: context.borderCol)),
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: onBack,
          ),
          AppAvatar(name: professionalName, size: AppAvatarSize.sm),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelMd(
                  professionalName,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (specialty.isNotEmpty)
                  AppText.bodyXs(specialty, color: AppColors.teal),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRate,
            child: AppContainer.tinted(
              color: AppColors.amber,
              borderRadius: AppBorderRadius.lgAll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                  const SizedBox(width: 5),
                  AppText.labelXs(AppStrings.rateProfessional, color: AppColors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  final void Function(_Msg) onReport;

  const _MessageBubble({required this.msg, required this.onReport});

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMine) ...[
            GestureDetector(
              onTap: () => onReport(msg),
              child: const Padding(
                padding: EdgeInsets.only(right: 6, bottom: 4),
                child: Icon(Icons.flag_outlined, size: 14, color: AppColors.textHint),
              ),
            ),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: msg.isMine ? null : () => onReport(msg),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isMine ? AppColors.teal : context.cardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(msg.isMine ? 18 : 4),
                    bottomRight: Radius.circular(msg.isMine ? 4 : 18),
                  ),
                  border: msg.isMine ? null : Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySm(
                      msg.text,
                      color: msg.isMine ? context.bg : context.primaryText,
                    ),
                    const SizedBox(height: 3),
                    AppText.bodyXs(
                      _fmtTime(msg.sentAt),
                      color: msg.isMine
                          ? context.bg.withValues(alpha: 0.55)
                          : AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;
    final extraPad = keyboardPad > 0 ? 8.0 : bottomPad + 8.0;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, extraPad),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hint: AppStrings.typeMessage,
              maxLines: 4,
              minLines: 1,
              maxLength: 2000,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) {
              final canSend = v.text.trim().isNotEmpty && !sending;
              return GestureDetector(
                onTap: canSend ? onSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: canSend ? AppColors.teal : context.inputBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: canSend ? AppColors.teal : context.borderCol,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: sending
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.bg),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: canSend ? context.bg : AppColors.textHint,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Rating bottom sheet ──────────────────────────────────────────────────────

class _RatingSheet extends StatefulWidget {
  final String professionalName;
  const _RatingSheet({required this.professionalName});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _stars = 0;
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_stars == 0) return;
    context.pop();
    AppSnackbar.success(context, AppStrings.ratingSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          AppText.h3(AppStrings.rateProfessional),
          const SizedBox(height: 4),
          AppText.bodySm(widget.professionalName, color: AppColors.textSecondary),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final n = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _stars = n),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: _stars >= n ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      _stars >= n ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: _stars >= n ? AppColors.amber : AppColors.textHint,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          AppTextField(
            controller: _reviewCtrl,
            hint: AppStrings.shareExperienceHint,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          AppButton(
            variant: AppButtonVariant.primary,
            label: AppStrings.submitRating,
            isFullWidth: true,
            onPressed: _stars > 0 ? _submit : null,
          ),
        ],
      ),
    );
  }
}

// ─── Report bottom sheet ──────────────────────────────────────────────────────

class _ReportSheet extends StatelessWidget {
  final String messageText;
  final TextEditingController reasonCtrl;
  final VoidCallback onSubmit;

  const _ReportSheet({
    required this.messageText,
    required this.reasonCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
              ),
            ),
            AppText.h3(AppStrings.reportMessage),
            const SizedBox(height: 14),
            AppContainer(
              color: context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
              padding: const EdgeInsets.all(12),
              child: AppText.bodySm(
                '"$messageText"',
                color: AppColors.textSecondary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 14),
            AppText.bodyXs(AppStrings.reasonOptional, color: AppColors.textHint),
            const SizedBox(height: 6),
            AppTextField(
              controller: reasonCtrl,
              hint: AppStrings.reportReasonHint,
              maxLines: 3,
              minLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            AppButton(
              variant: AppButtonVariant.danger,
              label: AppStrings.submitReport,
              isFullWidth: true,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
