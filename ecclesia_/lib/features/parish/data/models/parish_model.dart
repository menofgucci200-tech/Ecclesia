import 'package:equatable/equatable.dart';

/// A parish as returned by the API.
class ParishModel extends Equatable {
  const ParishModel({
    required this.id,
    required this.name,
    required this.code,
    required this.diocese,
    this.address,
    this.city,
    this.commune,
    this.region,
    this.country,
    this.phone,
    this.email,
    this.logo,
    this.status = 'active',
  });

  final int id;
  final String name;
  final String code;
  final String diocese;
  final String? address;
  final String? city;
  final String? commune;
  final String? region;
  final String? country;
  final String? phone;
  final String? email;
  final String? logo;
  final String status;

  /// A short, human-friendly location line (commune + city) for list cards.
  String get locationLine {
    return [commune, city]
        .where((part) => part != null && part.isNotEmpty)
        .join(', ');
  }

  factory ParishModel.fromJson(Map<String, dynamic> json) {
    return ParishModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      diocese: json['diocese'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      commune: json['commune'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logo: json['logo'] as String?,
      status: (json['status'] as String?) ?? 'active',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        diocese,
        address,
        city,
        commune,
        region,
        country,
        phone,
        email,
        logo,
        status,
      ];
}
