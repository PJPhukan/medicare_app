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
  });

  final String id;
  final String imageUrl;
  final String? actionUrl;
  final String? title;
  final String? subtitle;
  final Color? gradientStart;
  final Color? gradientEnd;

  bool get isGradient => imageUrl.isEmpty;

  factory DashboardBanner.fromJson(Map<String, dynamic> json) =>
      DashboardBanner(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        actionUrl: json['actionUrl'] as String?,
      );
}

const kFallbackBanners = [
  DashboardBanner(
    id: 'promo1',
    imageUrl: '',
    title: 'Track Your Medicines',
    subtitle: 'Never miss a dose with smart reminders',
    gradientStart: Color(0xFF0B4F4F),
    gradientEnd: Color(0xFF0D2137),
  ),
  DashboardBanner(
    id: 'promo2',
    imageUrl: '',
    title: 'Connect Your Care Team',
    subtitle: 'Share health updates with doctors & caregivers',
    gradientStart: Color(0xFF2D1B5E),
    gradientEnd: Color(0xFF0D2137),
  ),
  DashboardBanner(
    id: 'promo3',
    imageUrl: '',
    title: 'Monitor Your Vitals',
    subtitle: 'Log BP, sugar, weight & more in seconds',
    gradientStart: Color(0xFF1A3A20),
    gradientEnd: Color(0xFF0D2137),
  ),
];
