import 'package:dio/dio.dart';

/// Attaches the stored Bearer token to every request and reacts to a rejected
/// (401) token by clearing the session — the automatic "expired token"
/// handling required by the app.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenReader,
    required this.onUnauthorized,
  });

  /// Reads the current access token (from secure storage).
  final Future<String?> Function() tokenReader;

  /// Invoked when an authenticated request is rejected with 401.
  final Future<void> Function() onUnauthorized;

  static const String _authHeader = 'Authorization';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('Accept', () => 'application/json');

    if (!options.headers.containsKey(_authHeader)) {
      final token = await tokenReader();
      if (token != null && token.isNotEmpty) {
        options.headers[_authHeader] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final wasAuthenticated =
        err.requestOptions.headers.containsKey(_authHeader);

    if (err.response?.statusCode == 401 && wasAuthenticated) {
      await onUnauthorized();
    }

    handler.next(err);
  }
}
