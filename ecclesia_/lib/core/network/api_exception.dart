import 'package:dio/dio.dart';

/// A typed, user-presentable representation of any failure that can occur when
/// talking to the Ecclesia API. Every network call surfaces one of these.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  /// A French, ready-to-display message.
  final String message;

  @override
  String toString() => message;

  /// Map a low-level [DioException] into a meaningful domain exception.
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.badCertificate:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return _fromResponse(error.response);
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final data = response?.data;
    final message = _extractMessage(data);

    return switch (status) {
      401 => UnauthorizedException(message ?? 'Session expirée. Veuillez vous reconnecter.'),
      403 => ForbiddenException(message ?? 'Accès non autorisé.'),
      404 => NotFoundException(message ?? 'Ressource introuvable.'),
      422 => ValidationException(
          message ?? 'Certaines informations sont invalides.',
          _extractErrors(data),
        ),
      429 => const RateLimitException(),
      >= 500 => const ServerException(),
      _ => UnknownException(message ?? 'Une erreur inattendue est survenue.'),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map && data['message'] is String) {
      final message = data['message'] as String;
      return message.isNotEmpty ? message : null;
    }
    return null;
  }

  static Map<String, List<String>> _extractErrors(dynamic data) {
    final result = <String, List<String>>{};
    if (data is Map && data['errors'] is Map) {
      (data['errors'] as Map).forEach((key, value) {
        if (value is List) {
          result['$key'] = value.map((e) => '$e').toList();
        } else if (value != null) {
          result['$key'] = ['$value'];
        }
      });
    }
    return result;
  }
}

class NetworkException extends ApiException {
  const NetworkException()
      : super('Impossible de contacter le serveur. Vérifiez votre connexion.');
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super('Le serveur met trop de temps à répondre. Veuillez réessayer.');
}

class ServerException extends ApiException {
  const ServerException()
      : super('Une erreur est survenue sur le serveur. Veuillez réessayer.');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class RateLimitException extends ApiException {
  const RateLimitException()
      : super('Trop de tentatives. Veuillez patienter un instant.');
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException() : super('Requête annulée.');
}

class UnknownException extends ApiException {
  const UnknownException(super.message);
}

/// A 422 response with field-level validation errors, keyed by input name.
class ValidationException extends ApiException {
  const ValidationException(super.message, this.errors);

  final Map<String, List<String>> errors;

  /// The first error message for [field], if any.
  String? firstFor(String field) {
    final messages = errors[field];
    return (messages != null && messages.isNotEmpty) ? messages.first : null;
  }
}
