import 'package:equatable/equatable.dart';

import 'gender.dart';

/// Accumulates the data collected across the registration wizard
/// (phone check → personal info → contact → password) before the final
/// submission to the API in a single call.
class RegistrationDraft extends Equatable {
  const RegistrationDraft({
    this.phone = '',
    this.firstName = '',
    this.lastName = '',
    this.gender,
    this.email,
  });

  /// The local Ivorian number, as verified during the phone step.
  final String phone;
  final String firstName;
  final String lastName;
  final Gender? gender;
  final String? email;

  bool get hasPersonalInfo =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty && gender != null;

  RegistrationDraft copyWith({
    String? phone,
    String? firstName,
    String? lastName,
    Gender? gender,
    String? email,
  }) {
    return RegistrationDraft(
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [phone, firstName, lastName, gender, email];
}
