import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provided (as an override, from `main.dart`) once [SharedPreferences] has
/// resolved at startup, so the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

/// Whether the app is currently showing data served from the local cache
/// because the last attempt to reach the API failed (no connectivity,
/// timeout). Flipped by [CacheService] as requests succeed or fall back.
class OfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOnline() => state = false;
  void setOffline() => state = true;
}

final isOfflineProvider = NotifierProvider<OfflineNotifier, bool>(OfflineNotifier.new);

/// Lightweight JSON cache backed by [SharedPreferences], used to keep the
/// app usable — last-known data, not a blank error screen — when there is
/// no network connectivity.
class CacheService {
  CacheService(this._ref, this._prefs);

  final Ref _ref;
  final SharedPreferences _prefs;
  static const _prefix = 'cache_';

  Future<void> writeRaw(String key, Object? value) async {
    await _prefs.setString('$_prefix$key', jsonEncode(value));
    _ref.read(isOfflineProvider.notifier).setOnline();
  }

  /// Returns the cached value for [key], or null if nothing was ever cached.
  /// Only call this as a fallback after a failed network request — a hit
  /// marks the app as offline so the UI can show a subtle indicator.
  Object? readRawAsFallback(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    _ref.read(isOfflineProvider.notifier).setOffline();
    return jsonDecode(raw);
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref, ref.watch(sharedPreferencesProvider));
});
