import 'package:dio/dio.dart';

/// A typed, user-presentable representation of any failure that can occur when
/// talking to the Ecclesia API. Every network call surfaces one of these.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  /// A French, ready-to-display message.
  final String message;

  @override
  String toString() => message;

  /// A short, reassuring headline for the error card (never alarming).
  String get title => switch (this) {
        NetworkException() => 'Pas de connexion',
        TimeoutException() => 'Connexion lente',
        ServerException() => 'Service momentanément indisponible',
        RateLimitException() => 'Un instant, s\'il vous plaît',
        ForbiddenException() => 'Réseau bloqué',
        UnauthorizedException() => 'Session expirée',
        NotFoundException() => 'Introuvable',
        ValidationException() => 'Quelques informations à vérifier',
        RequestCancelledException() => 'Requête annulée',
        UnknownException() => 'Oups, un souci est survenu',
      };

  /// Whether offering a "Réessayer" action makes sense for this error.
  bool get isRetryable => switch (this) {
        NetworkException() ||
        TimeoutException() ||
        ServerException() ||
        RateLimitException() ||
        ForbiddenException() ||
        UnknownException() =>
          true,
        _ => false,
      };

  /// Whether this looks like a connectivity / infrastructure hiccup (as opposed
  /// to something the user did wrong). Presented gently, in amber, to avoid
  /// panic — the vast majority of these resolve by simply retrying.
  bool get isConnectivity => switch (this) {
        NetworkException() ||
        TimeoutException() ||
        ServerException() ||
        ForbiddenException() =>
          true,
        _ => false,
      };

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
      // A 403 on a public endpoint is almost never the app: it is the host's
      // firewall (WAF) blocking the network the phone is on — typically a
      // Wi-Fi whose public IP got flagged. Switching to mobile data or another
      // Wi-Fi resolves it, so we say exactly that instead of "accès refusé".
      403 => ForbiddenException(
          _looksLikeHtml(data)
              ? 'Votre réseau actuel (souvent le Wi-Fi) est bloqué par le '
                  'pare-feu du serveur. Passez en données mobiles (4G) ou '
                  'connectez-vous à un autre Wi-Fi, puis réessayez.'
              : (message ??
                  'La connexion a été refusée par le réseau. Passez en 4G ou '
                      'sur un autre Wi-Fi, puis réessayez.'),
        ),
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

  /// True when the body is a raw HTML page (e.g. a WAF/firewall block page)
  /// rather than a JSON API payload — a strong signal the request was stopped
  /// by network infrastructure, not by our application.
  static bool _looksLikeHtml(dynamic data) {
    if (data is! String) return false;
    final head = data.trimLeft().toLowerCase();
    return head.startsWith('<!doctype html') ||
        head.startsWith('<html') ||
        head.contains('<title') && head.contains('403');
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
      : super(
          'Nous n\'arrivons pas à joindre le serveur. Vérifiez votre connexion '
          'internet (Wi-Fi ou données mobiles), puis réessayez.',
        );
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super(
          'Le serveur met trop de temps à répondre. Cela vient souvent d\'une '
          'connexion lente — réessayez dans un instant.',
        );
}

class ServerException extends ApiException {
  const ServerException()
      : super(
          'Le service est momentanément indisponible. Ce n\'est pas de votre '
          'faute — merci de réessayer dans quelques instants.',
        );
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
      : super(
          'Vous avez fait plusieurs tentatives rapprochées. Patientez une '
          'minute, puis réessayez tranquillement.',
        );
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
