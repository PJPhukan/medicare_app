// Pure domain entity for professional service areas.
// No Flutter, no JSON, no Dio.

class ServiceAreaEntity {
  const ServiceAreaEntity({
    required this.id,
    required this.city,
    required this.state,
    required this.country,
    this.pincode,
  });

  final String id;
  final String city;
  final String state;
  final String country;
  final String? pincode;

  String get displayName => '$city, $state, $country';
}
