// Pure domain entity for professional profile (own profile view).
// No Flutter, no JSON, no Dio.

import 'service_area_entity.dart';

class ProProfileEntity {
  const ProProfileEntity({
    required this.id,
    required this.isVerified,
    required this.agreedToTerms,
    required this.certifications,
    required this.serviceAreas,
    required this.createdAt,
    this.displayName,
    this.bio,
    this.experienceYrs,
    this.basePrice,
    this.hourlyRate,
    this.dailyRate,
    this.monthlyRate,
    this.currency,
    this.profileImageUrl,
    this.phone,
    this.address,
    this.categoryId,
    this.categoryLabel,
  });

  final String id;
  final bool isVerified;
  final bool agreedToTerms;
  final List<String> certifications;
  final List<ServiceAreaEntity> serviceAreas;
  final String createdAt;
  final String? displayName;
  final String? bio;
  final int? experienceYrs;
  final double? basePrice;
  final double? hourlyRate;
  final double? dailyRate;
  final double? monthlyRate;
  final String? currency;
  final String? profileImageUrl;
  final String? phone;
  final String? address;
  final String? categoryId;
  final String? categoryLabel;

  bool get hasServiceAreas => serviceAreas.isNotEmpty;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
