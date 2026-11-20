import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../utils/result.dart';

/// Sign in, sign up and password reset. On success the Session changes and the
/// router moves on by itself.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this._auth});

  final AuthRepository _auth;

  bool _busy = false;
  bool get busy => _busy;

  AppError? _error;
  AppError? get error => _error;

  Future<bool> signIn(String email, String password) =>
      _run(() => _auth.signIn(email, password));

  Future<bool> signUp(String email, String password) =>
      _run(() => _auth.signUp(email, password));

  Future<bool> signInWithGoogle() => _run(_auth.signInWithGoogle);

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _auth.sendPasswordReset(email));

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
