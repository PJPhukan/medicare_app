import '../../domain/entities/service_area_entity.dart';

class ServiceArea extends ServiceAreaEntity {
  const ServiceArea({
    required super.id,
    required super.city,
    required super.state,
    required super.country,
    super.pincode,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) => ServiceArea(
        id: json['id'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        country: json['country'] as String,
        pincode: json['pincode'] as String?,
      );
}
