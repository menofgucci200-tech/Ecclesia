import 'package:dio/dio.dart';

import '../storage/cache_service.dart';
import 'api_exception.dart';

/// Runs [request]; on success, caches the decoded JSON body under
/// [cacheKey] and returns it. On a connectivity/timeout failure, falls back
/// to the last cached body for [cacheKey] if any (the app then keeps
/// showing the last-known data instead of an error screen); otherwise
/// rethrows the typed [ApiException].
Future<Map<String, dynamic>> fetchJsonWithCache({
  required CacheService cache,
  required String cacheKey,
  required Future<Response<Map<String, dynamic>>> Function() request,
}) async {
  try {
    final response = await request();
    final json = response.data ?? const {};
    await cache.writeRaw(cacheKey, json);
    return json;
  } on DioException catch (error) {
    final apiException = ApiException.fromDio(error);
    if (apiException is NetworkException || apiException is TimeoutException) {
      final cached = cache.readRawAsFallback(cacheKey);
      if (cached is Map<String, dynamic>) return cached;
    }
    throw apiException;
  }
}
