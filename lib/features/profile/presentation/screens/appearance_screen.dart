import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _darkMode = true;
  bool _compactMode = false;
  bool _reducedMotion = false;
  String _textSize = 'Medium';
  String _accentColor = 'Teal';

  static const _textSizes = ['Small', 'Medium', 'Large'];
  static const _accentPairs = [
    ('Teal', AppColors.teal),
    ('Blue', AppColors.blue),
    ('Purple', AppColors.purple),
    ('Green', AppColors.green),
  ];

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.bodySm),
      backgroundColor: context.inputBg,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: Text(AppStrings.appearance, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Label('THEME'),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.dark_mode_rounded,
                    color: AppColors.purple,
                    title: AppStrings.darkMode,
                    subtitle: 'Use dark background throughout the app',
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() => _darkMode = v);
                      _snack(v ? 'Dark mode enabled' : 'Light mode enabled');
                    },
                  ),
                  const SizedBox(height: 24),
                  _Label('TEXT SIZE'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.inputBg,
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      children: _textSizes.map((s) {
                        final sel = _textSize == s;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () { setState(() => _textSize = s); _snack('Text size: $s'); },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.teal.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: AppBorderRadius.mdAll,
                                border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.4) : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                s,
                                style: AppTypography.buttonSm.copyWith(
                                  color: sel ? AppColors.teal : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Label('ACCENT COLOUR'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _accentPairs.map((pair) {
                        final (label, color) = pair;
                        final sel = _accentColor == label;
                        return GestureDetector(
                          onTap: () { setState(() => _accentColor = label); _snack('$label accent selected'); },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2.5),
                                  boxShadow: sel ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)] : [],
                                ),
                                child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                              ),
                              const SizedBox(height: 6),
                              Text(label, style: AppTypography.bodyXs.copyWith(color: sel ? color : AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Label('DISPLAY'),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.view_compact_rounded,
                    color: AppColors.blue,
                    title: 'Compact Mode',
                    subtitle: 'Show more content with tighter spacing',
                    value: _compactMode,
                    onChanged: (v) { setState(() => _compactMode = v); _snack(v ? 'Compact mode on' : 'Compact mode off'); },
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.motion_photos_pause_rounded,
                    color: AppColors.amber,
                    title: 'Reduce Motion',
                    subtitle: 'Minimise animations and transitions',
                    value: _reducedMotion,
                    onChanged: (v) { setState(() => _reducedMotion = v); _snack(v ? 'Reduced motion on' : 'Reduced motion off'); },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppBorderRadius.smAll),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.teal,
              activeTrackColor: AppColors.teal.withValues(alpha: 0.25),
              inactiveTrackColor: context.inputBg,
              inactiveThumbColor: AppColors.textHint,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      );
}
