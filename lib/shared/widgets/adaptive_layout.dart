import 'package:flutter/material.dart';

const double _kTabletBreakpoint = 600;
const double _kDesktopBreakpoint = 1024;

/// Returns true when the screen is tablet-width or wider.
bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= _kTabletBreakpoint;

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;

/// Renders [mobile] on phones, [tablet] (fallback: [mobile]) on tablets+.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= _kDesktopBreakpoint && desktop != null) return desktop!;
    if (w >= _kTabletBreakpoint && tablet != null) return tablet!;
    return mobile;
  }
}

/// Splits into a master list + detail pane on tablets.
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 320,
  });

  final Widget master;
  final Widget detail;
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    if (isTablet(context)) {
      return Row(
        children: [
          SizedBox(width: masterWidth, child: master),
          const VerticalDivider(width: 1),
          Expanded(child: detail),
        ],
      );
    }
    return master;
  }
}

/// A two-column grid on tablets, single column on mobile.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 12,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= _kDesktopBreakpoint
        ? desktopColumns
        : w >= _kTabletBreakpoint
            ? tabletColumns
            : mobileColumns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    );
  }
}
