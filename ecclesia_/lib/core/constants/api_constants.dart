/// Centralized API configuration and endpoint paths.
///
/// The base URL is overridable at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
///
/// Default targets `127.0.0.1`, i.e. the host machine's own loopback as seen
/// from the device. This works out of the box for:
///   - A physical device connected over USB, via `adb reverse tcp:8000 tcp:8000`
///     (forwards the device's localhost:8000 to the host's localhost:8000 —
///     survives Wi-Fi IP changes, no override needed).
///
/// For the Android *emulator* (not a physical device), override instead with
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api` (the emulator's
/// alias for the host loopback). For a physical device over Wi-Fi without USB,
/// override with the host's current LAN IP.
class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.109:8000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  // Auth
  static const String checkPhone = '/auth/check-phone';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Parishes
  static const String parishes = '/parishes';
  static const String parishesSearch = '/parishes/search';
  static String parish(int id) => '/parishes/$id';

  // The authenticated faithful's parish membership.
  static const String userParish = '/user/parish';

  // Parish content — the "Fil paroissial" feed.
  static const String parishAnnouncements = '/parish/announcements';
}
