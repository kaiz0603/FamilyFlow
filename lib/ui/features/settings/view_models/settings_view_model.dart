import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/family_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../utils/result.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._session,
    required this._auth,
    required this._profiles,
    required this._families,
  });

  final Session _session;
  final AuthRepository _auth;
  final ProfileRepository _profiles;
  final FamilyRepository _families;

  UserProfile? get profile => _session.profile;
  String? get email => _auth.currentEmail;

  bool _busy = false;
  bool get busy => _busy;

  AppError? _error;
  AppError? get error => _error;

  Future<void> setLocale(String locale) async {
    final p = profile;
    if (p == null || p.locale == locale) return;
    await _run(() => _profiles.update(p.uid, locale: locale));
  }

  Future<void> signOut() => _run(_auth.signOut);

  bool get inFamily => profile?.familyId != null;

  Future<bool> leaveFamily() async {
    final p = profile;
    if (p?.familyId == null) return false;
    return _run(() => _families.leaveFamily(p!.familyId!, p));
  }

  /// Re-authenticate first, so a wrong password deletes nothing. Then leave
  /// the Family (or withdraw a request) before the profile goes.
  /// M3 adds private answers (docs/PRIVACY.md).
  Future<bool> deleteAccount(String password) async {
    final p = profile;
    if (p == null) return false;
    return _run(() async {
      if (await _auth.reauthenticate(password) case final Err<void> e) return e;
      if (p.pendingFamilyId case final fid?) {
        if (await _families.cancelRequest(fid, p.uid) case final Err<void> e) {
          return e;
        }
      }
      if (p.familyId case final fid?) {
        if (await _families.leaveFamily(fid, p) case final Err<void> e) {
          return e;
        }
      }
      if (await _profiles.delete(p.uid) case final Err<void> e) return e;
      return _auth.deleteCurrentUser();
    });
  }

  Future<bool> _run(Future<Result<void>> Function() op) async {
    _busy = true;
    _error = null;
    notifyListeners();
    final result = await op();
    _busy = false;
    if (result case Err(:final error)) _error = error;
    notifyListeners();
    return result is Ok;
  }
}
