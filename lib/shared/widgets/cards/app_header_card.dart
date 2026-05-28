import 'package:flutter/material.dart';
import 'app_base_card.dart';
import '../texts/app_text.dart';

/// Card with an optional logo, title, and subtitle above arbitrary content.
///
/// Built on [AppBaseCard] — inherits all theming and shadow behaviour.
///
/// ```dart
/// AppHeaderCard(
///   logo: AppBrand(layout: AppBrandLayout.logoOnly),
///   title: 'Reset Password',
///   subtitle: 'Enter your new password below.',
///   child: MyForm(),
/// )
/// ```
class AppHeaderCard extends StatelessWidget {
  const AppHeaderCard({
    super.key,
    required this.child,
    this.logo,
    this.title,
    this.subtitle,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final Widget? logo;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      padding: padding ?? const EdgeInsets.all(24),
      margin: margin,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (logo != null) ...[
            Center(child: logo!),
            const SizedBox(height: 24),
          ],
          if (title != null) ...[
            AppText.h1(title!),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              AppText.bodySm(subtitle!),
            ],
            const SizedBox(height: 28),
          ],
          child,
        ],
      ),
    );
  }
}
