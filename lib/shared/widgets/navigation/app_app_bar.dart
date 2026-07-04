import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/services/app_shell_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

// ─── Leading type ─────────────────────────────────────────────────────────────
enum AppBarLeading {
  none,
  menu,
  back,
  custom,
}

// ─── Shared config ────────────────────────────────────────────────────────────

/// All app-bar properties in one place.
/// Pass the same config to [AppAppBar] or [AppSliverAppBar].
class AppBarConfig {
  const AppBarConfig({
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading = AppBarLeading.menu,
    this.leadingWidget,
    this.onLeadingPressed,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? title;
  final String? subtitle;

  /// Replaces the [title]/[subtitle] column with a fully custom widget.
  final Widget? titleWidget;

  final AppBarLeading leading;

  /// Used when [leading] is [AppBarLeading.custom].
  final Widget? leadingWidget;

  /// Overrides the default tap handler (pop / openAppSidebar).
  final VoidCallback? onLeadingPressed;

  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

// ─── Shared builder helpers ───────────────────────────────────────────────────

Widget? _buildLeading(BuildContext context, AppBarConfig cfg, Color fg) {
  switch (cfg.leading) {
    case AppBarLeading.none:
      return null;

    case AppBarLeading.menu:
      return IconButton(
        icon: Icon(Icons.menu_rounded, size: 22, color: fg),
        onPressed: cfg.onLeadingPressed ?? openAppSidebar,
        tooltip: 'Menu',
        style: IconButton.styleFrom(backgroundColor: Colors.transparent),
      );

    case AppBarLeading.back:
      if (!context.canPop()) return null;
      return IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: fg),
        onPressed: cfg.onLeadingPressed ?? () => context.pop(),
        tooltip: 'Back',
      );

    case AppBarLeading.custom:
      return cfg.leadingWidget;
  }
}

Widget? _buildTitle(BuildContext context, AppBarConfig cfg, Color fg) {
  if (cfg.titleWidget != null) return cfg.titleWidget;
  if (cfg.title == null) return null;

  return Column(
    crossAxisAlignment:
        cfg.centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Flexible prevents long titles from overflowing
      AppText.h3(cfg.title!, color: fg),
      if (cfg.subtitle != null)
        AppText.bodySm(cfg.subtitle!, color: context.secondaryText),
    ],
  );
}

// ─── AppAppBar (non-sliver) ───────────────────────────────────────────────────

/// Standard app bar for screens using [Scaffold]'s `appBar` slot.
///
/// For scrollable screens inside a [CustomScrollView], use [AppSliverAppBar].
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.config,
  });

  final AppBarConfig config;

  @override
  Size get preferredSize => Size.fromHeight(
        AppSpacing.appBarHeight + (config.bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final bg = config.backgroundColor ?? context.bg;
    final fg = config.foregroundColor ?? context.primaryText;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: config.centerTitle,
      systemOverlayStyle: context.overlayStyle,
      toolbarHeight: AppSpacing.appBarHeight,
      leading: _buildLeading(context, config, fg),
      automaticallyImplyLeading: false,
      title: _buildTitle(context, config, fg),
      actions: config.actions,
      bottom: config.bottom,
    );
  }
}

// ─── AppSliverAppBar ──────────────────────────────────────────────────────────

/// Sliver app bar for screens using [CustomScrollView].
///
/// For screens using [Scaffold]'s `appBar` slot, use [AppAppBar].
class AppSliverAppBar extends StatelessWidget {
  const AppSliverAppBar({
    super.key,
    required this.config,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  final AppBarConfig config;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;

  /// Custom hero content shown when the bar is expanded.
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final bg = config.backgroundColor ?? context.bg;
    final fg = config.foregroundColor ?? context.primaryText;

    return SliverAppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      pinned: pinned,
      floating: floating,
      snap: snap,
      toolbarHeight: AppSpacing.appBarHeight,
      expandedHeight: flexibleSpace != null ? expandedHeight : null,
      leading: _buildLeading(context, config, fg),
      automaticallyImplyLeading: false,
      title: _buildTitle(context, config, fg),
      centerTitle: config.centerTitle,
      actions: config.actions,
      bottom: config.bottom,
      flexibleSpace: flexibleSpace != null
          ? FlexibleSpaceBar(
              background: flexibleSpace,
              collapseMode: CollapseMode.parallax,
            )
          : null,
    );
  }
}
