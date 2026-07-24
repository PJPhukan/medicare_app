import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showDragHandle = true,
    this.maxHeight,
    this.padding,
    this.headerAction,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showDragHandle;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final Widget? headerAction;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    String? subtitle,
    bool showDragHandle = true,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    Widget? headerAction,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        showDragHandle: showDragHandle,
        maxHeight: maxHeight,
        padding: padding,
        headerAction: headerAction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? screenH * 0.92),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.dividerCol,
                      borderRadius: AppBorderRadius.pill,
                    ),
                  ),
                ),
              ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!,
                              style: AppTypography.h3
                                  .copyWith(color: context.primaryText)),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(subtitle!,
                                  style: AppTypography.bodySm
                                      .copyWith(color: context.secondaryText)),
                            ),
                        ],
                      ),
                    ),
                    if (headerAction != null) headerAction!,
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}
