import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/movement.dart';

class MovementRemoteDataSource {
  MovementRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Movement>> fetchParishMovements() => _list(ApiConstants.movements);

  Future<List<Movement>> fetchMyMovements() => _list(ApiConstants.myMovements);

  Future<List<Movement>> _list(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final data = response.data?['movements'] as List<dynamic>? ?? const [];
      return data.map((e) => Movement.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<MovementDetail> fetchDetail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.movement(id));
      return MovementDetail.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> join(int id) async {
    try {
      await _dio.post<void>(ApiConstants.movementJoin(id));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> leave(int id) async {
    try {
      await _dio.delete<void>(ApiConstants.movementLeave(id));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
