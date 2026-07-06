import '../constants/app_constants.dart';

/// Reusable, French-language form validators shared across auth screens.
/// Each returns `null` when valid, or an error message otherwise.
class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)+$",
  );

  static String? name(String? value, {String label = 'Ce champ'}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label est obligatoire.';
    }
    if (text.length < AppConstants.minNameLength) {
      return '$label doit contenir au moins ${AppConstants.minNameLength} caractères.';
    }
    if (text.length > AppConstants.maxNameLength) {
      return '$label est trop long.';
    }
    return null;
  }

  /// Validates the local Ivorian number (10 digits, leading zero).
  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Le numéro de téléphone est obligatoire.';
    }
    if (digits.length != AppConstants.nationalPhoneLength ||
        !digits.startsWith('0')) {
      return 'Entrez un numéro ivoirien valide (10 chiffres).';
    }
    return null;
  }

  static String? email(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? 'L\'adresse e-mail est obligatoire.' : null;
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Entrez une adresse e-mail valide.';
    }
    return null;
  }

  /// A simple, free-form password: the only rules are a minimal length and,
  /// separately, that the confirmation matches.
  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Le mot de passe est obligatoire.';
    }
    if (text.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) {
      return 'Veuillez confirmer le mot de passe.';
    }
    if (value != original) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
