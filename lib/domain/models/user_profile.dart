enum Role {
  parent(minAge: 18),
  child(minAge: 13);

  const Role({required this.minAge});

  /// Must match `firebase/firestore.rules` (users create).
  final int minAge;
}

/// Ages are year-based on purpose: FamilyFlow stores birth year, not birth date.
int ageInYear(int birthYear, [int? year]) =>
    (year ?? DateTime.now().year) - birthYear;

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.birthYear,
    required this.locale,
    this.familyId,
  });

  final String uid;
  final String displayName;
  final Role role;
  final int birthYear;

  /// `zh` or `en`.
  final String locale;
  final String? familyId;

  static const maxNameLength = 30;
  static const locales = ['zh', 'en'];
}
