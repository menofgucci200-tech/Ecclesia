import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_events.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// The single, configured [Dio] instance shared across all data sources.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        // Identify ourselves with a clean, explicit User-Agent instead of the
        // default `Dart/x.y (dart:io)`, which edge WAFs (Hostinger hCDN) tend to
        // score as a bot and may block with a 403 from flagged mobile IPs.
        'User-Agent': 'EcclesiaApp/1.0 (Android)',
        // Mark the call as a programmatic API request (helps WAF/CORS heuristics
        // treat it as a legitimate app call rather than anonymous traffic).
        'X-Requested-With': 'com.ecclesia.app',
      },
    ),
  );

  final storage = ref.read(secureStorageServiceProvider);

  dio.interceptors.add(
    AuthInterceptor(
      tokenReader: storage.readToken,
      onUnauthorized: () async {
        await storage.deleteToken();
        ref.read(unauthorizedEventProvider.notifier).signal();
      },
    ),
  );

  dio.interceptors.add(RetryInterceptor(dio: dio));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
});
