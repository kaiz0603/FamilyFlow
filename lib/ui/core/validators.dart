import '../../domain/models/user_profile.dart';
import '../../l10n/app_localizations.dart';

/// Form validators. Final checks live in the Firestore rules and Firebase Auth.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const minPasswordLength = 8;

  static String? email(AppLocalizations l, String? v) {
    if (v == null || v.trim().isEmpty) return l.fieldRequired;
    return _email.hasMatch(v.trim()) ? null : l.invalidEmailField;
  }

  static String? newPassword(AppLocalizations l, String? v) {
    if (v == null || v.isEmpty) return l.fieldRequired;
    return v.length < minPasswordLength ? l.passwordTooShort : null;
  }

  static String? required(AppLocalizations l, String? v) =>
      v == null || v.trim().isEmpty ? l.fieldRequired : null;

  static String? displayName(AppLocalizations l, String? v) {
    if (v == null || v.trim().isEmpty) return l.fieldRequired;
    return v.trim().length > UserProfile.maxNameLength
        ? l.nameTooLong(UserProfile.maxNameLength)
        : null;
  }
}
