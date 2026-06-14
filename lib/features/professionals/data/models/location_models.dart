// ─── Area returned by the backend ────────────────────────────────────────────

class AreaInfo {
  const AreaInfo({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
  });

  final String id;
  final String name;
  final String district;
  final String state;

  factory AreaInfo.fromJson(Map<String, dynamic> json) => AreaInfo(
        id:       json['id'] as String,
        name:     json['name'] as String,
        district: json['district'] as String,
        state:    json['state'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id':       id,
        'name':     name,
        'district': district,
        'state':    state,
      };

  String get displayName => name;
  String get fullDisplay => '$name, $district';

  @override
  bool operator ==(Object other) =>
      other is AreaInfo && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ─── User's saved location (persisted in SharedPreferences) ──────────────────

class SavedLocation {
  const SavedLocation({
    this.pincode,
    required this.area,
  });

  // Null when the location was chosen by area name (no single pincode).
  final String? pincode;
  final AreaInfo area;

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        pincode: json['pincode'] as String?,
        area:    AreaInfo.fromJson(json['area'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'pincode': pincode,
        'area':    area.toJson(),
      };
}

// ─── Paginated professionals response with location context ──────────────────

class ProfessionalsLocationPage {
  const ProfessionalsLocationPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
    required this.isFallback,
    this.area,
    this.fallbackDistrict,
    this.fallbackAreas = const [],
  });

  final List<Map<String, dynamic>> items;
  final int total;
  final int page;
  final int pages;
  final bool isFallback;
  final AreaInfo? area;
  final String? fallbackDistrict;
  final List<AreaInfo> fallbackAreas;

  bool get hasMore => page < pages;
}
