import '../../domain/entities/professional_entity.dart';
import 'professional_category_model.dart';

class ProfessionalUser extends ProfessionalUserEntity {
  const ProfessionalUser({
    required super.id,
    required super.name,
    required super.phone,
    super.profilePicture,
  });

  factory ProfessionalUser.fromJson(Map<String, dynamic> json) =>
      ProfessionalUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
      );
}

class Professional extends ProfessionalEntity {
  const Professional({
    required super.id,
    required super.isVerified,
    required super.isBanned,
    required super.certifications,
    required super.agreedToTerms,
    required ProfessionalUser super.user,
    required ProfessionalCategory super.category,
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
    super.averageRating,
    super.ratingCount,
  });

  @override
  ProfessionalUser get user => super.user as ProfessionalUser;

  @override
  ProfessionalCategory get category =>
      super.category as ProfessionalCategory;

  factory Professional.fromJson(Map<String, dynamic> json) => Professional(
        id: json['id'] as String,
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
        isVerified: json['isVerified'] as bool? ?? false,
        isBanned: json['isBanned'] as bool? ?? false,
        certifications:
            (json['certifications'] as List<dynamic>? ?? []).cast<String>(),
        agreedToTerms: json['agreedToTerms'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
        user: ProfessionalUser.fromJson(
          json['user'] as Map<String, dynamic>,
        ),
        category: ProfessionalCategory.fromJson(
          json['category'] as Map<String, dynamic>,
        ),
        averageRating: json['averageRating'] != null
            ? (json['averageRating'] as num).toDouble()
            : null,
        ratingCount: json['ratingCount'] as int?,
      );
}
