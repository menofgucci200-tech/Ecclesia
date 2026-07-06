import '../../data/models/auth_result_model.dart';
import '../../data/models/user_model.dart';
import '../entities/register_params.dart';

/// Contract for every authentication operation. The presentation layer depends
/// on this abstraction, never on Dio directly.
abstract interface class AuthRepository {
  /// Whether an account already exists for the given phone number.
  Future<bool> checkPhone(String phone);

  Future<AuthResultModel> register(RegisterParams params);

  Future<AuthResultModel> login({
    required String phone,
    required String password,
  });

  Future<UserModel> fetchMe();

  Future<void> logout();

  /// Send a reset code to the e-mail linked to [phone]; returns the masked email.
  Future<String> forgotPassword(String phone);

  Future<AuthResultModel> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });
}
