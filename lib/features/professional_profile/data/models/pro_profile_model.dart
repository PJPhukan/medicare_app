import '../../domain/entities/pro_profile_entity.dart';
import 'service_area_model.dart';

class ProProfile extends ProProfileEntity {
  const ProProfile({
    required super.id,
    required super.isVerified,
    required super.agreedToTerms,
    required super.certifications,
    required List<ServiceArea> serviceAreas,
    required super.createdAt,
    super.displayName,
    super.bio,
    super.experienceYrs,
    super.basePrice,
    super.hourlyRate,
    super.dailyRate,
    super.monthlyRate,
    super.currency,
    super.profileImageUrl,
    super.phone,
    super.address,
    super.categoryId,
    super.categoryLabel,
  }) : super(serviceAreas: serviceAreas);

  @override
  List<ServiceArea> get serviceAreas => super.serviceAreas.cast<ServiceArea>();

  factory ProProfile.fromJson(Map<String, dynamic> json) => ProProfile(
        id: json['id'] as String,
        isVerified: json['isVerified'] as bool? ?? false,
        agreedToTerms: json['agreedToTerms'] as bool? ?? false,
        certifications:
            (json['certifications'] as List<dynamic>? ?? []).cast<String>(),
        createdAt: json['createdAt'] as String? ?? '',
        displayName: json['displayName'] as String?,
        bio: json['bio'] as String?,
        experienceYrs: json['experienceYrs'] as int?,
        basePrice: json['basePrice'] != null
            ? (json['basePrice'] as num).toDouble()
            : null,
        hourlyRate: json['hourlyRate'] != null
            ? (json['hourlyRate'] as num).toDouble()
            : null,
        dailyRate: json['dailyRate'] != null
            ? (json['dailyRate'] as num).toDouble()
            : null,
        monthlyRate: json['monthlyRate'] != null
            ? (json['monthlyRate'] as num).toDouble()
            : null,
        currency: json['currency'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        categoryId: json['categoryId'] as String?,
        categoryLabel: json['categoryLabel'] as String?,
        serviceAreas: (json['serviceAreas'] as List<dynamic>? ?? [])
            .map((e) => ServiceArea.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
