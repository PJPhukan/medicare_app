class TabConfigModel {
  final String id;
  final String slug;
  final String label;
  final bool isActive;
  final String tabType;  // 'CORE' | 'DEFAULT' | 'ROLE_ONLY' | 'GRANTABLE'
  final String platform; // 'APP' | 'WEB' | 'BOTH'
  final bool allowView;
  // Per-operation permissions (the backend already sends these; we now parse
  // them so screens can gate add/edit/delete/share actions per tab).
  final bool allowAdd;
  final bool allowEdit;
  final bool allowDelete;
  final bool allowShare;
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
    this.allowAdd = false,
    this.allowEdit = false,
    this.allowDelete = false,
    this.allowShare = false,
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
        allowAdd: json['allowAdd'] as bool? ?? false,
        allowEdit: json['allowEdit'] as bool? ?? false,
        allowDelete: json['allowDelete'] as bool? ?? false,
        allowShare: json['allowShare'] as bool? ?? false,
        showInBottomNav: json['showInBottomNav'] as bool? ?? false,
        navOrder: json['navOrder'] as int? ?? 0,
        sortOrder: json['sortOrder'] as int? ?? 0,
        iconSvg: json['iconSvg'] as String?,
      );
}
