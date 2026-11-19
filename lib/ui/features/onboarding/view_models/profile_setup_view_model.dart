import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../utils/result.dart';

enum SetupOutcome { saved, underAge, parentTooYoung, failed }

class ProfileSetupViewModel extends ChangeNotifier {
  ProfileSetupViewModel({
    required this._uid,
    required this._auth,
    required this._profiles,
  });

  final String _uid;
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  bool _busy = false;
  bool get busy => _busy;

  AppError? _error;
  AppError? get error => _error;

  Future<SetupOutcome> submit({
    required Role role,
    required String displayName,
    required int birthYear,
    required String locale,
  }) async {
    final age = ageInYear(birthYear);
    if (age < Role.child.minAge) return SetupOutcome.underAge;
    if (role == Role.parent && age < Role.parent.minAge) {
      return SetupOutcome.parentTooYoung;
    }
    _busy = true;
    _error = null;
    notifyListeners();
    final result = await _profiles.create(
      uid: _uid,
      displayName: displayName,
      role: role,
      birthYear: birthYear,
      locale: locale,
    );
    _busy = false;
    if (result case Err(:final error)) _error = error;
    notifyListeners();
    return result is Ok ? SetupOutcome.saved : SetupOutcome.failed;
  }

  /// Under-13: nothing was written to Firestore; remove the fresh sign-in too.
  /// Signs out even if the delete fails, so the user is never left half in.
  Future<void> removeUnderAgeAccount() async {
    await _auth.deleteCurrentUser();
    await _auth.signOut();
  }

  Future<void> useAnotherAccount() => _auth.signOut();
}
