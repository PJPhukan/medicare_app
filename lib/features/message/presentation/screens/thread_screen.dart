import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

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

// ─── Screen ───────────────────────────────────────────────────────────────────

class ThreadScreen extends StatefulWidget {
  final String contactName;
  final String contactRole;
  final Color avatarColor;

  const ThreadScreen({
    super.key,
    required this.contactName,
    required this.contactRole,
    this.avatarColor = AppColors.teal,
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [
    _Msg(
      id: 'm1',
      text: 'Hello! I have reviewed your vitals report. Your blood pressure looks elevated this week.',
      isMine: false,
      sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
    ),
    _Msg(
      id: 'm2',
      text: 'Yes, I noticed that too. I have been under a lot of stress lately.',
      isMine: true,
      sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
    ),
    _Msg(
      id: 'm3',
      text: 'I recommend reducing sodium intake and doing 20 minutes of light walking daily. Also, please take your Amlodipine consistently at the same time each day.',
      isMine: false,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _Msg(
      id: 'm4',
      text: 'Thank you, doctor. I will follow your advice. Should I log my readings more frequently?',
      isMine: true,
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    _Msg(
      id: 'm5',
      text: 'Yes, please log morning and evening readings for the next two weeks. That will help us track the trend.',
      isMine: false,
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        if (animated) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _inputCtrl.clear();
    setState(() {
      _sending = true;
      _messages.add(_Msg(
        id: 'm${_messages.length + 1}',
        text: text,
        isMine: true,
        sentAt: DateTime.now(),
      ));
    });
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: 400));
    if (mounted) setState(() => _sending = false);
  }

  String get _initials {
    final parts = widget.contactName.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: context.cardBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            ),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.avatarColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.avatarColor.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contactName, style: AppTypography.labelMd),
                  Text(
                    widget.contactRole,
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noMessagesYetSayHi,
                        style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        final prev = i > 0 ? _messages[i - 1] : null;
                        final showDate = prev == null ||
                            !_sameDay(msg.sentAt, prev.sentAt);
                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: _DateDivider(date: msg.sentAt),
                              ),
                            _Bubble(msg: msg),
                            SizedBox(height: 4),
                          ],
                        );
                      },
                    ),
            ),

            // Input bar
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
              decoration: BoxDecoration(
                color: context.cardBg,
                border: Border(top: BorderSide(color: context.borderCol)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        maxLines: null,
                        style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                        decoration: InputDecoration(
                          hintText: AppStrings.typeMessage,
                          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                    valueListenable: _inputCtrl,
                    builder: (_, v, __) {
                      final canSend = v.text.trim().isNotEmpty && !_sending;
                      return GestureDetector(
                        onTap: canSend ? _send : null,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: canSend ? AppColors.teal : context.inputBg,
                            borderRadius: AppBorderRadius.lgAll,
                          ),
                          alignment: Alignment.center,
                          child: _sending
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: context.bg,
                                    strokeWidth: 2,
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: msg.isMine
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.teal, Color(0xFF00B89C)],
                      )
                    : null,
                color: msg.isMine ? null : context.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMine ? 4 : 16),
                ),
                border: msg.isMine
                    ? null
                    : Border.all(color: context.borderCol),
              ),
              child: Text(
                msg.text,
                style: AppTypography.bodyMd.copyWith(
                  color: msg.isMine ? context.bg : context.primaryText,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _fmtTime(msg.sentAt),
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Date divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = now.subtract(Duration(days: 1));
    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
    final label = isToday
        ? AppStrings.today
        : isYesterday
            ? AppStrings.yesterdayLabel
            : _fmt(date);

    return Row(
      children: [
        Expanded(child: Divider(color: context.borderCol, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
          ),
        ),
        Expanded(child: Divider(color: context.borderCol, height: 1)),
      ],
    );
  }

  String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
