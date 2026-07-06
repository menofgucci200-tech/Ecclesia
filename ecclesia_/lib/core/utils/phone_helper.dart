import '../constants/app_constants.dart';

/// Formatting and normalization helpers for Ivorian phone numbers.
class PhoneHelper {
  const PhoneHelper._();

  /// Keep digits only, capped at the national length.
  static String digitsOnly(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length > AppConstants.nationalPhoneLength
        ? digits.substring(0, AppConstants.nationalPhoneLength)
        : digits;
  }

  /// Group digits by pairs for display: `0102030405` -> `01 02 03 04 05`.
  static String formatNational(String input) {
    final digits = digitsOnly(input);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 2 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Convert a local number to canonical E.164 (`+2250102030405`).
  static String toE164(String input) {
    return '${AppConstants.defaultDialCode}${digitsOnly(input)}';
  }
}
