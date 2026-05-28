import 'professional_category_entity.dart';

class ProfessionalUserEntity {
  const ProfessionalUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String phone;
  final String? profilePicture;
}

class ProfessionalEntity {
  const ProfessionalEntity({
    required this.id,
    required this.isVerified,
    required this.isBanned,
    required this.certifications,
    required this.agreedToTerms,
    required this.user,
    required this.category,
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
    this.averageRating,
    this.ratingCount,
  });

  final String id;
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
  final bool isVerified;
  final bool isBanned;
  final List<String> certifications;
  final bool agreedToTerms;
  final String createdAt;
  final ProfessionalUserEntity user;
  final ProfessionalCategoryEntity category;
  final double? averageRating;
  final int? ratingCount;

  String get name => displayName ?? user.name;
}
