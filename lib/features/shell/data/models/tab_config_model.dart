class TabConfigModel {
  final String id;
  final String slug;
  final String label;
  final bool isActive;
  final String tabType; // 'CORE' | 'DEFAULT' | 'ROLE_ONLY' | 'GRANTABLE'
  final bool allowView;
  final int sortOrder;
  final String? iconSvg;

  const TabConfigModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.isActive,
    required this.tabType,
    required this.allowView,
    required this.sortOrder,
    this.iconSvg,
  });

  factory TabConfigModel.fromJson(Map<String, dynamic> json) => TabConfigModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        label: json['label'] as String,
        isActive: json['isActive'] as bool? ?? true,
        tabType: json['tabType'] as String? ?? 'DEFAULT',
        allowView: json['allowView'] as bool? ?? true,
        sortOrder: json['sortOrder'] as int? ?? 0,
        iconSvg: json['iconSvg'] as String?,
      );
}
