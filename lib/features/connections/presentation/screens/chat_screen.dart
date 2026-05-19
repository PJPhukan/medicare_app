import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

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

class ChatScreen extends StatefulWidget {
  final String connectionId;
  final String professionalName;
  final String professionalSpecialty;
  final Color avatarColor;

  const ChatScreen({
    super.key,
    required this.connectionId,
    required this.professionalName,
    required this.professionalSpecialty,
    required this.avatarColor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = _buildMockMessages();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  String get _initials {
    final parts = widget.professionalName.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

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

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(_Msg(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isMine: true,
        sentAt: DateTime.now(),
      ));
      _inputCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: true));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _sending = false);
    });
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
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.messageReported, style: AppTypography.bodySm),
              backgroundColor: context.inputBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────────
            _ChatHeader(
              initials: _initials,
              avatarColor: widget.avatarColor,
              professionalName: widget.professionalName,
              specialty: widget.professionalSpecialty,
              onBack: () => Navigator.pop(context),
              onRate: _showRatingSheet,
            ),

            // ── Messages ──────────────────────────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 52, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noMessagesYetSayHi,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
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

            // ── Input bar ─────────────────────────────────────────────────────
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
  final String initials;
  final Color avatarColor;
  final String professionalName;
  final String specialty;
  final VoidCallback onBack;
  final VoidCallback onRate;

  _ChatHeader({
    required this.initials,
    required this.avatarColor,
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
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textSecondary),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor.withValues(alpha: 0.35)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professionalName,
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  specialty,
                  style: AppTypography.bodyXs.copyWith(color: avatarColor),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                  const SizedBox(width: 5),
                  Text(
                    AppStrings.rateProfessional,
                    style: AppTypography.labelXs.copyWith(color: AppColors.amber, fontSize: 11),
                  ),
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
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isMine ? AppColors.teal : context.cardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(msg.isMine ? 18 : 4),
                    bottomRight: Radius.circular(msg.isMine ? 4 : 18),
                  ),
                  border: msg.isMine ? null : Border.all(color: context.borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: AppTypography.bodySm.copyWith(
                        color: msg.isMine ? context.bg : context.primaryText,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      _fmtTime(msg.sentAt),
                      style: AppTypography.bodyXs.copyWith(
                        color: msg.isMine
                            ? context.bg.withValues(alpha: 0.55)
                            : AppColors.textHint,
                        fontSize: 10,
                      ),
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

  _InputBar({
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
            child: Container(
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                maxLength: 2000,
                style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  counterText: '',
                ),
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) {
              final canSend = v.text.trim().isNotEmpty && !sending;
              return GestureDetector(
                onTap: canSend ? onSend : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
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
  bool _submitting = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _submitting = true);
    await Future.delayed(Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.ratingSubmitted, style: AppTypography.bodySm),
        backgroundColor: context.inputBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          Text(AppStrings.rateProfessional, style: AppTypography.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(widget.professionalName, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Stars
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
          SizedBox(height: 20),

          // Review text
          Container(
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: TextField(
              controller: _reviewCtrl,
              maxLines: 3,
              maxLength: 500,
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: AppStrings.shareExperienceHint,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _stars > 0 && !_submitting ? _submit : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _stars > 0 ? AppColors.teal : context.inputBg,
                  borderRadius: AppBorderRadius.lgAll,
                ),
                alignment: Alignment.center,
                child: _submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.bg),
                      )
                    : Text(
                        AppStrings.submitRating,
                        style: AppTypography.buttonMd.copyWith(
                          color: _stars > 0 ? context.bg : AppColors.textHint,
                        ),
                      ),
              ),
            ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Text(AppStrings.reportMessage, style: AppTypography.h3.copyWith(fontSize: 17)),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: context.borderCol),
              ),
              child: Text(
                '"$messageText"',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 14),
            Text(AppStrings.reasonOptional, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
            SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: TextField(
                controller: reasonCtrl,
                maxLines: 3,
                maxLength: 200,
                style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: AppStrings.reportReasonHint,
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: AppBorderRadius.lgAll),
                  alignment: Alignment.center,
                  child: Text(AppStrings.submitReport, style: AppTypography.buttonMd.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
