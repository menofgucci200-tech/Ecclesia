import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/data/models/user_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  /// Update the identity (name/email) and optionally the avatar photo.
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? avatarPath,
  }) async {
    try {
      final form = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (avatarPath != null) 'avatar': await MultipartFile.fromFile(avatarPath, filename: 'avatar.jpg'),
      });
      final response = await _dio.post<Map<String, dynamic>>('/profile', data: form);
      return UserModel.fromJson(response.data!['user'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// Update app preferences (feed priority, hidden sections…).
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>('/profile/preferences', data: {'preferences': preferences});
      return (response.data?['preferences'] as Map<String, dynamic>?) ?? preferences;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

final profileDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.read(dioProvider)),
);
