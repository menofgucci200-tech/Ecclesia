import 'package:dio/dio.dart';
import 'package:ecclesia_/core/network/api_exception.dart';
import 'package:ecclesia_/core/network/cached_fetch.dart';
import 'package:ecclesia_/core/storage/cache_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Covers the offline fallback behind the "previously logged-in user must
/// not be bounced to onboarding when there is no connectivity" fix: a
/// successful fetch is cached, a connectivity failure falls back to that
/// cache (and flips [isOfflineProvider]), and a failure with nothing cached
/// still surfaces as an error.
void main() {
  late ProviderContainer container;
  late CacheService cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    cache = container.read(cacheServiceProvider);
  });

  tearDown(() => container.dispose());

  Response<Map<String, dynamic>> fakeResponse(Map<String, dynamic> data) {
    return Response(data: data, requestOptions: RequestOptions(path: '/x'));
  }

  DioException connectionError() => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  test('caches a successful response and marks the app online', () async {
    final json = await fetchJsonWithCache(
      cache: cache,
      cacheKey: 'k',
      request: () async => fakeResponse({'a': 1}),
    );

    expect(json, {'a': 1});
    expect(container.read(isOfflineProvider), isFalse);
  });

  test('falls back to the cached value on a network failure', () async {
    await fetchJsonWithCache(
      cache: cache,
      cacheKey: 'k',
      request: () async => fakeResponse({'a': 1}),
    );

    final json = await fetchJsonWithCache(
      cache: cache,
      cacheKey: 'k',
      request: () async => throw connectionError(),
    );

    expect(json, {'a': 1});
    expect(container.read(isOfflineProvider), isTrue);
  });

  test('rethrows a typed ApiException when nothing is cached yet', () async {
    expect(
      () => fetchJsonWithCache(
        cache: cache,
        cacheKey: 'missing',
        request: () async => throw connectionError(),
      ),
      throwsA(isA<NetworkException>()),
    );
  });
}
