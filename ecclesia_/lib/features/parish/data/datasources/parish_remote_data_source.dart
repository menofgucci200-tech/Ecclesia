import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/paginated_parishes.dart';
import '../models/parish_model.dart';

/// Talks to the parish endpoints and translates transport errors into typed
/// [ApiException]s. Contains no business logic.
class ParishRemoteDataSource {
  ParishRemoteDataSource(this._dio);

  final Dio _dio;

  /// Paginated list of joinable parishes.
  Future<PaginatedParishes> fetchParishes({int page = 1, int perPage = 20}) async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parishes,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedParishes.fromJson(response.data!);
    });
  }

  /// Search joinable parishes by name, code, city, commune or region.
  Future<PaginatedParishes> searchParishes({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parishesSearch,
        queryParameters: {'q': query, 'page': page, 'per_page': perPage},
      );
      return PaginatedParishes.fromJson(response.data!);
    });
  }

  /// Full details of a single parish.
  Future<ParishModel> fetchParish(int id) async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.parish(id));
      return ParishModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }

  /// Automatically associate the authenticated faithful to a parish.
  Future<ParishModel> associate(int parishId) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.userParish,
        data: {'parish_id': parishId},
      );
      return ParishModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }

  /// The parish the authenticated faithful currently belongs to.
  Future<ParishModel?> fetchCurrent() async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.userParish);
      final data = response.data?['data'];
      return data is Map<String, dynamic> ? ParishModel.fromJson(data) : null;
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
