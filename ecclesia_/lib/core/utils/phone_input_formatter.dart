import 'package:flutter/services.dart';

import 'phone_helper.dart';

/// Formats the phone field as the user types: digits grouped by pairs,
/// e.g. `01 02 03 04 05`, capped at the national length.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = PhoneHelper.formatNational(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
