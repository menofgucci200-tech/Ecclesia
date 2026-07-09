import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/announcement_model.dart';

/// Talks to the parish feed endpoint and translates transport errors into typed
/// [ApiException]s. Contains no business logic.
class AnnouncementRemoteDataSource {
  AnnouncementRemoteDataSource(this._dio);

  final Dio _dio;

  /// The parish feed for the authenticated faithful (pinned first, then recent).
  Future<List<AnnouncementModel>> fetchParishFeed({int perPage = 15}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parishAnnouncements,
        queryParameters: {'per_page': perPage},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
