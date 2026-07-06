/// The gender options collected during registration.
enum Gender {
  male('male', 'Homme'),
  female('female', 'Femme');

  const Gender(this.value, this.label);

  final String value;
  final String label;

  static Gender? fromValue(String? value) {
    for (final gender in Gender.values) {
      if (gender.value == value) {
        return gender;
      }
    }
    return null;
  }
}
