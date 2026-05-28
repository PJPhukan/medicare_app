import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Standard app bar used across all screens.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.showBack = true,
    this.backgroundColor,
    this.foregroundColor,
    this.onBack,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.bg;
    final fg = foregroundColor ?? context.primaryText;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      systemOverlayStyle: context.overlayStyle,
      leading: leading ?? (showBack && Navigator.canPop(context)
          ? _BackButton(color: fg, onBack: onBack ?? () => Navigator.of(context).pop())
          : null),
      title: titleWidget ?? (title != null
          ? Text(title!, style: AppTypography.h3.copyWith(color: fg))
          : null),
      actions: actions != null
          ? [...actions!, const SizedBox(width: 4)]
          : null,
      bottom: bottom,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color, required this.onBack});
  final Color color;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: color),
      onPressed: onBack,
      tooltip: 'Back',
    );
  }
}

// ─── Sliver app bar ───────────────────────────────────────────────────────────

class AppSliverAppBar extends StatelessWidget {
  const AppSliverAppBar({
    super.key,
    this.title,
    this.expandedTitle,
    this.actions,
    this.flexibleSpace,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.onBack,
  });

  final String? title;
  final Widget? expandedTitle;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.bg,
      foregroundColor: context.primaryText,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null ? Text(title!, style: AppTypography.h3) : null,
      actions: actions,
      flexibleSpace: flexibleSpace ?? (expandedTitle != null
          ? FlexibleSpaceBar(
              background: expandedTitle,
              collapseMode: CollapseMode.parallax,
            )
          : null),
    );
  }
}
