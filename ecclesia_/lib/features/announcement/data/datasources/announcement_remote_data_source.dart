import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/cached_fetch.dart';
import '../../../../core/storage/cache_service.dart';
import '../models/announcement_comment_model.dart';
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
      cacheKey: perPage <= 15 ? 'parish_feed' : 'parish_feed_full',
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

  /// The faithful's saved ("Enregistrées") announcements.
  Future<List<AnnouncementModel>> fetchSaved() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiConstants.savedAnnouncements);
      final data = res.data?['data'] as List<dynamic>? ?? const [];
      return data.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Toggles the bookmark on an announcement. Returns the new saved state.
  Future<bool> toggleSave(int announcementId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(ApiConstants.announcementSave(announcementId));
      return res.data?['is_saved'] as bool? ?? false;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Toggles the like on an announcement. Returns the new state and the
  /// real, server-computed like count.
  Future<({bool isLiked, int likesCount})> toggleLike(int announcementId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(ApiConstants.announcementLike(announcementId));
      return (
        isLiked: res.data?['is_liked'] as bool? ?? false,
        likesCount: (res.data?['likes_count'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<AnnouncementCommentModel>> fetchComments(int announcementId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiConstants.announcementComments(announcementId));
      final data = res.data?['data'] as List<dynamic>? ?? const [];
      return data.map((e) => AnnouncementCommentModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AnnouncementCommentModel> postComment(int announcementId, String body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.announcementComments(announcementId),
        data: {'body': body},
      );
      return AnnouncementCommentModel.fromJson(res.data?['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteComment(int announcementId, int commentId) async {
    try {
      await _dio.delete<void>(ApiConstants.announcementComment(announcementId, commentId));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
