import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _Request {
  final String id;
  final String name;
  final String specialty;
  final Color avatarColor;
  final String message;
  final String timeAgo;

  const _Request({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarColor,
    required this.message,
    required this.timeAgo,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kRequests = [
  _Request(
    id: 'inc_1',
    name: 'Dr. Deepa Krishnan',
    specialty: 'Endocrinologist',
    avatarColor: AppColors.amber,
    message: 'Hi! I noticed your recent vitals and would like to help manage your condition.',
    timeAgo: '6 hours ago',
  ),
  _Request(
    id: 'inc_2',
    name: 'Dr. Meera Pillai',
    specialty: 'Dietitian',
    avatarColor: AppColors.green,
    message: 'I specialise in diabetes management and would love to help you with your nutrition plan.',
    timeAgo: '2 days ago',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({super.key});

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  final _requests = List<_Request>.from(_kRequests);

  void _accept(_Request r) {
    setState(() => _requests.remove(r));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.connectionAccepted, style: AppTypography.bodySm),
      backgroundColor: AppColors.teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
    ));
  }

  void _decline(_Request r) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.declineRequest, style: AppTypography.h3),
        content: Text('Decline connection request from ${r.name}?',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.declineRequest, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && mounted) {
        setState(() => _requests.remove(r));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.requestDeclined, style: AppTypography.bodySm),
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
                title: Text(AppStrings.incomingRequests, style: AppTypography.h2.copyWith(fontSize: 22)),
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
                          color: AppColors.teal.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_rounded, size: 36, color: AppColors.teal),
                      ),
                      const SizedBox(height: 20),
                      Text('No incoming requests', style: AppTypography.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'When professionals send you connection requests, they\'ll appear here.',
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
                    (_, i) => _RequestCard(
                      request: _requests[i],
                      onAccept: () => _accept(_requests[i]),
                      onDecline: () => _decline(_requests[i]),
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

class _RequestCard extends StatelessWidget {
  final _Request request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({required this.request, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.xlAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    ],
                  ),
                ),
                Text(request.timeAgo, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
              ],
            ),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.inputBg,
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Text(
                  '"${request.message}"',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDecline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                      ),
                      alignment: Alignment.center,
                      child: Text(AppStrings.declineRequest,
                          style: AppTypography.buttonSm.copyWith(color: AppColors.error)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: AppBorderRadius.lgAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(AppStrings.acceptRequest,
                          style: AppTypography.buttonSm.copyWith(color: AppColors.textInverse)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
