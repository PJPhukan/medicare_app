import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../providers/connections_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';

String _timeAgo(String isoStr) {
  final dt = DateTime.tryParse(isoStr);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return '1 day ago';
  return '${diff.inDays} days ago';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class IncomingRequestsScreen extends ConsumerWidget {
  const IncomingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Connections');
    }
    final requests = ref.watch(connectionsProvider).incomingRequests;

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
              leading: AppIconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: AppText.h2(AppStrings.incomingRequests),
                background: Container(color: context.bg),
              ),
            ),
            if (requests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.person_add_rounded,
                    title: 'No incoming requests',
                    subtitle: 'When professionals send you connection requests, they\'ll appear here.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final req = requests[i];
                      return _RequestCard(
                        request: req,
                        onAccept: () => _accept(context, ref, req.id),
                        onDecline: () => _decline(context, ref, req),
                      );
                    },
                    childCount: requests.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref, String id) async {
    await ref.read(connectionsProvider.notifier).acceptRequest(id);
    if (!context.mounted) return;
    AppSnackbar.success(context, AppStrings.connectionAccepted);
  }

  Future<void> _decline(BuildContext context, WidgetRef ref, ConnectionRequestEntity req) async {
    final ok = await AppDialog.confirm(
      context,
      title: AppStrings.declineRequest,
      message: 'Decline connection request from ${req.sender.name}?',
      confirmLabel: AppStrings.declineRequest,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (ok == true && context.mounted) {
      await ref.read(connectionsProvider.notifier).declineRequest(req.id);
      if (!context.mounted) return;
      AppSnackbar.info(context, AppStrings.requestDeclined);
    }
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ConnectionRequestEntity request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({required this.request, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final name = request.sender.name;
    final ago = _timeAgo(request.createdAt);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: name, size: AppAvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: AppText.bodyMd(name, fontWeight: FontWeight.w700),
              ),
              if (ago.isNotEmpty)
                AppText.bodyXs(ago, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  label: AppStrings.declineRequest,
                  color: AppColors.error,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.primary(
                  label: AppStrings.acceptRequest,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
