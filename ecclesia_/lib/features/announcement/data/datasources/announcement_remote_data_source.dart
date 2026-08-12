import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/cached_fetch.dart';
import '../../../../core/storage/cache_service.dart';
import '../models/announcement_model.dart';

/// Talks to the parish feed endpoint and translates transport errors into typed
/// [ApiException]s. Contains no business logic. Caches the last response so
/// the feed still shows something when there is no connectivity.
class AnnouncementRemoteDataSource {
  AnnouncementRemoteDataSource(this._dio, this._cache);

  final Dio _dio;
  final CacheService _cache;

  /// The parish feed for the authenticated faithful (pinned first, then recent).
  Future<List<AnnouncementModel>> fetchParishFeed({int perPage = 15}) async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'parish_feed',
      request: () => _dio.get<Map<String, dynamic>>(
        ApiConstants.parishAnnouncements,
        queryParameters: {'per_page': perPage},
      ),
    );
    final data = json['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
