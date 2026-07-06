import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<bool> checkPhone(String phone) => _remote.checkPhone(phone);

  @override
  Future<AuthResultModel> register(RegisterParams params) =>
      _remote.register(params);

  @override
  Future<AuthResultModel> login({
    required String phone,
    required String password,
  }) =>
      _remote.login(phone: phone, password: password);

  @override
  Future<UserModel> fetchMe() => _remote.fetchMe();

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<String> forgotPassword(String phone) => _remote.forgotPassword(phone);

  @override
  Future<AuthResultModel> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) =>
      _remote.resetPassword(
        phone: phone,
        code: code,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      _remote.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});
