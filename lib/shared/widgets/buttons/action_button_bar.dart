import 'package:flutter/material.dart';
import 'app_base_button.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'outline_button.dart';
import 'ghost_button.dart';

/// A pre-built row or column of action buttons, handling spacing and layout.
///
/// Commonly used at the bottom of forms, modals, and confirm dialogs.
///
/// ```dart
/// // Confirm / Cancel row (primary + secondary)
/// AppActionButtonBar(
///   primary: AppActionBtn(label: 'Save', onPressed: _save),
///   secondary: AppActionBtn(label: 'Cancel', onPressed: Navigator.of(context).pop),
/// )
///
/// // Stacked full-width buttons
/// AppActionButtonBar.column(
///   primary: AppActionBtn(label: 'Delete Account', onPressed: _delete),
///   secondary: AppActionBtn(label: 'Keep Account', onPressed: _cancel),
/// )
/// ```
class AppActionButtonBar extends StatelessWidget {
  const AppActionButtonBar({
    super.key,
    required this.primary,
    this.secondary,
    this.tertiary,
    this.direction = Axis.horizontal,
    this.spacing = 12,
    this.reversePrimary = false,
    this.padding,
  });

  const AppActionButtonBar.column({
    super.key,
    required this.primary,
    this.secondary,
    this.tertiary,
    this.spacing = 10,
    this.reversePrimary = false,
    this.padding,
  })  : direction = Axis.vertical;

  final AppActionBtn primary;
  final AppActionBtn? secondary;
  final AppActionBtn? tertiary;

  /// [Axis.horizontal] — buttons side by side.
  /// [Axis.vertical]   — buttons stacked full-width.
  final Axis direction;

  final double spacing;

  /// When true, places the secondary button before the primary.
  final bool reversePrimary;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: direction == Axis.horizontal
          ? Row(children: _intersperse(buttons, SizedBox(width: spacing)))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _intersperse(buttons, SizedBox(height: spacing)),
            ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    Widget make(AppActionBtn btn, {bool isPrimary = false}) {
      final isCol = direction == Axis.vertical;
      return switch (btn.style) {
        AppActionBtnStyle.primary => Expanded(
            child: AppPrimaryButton(
              label: btn.label,
              onPressed: btn.onPressed,
              leadingIcon: btn.leadingIcon,
              trailingIcon: btn.trailingIcon,
              size: btn.size,
              isFullWidth: isCol,
              isLoading: btn.isLoading,
              enabled: btn.enabled,
            ),
          ),
        AppActionBtnStyle.secondary => Expanded(
            child: AppSecondaryButton(
              label: btn.label,
              onPressed: btn.onPressed,
              leadingIcon: btn.leadingIcon,
              trailingIcon: btn.trailingIcon,
              size: btn.size,
              isFullWidth: isCol,
              isLoading: btn.isLoading,
              enabled: btn.enabled,
            ),
          ),
        AppActionBtnStyle.outline => Expanded(
            child: AppOutlineButton(
              label: btn.label,
              onPressed: btn.onPressed,
              leadingIcon: btn.leadingIcon,
              trailingIcon: btn.trailingIcon,
              size: btn.size,
              isFullWidth: isCol,
              isLoading: btn.isLoading,
              enabled: btn.enabled,
            ),
          ),
        AppActionBtnStyle.ghost => Expanded(
            child: AppGhostButton(
              label: btn.label,
              onPressed: btn.onPressed,
              leadingIcon: btn.leadingIcon,
              trailingIcon: btn.trailingIcon,
              size: btn.size,
              isFullWidth: isCol,
              isLoading: btn.isLoading,
              enabled: btn.enabled,
            ),
          ),
      };
    }

    final pBtn = make(primary, isPrimary: true);
    final sBtn = secondary != null ? make(secondary!) : null;
    final tBtn = tertiary != null ? make(tertiary!) : null;

    final ordered = [
      if (reversePrimary) ...[
        if (sBtn != null) sBtn,
        pBtn,
      ] else ...[
        pBtn,
        if (sBtn != null) sBtn,
      ],
      if (tBtn != null) tBtn,
    ];

    return ordered;
  }

  List<Widget> _intersperse(List<Widget> items, Widget sep) {
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) result.add(sep);
    }
    return result;
  }
}

// ─── Action button descriptor ─────────────────────────────────────────────────

enum AppActionBtnStyle { primary, secondary, outline, ghost }

class AppActionBtn {
  const AppActionBtn({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.style = AppActionBtnStyle.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppActionBtnStyle style;
  final AppButtonSize size;
  final bool isLoading;
  final bool enabled;
}
