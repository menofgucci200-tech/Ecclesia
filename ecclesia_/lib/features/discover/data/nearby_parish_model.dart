import 'package:equatable/equatable.dart';

/// A parish plotted on the "Découvrir" map (`GET /parishes/nearby`).
class NearbyParish extends Equatable {
  const NearbyParish({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.commune,
    required this.latitude,
    required this.longitude,
    required this.isPartner,
    this.logoUrl,
    required this.distanceKm,
  });

  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? commune;
  final double latitude;
  final double longitude;
  final bool isPartner;
  final String? logoUrl;
  final double distanceKm;

  /// Short line under the name in the info sheet, e.g. "Treichville, Abidjan".
  String get locationLine {
    final parts = [commune, city].where((v) => v != null && v.isNotEmpty).toList();
    return parts.isEmpty ? (address ?? '') : parts.join(', ');
  }

  factory NearbyParish.fromJson(Map<String, dynamic> json) => NearbyParish(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        city: json['city'] as String?,
        commune: json['commune'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isPartner: json['is_partner'] as bool? ?? false,
        logoUrl: json['logo_url'] as String?,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [id, name, address, city, commune, latitude, longitude, isPartner, logoUrl, distanceKm];
}
