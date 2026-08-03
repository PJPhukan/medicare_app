import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/extensions/context_extensions.dart';

// ─── Base card ────────────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.hasShadow = false,
    this.margin,
    this.raised = false,
    this.effectColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  /// Opt in to an outer drop shadow. Off by default — depth comes from the
  /// corner-lit surface gradient, which keeps the card flush with the page.
  final bool hasShadow;
  final EdgeInsetsGeometry? margin;

  /// Deepen the corner lighting — for the one hero card on a screen.
  final bool raised;

  /// Tints the lit corner — e.g. `AppColors.teal` for an accent card.
  /// Defaults to a neutral white sheen.
  final Color? effectColor;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final br  = borderRadius ?? AppBorderRadius.xlAll;
    final bg  = color ?? context.cardBg;
    final bc  = borderColor ?? context.cardEdge;

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.cardSheen(bg, isDark,
            color: effectColor, strong: raised),
        borderRadius: br,
        border: Border.all(color: bc),
        boxShadow: hasShadow
            ? AppShadows.softCard(isDark, color: effectColor)
            : const [],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (margin != null) card = Padding(padding: margin!, child: card);

    if (onTap != null) {
      return _TappableCard(borderRadius: br, onTap: onTap!, child: card);
    }
    return card;
  }
}

class _TappableCard extends StatefulWidget {
  const _TappableCard({required this.child, required this.onTap, required this.borderRadius});
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1, end: AppAnimations.pressScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
    this.subtitle,
  });

  final String label;
  final String value;
  final Widget? icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return AppCard(
      onTap: onTap,
      // Match the sheen to this card's accent instead of the default teal.
      effectColor: c,
      color: Color.fromRGBO(
        c.r.round(), c.g.round(), c.b.round(), 0.06,
      ),
      borderColor: Color.fromRGBO(
        c.r.round(), c.g.round(), c.b.round(), 0.2,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(c.r.round(), c.g.round(), c.b.round(), 0.15),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconTheme(data: IconThemeData(size: 18, color: c), child: icon!),
                ),
              ),
            ),
          Text(value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: c,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle!, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
            ),
        ],
      ),
    );
  }
}
