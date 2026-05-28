import '../../domain/entities/professional_category_entity.dart';

class ProfessionalCategory extends ProfessionalCategoryEntity {
  const ProfessionalCategory({
    required super.id,
    required super.slug,
    required super.name,
    super.description,
  });

  factory ProfessionalCategory.fromJson(Map<String, dynamic> json) =>
      ProfessionalCategory(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}
