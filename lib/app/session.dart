import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/models/user_profile.dart';

enum SessionStatus { loading, signedOut, needsProfile, ready }

/// Who is signed in and whether they have a profile. Drives the router gates
/// and the app language.
class Session extends ChangeNotifier {
  Session({required AuthRepository auth, required this._profiles}) {
    _authSub = auth.uidChanges().listen(_onUid);
  }

  final ProfileRepository _profiles;
  late final StreamSubscription<String?> _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  SessionStatus _status = SessionStatus.loading;
  SessionStatus get status => _status;

  String? _uid;
  String? get uid => _uid;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Locale? get locale => _profile == null ? null : Locale(_profile!.locale);

  void _onUid(String? uid) {
    _profileSub?.cancel();
    _uid = uid;
    _profile = null;
    if (uid == null) {
      _set(SessionStatus.signedOut);
      return;
    }
    _set(SessionStatus.loading);
    _profileSub = _profiles.watch(uid).listen(
      (p) {
        _profile = p;
        _set(p == null ? SessionStatus.needsProfile : SessionStatus.ready);
      },
      // Unreadable profile: send the user to setup, where a retry shows the error.
      onError: (_) => _set(SessionStatus.needsProfile),
    );
  }

  void _set(SessionStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
