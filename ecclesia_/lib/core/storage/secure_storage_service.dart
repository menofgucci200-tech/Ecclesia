import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

/// Thin, testable wrapper around [FlutterSecureStorage] for the values the app
/// must persist securely (the Sanctum access token) and simple flags.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readToken() {
    return _storage.read(key: StorageKeys.authToken);
  }

  Future<void> writeToken(String token) {
    return _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<void> deleteToken() {
    return _storage.delete(key: StorageKeys.authToken);
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: StorageKeys.onboardingSeen);
    return value == 'true';
  }

  Future<void> markOnboardingSeen() {
    return _storage.write(key: StorageKeys.onboardingSeen, value: 'true');
  }
}

/// Provider exposing a single [SecureStorageService] instance for the app.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});
