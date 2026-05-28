import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/connectivity_monitor.dart';
import 'offline_page.dart';

/// Wraps [child] and replaces it with [OfflinePage] when the device is offline.
///
/// Use for any screen that cannot meaningfully function without a network
/// connection (Community, Messages, Connections, Professionals, etc.).
///
/// ```dart
/// // In a screen's build():
/// return NetworkRequired(
///   featureName: 'Community',
///   child: _buildContent(),
/// );
/// ```
///
/// Set [showAppBar] to false when the child already owns a full Scaffold with
/// a back button (e.g. top-level tab screens).
class NetworkRequired extends ConsumerWidget {
  const NetworkRequired({
    super.key,
    required this.child,
    required this.featureName,
    this.showAppBar = true,
  });

  final Widget child;

  /// Shown in the offline message: "[featureName] needs an internet connection."
  final String featureName;

  /// Whether [OfflinePage] renders its own back-arrow app bar.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    if (isOnline) return child;
    return OfflinePage(featureName: featureName, showAppBar: showAppBar);
  }
}
