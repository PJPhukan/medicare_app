import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/message_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/utils/logger.dart';

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

class ThreadScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String contactName;

  const ThreadScreen({
    super.key,
    required this.conversationId,
    required this.contactName,
  });

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
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

  @override
  void dispose() {
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

  void _onSend(String text) {
    AppLogger.i('Message send → conv:${widget.conversationId}', tag: 'Message');
    final msg = _Msg(
      id: 'm${_messages.length + 1}',
      text: text,
      isMine: true,
      sentAt: DateTime.now(),
    );
    setState(() => _messages.add(msg));
    _scrollToBottom();
    ref.read(sendMessageProvider).call(
      conversationId: widget.conversationId,
      body: text,
    ).then((_) {
      AppLogger.i('Message sent ✓', tag: 'Message');
    }).catchError((e) {
      AppLogger.e('Message send failed', tag: 'Message', error: e);
      if (mounted) setState(() => _messages.remove(msg));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Messages');
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        resizeToAvoidBottomInset: true,
        appBar: AppAppBar(
          config: AppBarConfig(
            leading: AppBarLeading.back,
            titleWidget: Row(
              children: [
                AppAvatar(name: widget.contactName, size: AppAvatarSize.sm),
                const SizedBox(width: 10),
                AppText.labelMd(widget.contactName),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: context.borderCol),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: AppText.bodySm(
                        AppStrings.noMessagesYetSayHi,
                        color: AppColors.textHint,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        final prev = i > 0 ? _messages[i - 1] : null;
                        final showDate =
                            prev == null || !_sameDay(msg.sentAt, prev.sentAt);
                        final nextMsg =
                            i < _messages.length - 1 ? _messages[i + 1] : null;
                        final isLastInGroup = nextMsg == null ||
                            nextMsg.isMine != msg.isMine;

                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: _DateDivider(date: msg.sentAt),
                              ),
                            AppChatBubble(
                              message: msg.text,
                              type: msg.isMine
                                  ? BubbleType.sent
                                  : BubbleType.received,
                              timestamp: _fmtTime(msg.sentAt),
                              isLastInGroup: isLastInGroup,
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      },
                    ),
            ),
            AppChatInput(
              hint: AppStrings.typeMessage,
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Date divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
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
          child: AppText.bodyXs(label, color: AppColors.textHint),
        ),
        Expanded(child: Divider(color: context.borderCol, height: 1)),
      ],
    );
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
