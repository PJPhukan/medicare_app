import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _RequestStatus { pending, declined }

class _SentRequest {
  final String id;
  final String name;
  final String specialty;
  final Color avatarColor;
  final String sentAgo;
  final _RequestStatus status;

  const _SentRequest({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarColor,
    required this.sentAgo,
    required this.status,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kSentRequests = [
  _SentRequest(
    id: 'sr_1',
    name: 'Dr. Kavya Rao',
    specialty: 'Psychologist',
    avatarColor: AppColors.purple,
    sentAgo: '2 days ago',
    status: _RequestStatus.pending,
  ),
  _SentRequest(
    id: 'sr_2',
    name: 'Dr. Suresh Iyer',
    specialty: 'Dermatologist',
    avatarColor: AppColors.amber,
    sentAgo: '6 days ago',
    status: _RequestStatus.declined,
  ),
  _SentRequest(
    id: 'sr_3',
    name: 'Dr. Anita Bhatt',
    specialty: 'Gynaecologist',
    avatarColor: AppColors.pink,
    sentAgo: '1 week ago',
    status: _RequestStatus.pending,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _requests = List<_SentRequest>.from(_kSentRequests);

  void _cancel(_SentRequest r) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.cancelRequest, style: AppTypography.h3),
        content: Text('Cancel your request to ${r.name}?',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel Request', style: AppTypography.bodySm.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && mounted) {
        setState(() => _requests.remove(r));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.connectionCancelledMsg, style: AppTypography.bodySm),
          backgroundColor: context.inputBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: Text(AppStrings.sentRequests, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            if (_requests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, size: 36, color: AppColors.blue),
                      ),
                      const SizedBox(height: 20),
                      Text(AppStrings.noRequestsYet, style: AppTypography.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Browse professionals and send connection requests to get started.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SentCard(
                      request: _requests[i],
                      onCancel: _requests[i].status == _RequestStatus.pending
                          ? () => _cancel(_requests[i])
                          : null,
                    ),
                    childCount: _requests.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _SentCard extends StatelessWidget {
  final _SentRequest request;
  final VoidCallback? onCancel;

  const _SentCard({required this.request, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == _RequestStatus.pending;
    final (statusColor, statusLabel, statusIcon) = isPending
        ? (AppColors.amber, 'Pending', Icons.schedule_rounded)
        : (AppColors.error, 'Declined', Icons.cancel_outlined);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: request.avatarColor.withValues(alpha: 0.15),
            child: Text(
              request.name[0],
              style: AppTypography.h3.copyWith(color: request.avatarColor, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.name,
                    style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(request.specialty, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusLabel, style: AppTypography.bodyXs.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('· ${request.sentAgo}', style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Text(AppStrings.cancelRequest,
                    style: AppTypography.labelXs.copyWith(color: AppColors.error, letterSpacing: 0)),
              ),
            ),
        ],
      ),
    );
  }
}
