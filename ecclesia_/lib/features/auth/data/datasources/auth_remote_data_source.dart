import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/cached_fetch.dart';
import '../../../../core/storage/cache_service.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../domain/entities/register_params.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

/// Talks to the `/auth/*` endpoints and translates transport errors into typed
/// [ApiException]s. Contains no business logic.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio, this._cache);

  final Dio _dio;
  final CacheService _cache;

  static const String _deviceName = 'ecclesia-mobile-app';

  Future<bool> checkPhone(String phone) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.checkPhone,
        data: {'phone': PhoneHelper.toE164(phone)},
      );
      return (response.data?['exists'] as bool?) ?? false;
    });
  }

  Future<AuthResultModel> register(RegisterParams params) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {...params.toJson(), 'device_name': _deviceName},
      );
      return AuthResultModel.fromJson(response.data!);
    });
  }

  Future<AuthResultModel> login({
    required String phone,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'phone': PhoneHelper.toE164(phone),
          'password': password,
          'device_name': _deviceName,
        },
      );
      return AuthResultModel.fromJson(response.data!);
    });
  }

  /// Cached so a previously-authenticated user still lands on their
  /// dashboard (with the last-known profile) when there is no connectivity,
  /// instead of being bounced back to onboarding.
  Future<UserModel> fetchMe() async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'me',
      request: () => _dio.get<Map<String, dynamic>>(ApiConstants.me),
    );
    return UserModel.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    return _guard(() async {
      await _dio.post<void>(ApiConstants.logout);
    });
  }

  Future<String> forgotPassword(String phone) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.forgotPassword,
        data: {'phone': PhoneHelper.toE164(phone)},
      );
      return (response.data?['email_hint'] as String?) ?? '';
    });
  }

  Future<AuthResultModel> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.resetPassword,
        data: {
          'phone': PhoneHelper.toE164(phone),
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': _deviceName,
        },
      );
      return AuthResultModel.fromJson(response.data!);
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _guard(() async {
      await _dio.post<void>(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
