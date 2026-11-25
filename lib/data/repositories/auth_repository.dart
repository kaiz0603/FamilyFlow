import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/result.dart';
import '../services/google_auth_service.dart';

/// Sign-in state and credentials. Wraps [FirebaseAuth]; nothing above this
/// layer imports firebase_auth.
class AuthRepository {
  AuthRepository(this._auth, [GoogleAuthService? google])
    : _google = google ?? GoogleAuthService();

  final FirebaseAuth _auth;
  final GoogleAuthService _google;

  Stream<String?> uidChanges() => _auth.authStateChanges().map((u) => u?.uid);

  String? get currentEmail => _auth.currentUser?.email;

  Future<Result<void>> signUp(String email, String password) => guard(
    () => _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<Result<void>> signIn(String email, String password) => guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  /// Closing the Google picker is not an error: nothing happens.
  Future<Result<void>> signInWithGoogle() => guard(() async {
    final token = await _google.idToken();
    if (token == null) return;
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  });

  /// Accounts with a password re-authenticate with it; Google-only ones with Google.
  bool get hasPassword =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  Future<Result<void>> sendPasswordReset(String email) =>
      guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<Result<void>> signOut() => guard(() async {
    await _auth.signOut();
    await _google.signOut();
  });

  /// Firebase only deletes accounts after a recent sign-in.
  Future<Result<void>> reauthenticate(String password) => guard(() async {
    final user = _auth.currentUser!;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
  });

  /// Ok(false) when the user closed the Google picker.
  Future<Result<bool>> reauthenticateWithGoogle() => guard(() async {
    final token = await _google.idToken();
    if (token == null) return false;
    await _auth.currentUser!.reauthenticateWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
    return true;
  });

  Future<Result<void>> deleteCurrentUser() =>
      guard(() => _auth.currentUser!.delete());
}
