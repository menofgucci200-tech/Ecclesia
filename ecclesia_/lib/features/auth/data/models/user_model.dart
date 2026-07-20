import 'package:equatable/equatable.dart';

import '../../../parish/data/models/parish_model.dart';
import '../../domain/entities/gender.dart';

/// The authenticated faithful, as returned by the API.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.phone,
    required this.status,
    required this.hasParish,
    this.email,
    this.avatarUrl,
    this.preferences = const {},
    this.parishId,
    this.parish,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final Gender? gender;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final Map<String, dynamic> preferences;
  final String status;
  final bool hasParish;
  final int? parishId;
  final ParishModel? parish;

  String? get feedPriority => preferences['feed_priority'] as String?;
  List<String> get hiddenSections =>
      (preferences['hidden_sections'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final parishJson = json['parish'];

    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: (json['full_name'] as String?) ??
          '${json['first_name']} ${json['last_name']}',
      gender: Gender.fromValue(json['gender'] as String?),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: json['preferences'] is Map<String, dynamic>
          ? json['preferences'] as Map<String, dynamic>
          : const {},
      status: (json['status'] as String?) ?? 'active',
      hasParish: (json['has_parish'] as bool?) ?? (json['parish_id'] != null),
      parishId: json['parish_id'] as int?,
      parish: parishJson is Map<String, dynamic>
          ? ParishModel.fromJson(parishJson)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        gender,
        phone,
        email,
        avatarUrl,
        preferences,
        status,
        hasParish,
        parishId,
        parish,
      ];
}
