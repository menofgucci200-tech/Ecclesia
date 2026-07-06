import 'dart:async';

import 'package:dio/dio.dart';

/// Automatically retries idempotent requests that fail because of transient
/// connectivity issues (timeouts / connection errors), with a short backoff.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 600),
  });

  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  static const String _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (_shouldRetry(err) && attempt < maxRetries) {
      await Future<void>.delayed(retryDelay * (attempt + 1));

      final options = err.requestOptions..extra[_retryCountKey] = attempt + 1;

      try {
        final response = await dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        return handler.next(retryError);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (!_isIdempotent(err.requestOptions.method)) {
      return false;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  bool _isIdempotent(String method) {
    final normalized = method.toUpperCase();
    return normalized == 'GET' || normalized == 'HEAD';
  }
}
