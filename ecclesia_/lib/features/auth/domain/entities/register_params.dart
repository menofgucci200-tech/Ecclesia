import '../../../../core/utils/phone_helper.dart';
import 'gender.dart';

/// The full set of data collected across the registration wizard.
class RegisterParams {
  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.email,
  });

  final String firstName;
  final String lastName;
  final Gender gender;

  /// The local Ivorian number as typed (digits, spaces tolerated).
  final String phone;
  final String? email;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'gender': gender.value,
      'phone': PhoneHelper.toE164(phone),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
