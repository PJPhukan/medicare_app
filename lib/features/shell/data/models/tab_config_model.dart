class TabConfigModel {
  final String id;
  final String slug;
  final String label;
  final bool isActive;
  final String tabType;  // 'CORE' | 'DEFAULT' | 'ROLE_ONLY' | 'GRANTABLE'
  final String platform; // 'APP' | 'WEB' | 'BOTH'
  final bool allowView;
  final bool showInBottomNav;
  final int navOrder;
  final int sortOrder;
  final String? iconSvg;

  const TabConfigModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.isActive,
    required this.tabType,
    required this.platform,
    required this.allowView,
    required this.showInBottomNav,
    required this.navOrder,
    required this.sortOrder,
    this.iconSvg,
  });

  factory TabConfigModel.fromJson(Map<String, dynamic> json) => TabConfigModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        label: json['label'] as String,
        isActive: json['isActive'] as bool? ?? true,
        tabType: json['tabType'] as String? ?? 'DEFAULT',
        platform: json['platform'] as String? ?? 'BOTH',
        allowView: json['allowView'] as bool? ?? true,
        showInBottomNav: json['showInBottomNav'] as bool? ?? false,
        navOrder: json['navOrder'] as int? ?? 0,
        sortOrder: json['sortOrder'] as int? ?? 0,
        iconSvg: json['iconSvg'] as String?,
      );
}
