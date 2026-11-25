import 'package:google_sign_in/google_sign_in.dart';

/// The Google account picker. The only google_sign_in import; tests fake it.
class GoogleAuthService {
  Future<void>? _init;

  /// The Google ID token for Firebase, or null when the user closes the picker.
  /// Android finds the web client ID in google-services.json; iOS reads
  /// GIDClientID from Info.plist.
  Future<String?> idToken() async {
    await (_init ??= GoogleSignIn.instance.initialize());
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Forget the chosen account, so the next sign-in shows the picker again.
  Future<void> signOut() async {
    if (_init == null) return;
    await _init;
    await GoogleSignIn.instance.signOut();
  }
}
