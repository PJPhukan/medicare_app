class ProfessionalCategoryEntity {
  const ProfessionalCategoryEntity({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
}
