import 'package:flutter/material.dart';

class DashboardBanner {
  const DashboardBanner({
    required this.id,
    required this.imageUrl,
    this.actionUrl,
    this.title,
    this.subtitle,
    this.gradientStart,
    this.gradientEnd,
    this.active = true,
  });

  final String id;
  final String imageUrl;
  final String? actionUrl;
  final String? title;
  final String? subtitle;
  final Color? gradientStart;
  final Color? gradientEnd;
  final bool active;

  bool get isGradient => imageUrl.isEmpty;

  factory DashboardBanner.fromJson(Map<String, dynamic> json) =>
      DashboardBanner(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        actionUrl: json['actionUrl'] as String?,
        active: json['active'] as bool? ?? true,
      );
}
