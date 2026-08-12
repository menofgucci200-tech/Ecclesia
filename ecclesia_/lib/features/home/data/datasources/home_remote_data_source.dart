import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/cached_fetch.dart';
import '../../../../core/storage/cache_service.dart';
import '../models/home_data.dart';

/// Fetches the aggregated home payload (liturgy + parish schedule + headline).
/// Every response is cached locally so the app can keep showing the last
/// known data — instead of an error screen — when there is no connectivity.
class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio, this._cache);

  final Dio _dio;
  final CacheService _cache;

  Future<HomeData> fetchHome() async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'home',
      request: () => _dio.get<Map<String, dynamic>>(ApiConstants.home),
    );
    return HomeData.fromJson(json);
  }

  /// The full agenda: major liturgical feasts + parish events (12 months).
  Future<List<AgendaEvent>> fetchAgenda() async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'agenda',
      request: () => _dio.get<Map<String, dynamic>>(ApiConstants.agenda),
    );
    final data = json['events'] as List<dynamic>? ?? const [];
    return data.map((e) => AgendaEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Toggles the faithful's RSVP for a parish event. Returns the new
  /// attending state and attendee count.
  Future<({bool isAttending, int attendeesCount})> toggleEventRsvp(int eventId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(ApiConstants.agendaEventRsvp(eventId));
      return (
        isAttending: res.data?['is_attending'] as bool? ?? false,
        attendeesCount: (res.data?['attendees_count'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// The liturgy (readings) for a given date (YYYY-MM-DD), or null if none.
  Future<LiturgyModel?> fetchLiturgyForDate(String date) async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'liturgy_$date',
      request: () => _dio.get<Map<String, dynamic>>(ApiConstants.liturgyForDate(date)),
    );
    final liturgy = json['liturgy'] as Map<String, dynamic>?;
    return liturgy == null ? null : LiturgyModel.fromJson(liturgy);
  }
}
