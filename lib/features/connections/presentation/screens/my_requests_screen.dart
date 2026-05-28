import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Connections');
    }
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
                title: AppText.h2(AppStrings.sentRequests),
                background: Container(color: context.bg),
              ),
            ),
            SliverFillRemaining(
              child: Center(
                child: AppEmptyState(
                  icon: Icons.send_rounded,
                  title: AppStrings.noRequestsYet,
                  subtitle: 'Browse professionals and send connection requests to get started.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
