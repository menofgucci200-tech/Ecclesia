/// Application-wide immutable constants.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Ecclesia';
  static const String appTagline = 'Le numérique au service de la mission.';

  /// Only Côte d'Ivoire is supported for now.
  static const String defaultCountryIso = 'CI';
  static const String defaultDialCode = '+225';

  /// A Côte d'Ivoire national number is 10 digits since the 2021 renumbering.
  static const int nationalPhoneLength = 10;

  static const int minPasswordLength = 4;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  /// Temporary support contact number, shown from the "Besoin d'aide ?" badge.
  static const String supportPhone = '0718002293';
  static const String supportPhoneFormatted = '07 18 00 22 93';
}
