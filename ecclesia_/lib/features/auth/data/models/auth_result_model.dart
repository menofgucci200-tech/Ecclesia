import 'user_model.dart';

/// The payload returned by register/login: the user plus a Bearer token.
class AuthResultModel {
  const AuthResultModel({
    required this.user,
    required this.token,
    this.tokenType = 'Bearer',
  });

  final UserModel user;
  final String token;
  final String tokenType;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
    );
  }
}
