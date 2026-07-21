import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../connections/domain/entities/connection_entity.dart';
import '../../../connections/presentation/providers/connections_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/network/connectivity_monitor.dart';

String _fmtDate(String isoStr) {
  final dt = DateTime.tryParse(isoStr);
  if (dt == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfessionalConnectionsScreen extends ConsumerStatefulWidget {
  const ProfessionalConnectionsScreen({super.key});

  @override
  ConsumerState<ProfessionalConnectionsScreen> createState() => _ProfessionalConnectionsScreenState();
}

class _ProfessionalConnectionsScreenState extends ConsumerState<ProfessionalConnectionsScreen> {
  bool _asPatient = true;

  void _openChat(ConnectionEntity conn) {
    context.push(
      AppRoutes.chat,
      extra: ChatArgs(
        connectionId: conn.id,
        professionalName: conn.connectedUser.name,
        professionalSpecialty: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Connections');
    }
    final connections = ref.watch(connectionsProvider).connections;
    final isLoading = ref.watch(connectionsProvider).isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: AppStrings.myConnections,
                subtitle: 'Your healthcare professionals',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _TabToggle(
                  asPatient: _asPatient,
                  onToggle: (v) => setState(() => _asPatient = v),
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.teal),
                ),
              )
            else if (connections.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: AppStrings.noConnectionsYet,
                    subtitle: AppStrings.browseProfessionals,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'ACTIVE CONNECTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...connections.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ConnectionCard(
                              conn: c, onChat: () => _openChat(c)),
                        )),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab toggle ───────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final bool asPatient;
  final ValueChanged<bool> onToggle;
  const _TabToggle({required this.asPatient, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          _Tab(
              label: AppStrings.asPatient,
              isActive: asPatient,
              onTap: () => onToggle(true)),
          _Tab(
              label: AppStrings.asProfessionalTab,
              isActive: !asPatient,
              onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal : Colors.transparent,
            borderRadius: AppBorderRadius.mdAll,
          ),
          child: AppText.labelSm(
            label,
            color: isActive ? context.bg : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Connection card ──────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final ConnectionEntity conn;
  final VoidCallback onChat;
  const _ConnectionCard({required this.conn, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final name = conn.connectedUser.name;
    final since = _fmtDate(conn.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(name: name, size: AppAvatarSize.sm),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText.labelMd(
                            name,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppContainer.tinted(
                          color: AppColors.teal,
                          borderRadius: AppBorderRadius.pill,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: AppText.labelXs('ACTIVE',
                              color: AppColors.teal,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (since.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      AppText.bodySm('${AppStrings.connectionStarted} $since',
                          color: context.secondaryText),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            variant: AppButtonVariant.primary,
            label: AppStrings.openChat,
            leading:
                const Icon(Icons.chat_bubble_outline_rounded, size: 14),
            isFullWidth: true,
            onPressed: onChat,
          ),
        ],
      ),
    );
  }
}
