import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/result.dart';

/// Sign-in state and credentials. Wraps [FirebaseAuth]; nothing above this
/// layer imports firebase_auth.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

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

  Future<Result<void>> sendPasswordReset(String email) =>
      guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<Result<void>> signOut() => guard(_auth.signOut);

  /// Firebase only deletes accounts after a recent sign-in.
  Future<Result<void>> reauthenticate(String password) => guard(() async {
    final user = _auth.currentUser!;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
  });

  Future<Result<void>> deleteCurrentUser() =>
      guard(() => _auth.currentUser!.delete());
}
