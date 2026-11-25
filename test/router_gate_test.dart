import 'package:familyflow/app/router.dart';
import 'package:familyflow/app/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loading always shows the splash', () {
    expect(gate(SessionStatus.loading, Routes.home), Routes.splash);
    expect(gate(SessionStatus.loading, Routes.splash), isNull);
  });

  test('signed out stays on auth pages, everything else goes to welcome', () {
    for (final r in Routes.signedOutOnly) {
      expect(gate(SessionStatus.signedOut, r), isNull);
    }
    expect(gate(SessionStatus.signedOut, Routes.settings), Routes.welcome);
    expect(gate(SessionStatus.signedOut, Routes.profileSetup), Routes.welcome);
  });

  test('no profile is held at profile setup', () {
    expect(gate(SessionStatus.needsProfile, Routes.home), Routes.profileSetup);
    expect(
      gate(SessionStatus.needsProfile, Routes.signIn),
      Routes.profileSetup,
    );
    expect(gate(SessionStatus.needsProfile, Routes.profileSetup), isNull);
  });

  test('ready users skip auth and setup pages', () {
    expect(gate(SessionStatus.ready, Routes.signIn), Routes.home);
    expect(gate(SessionStatus.ready, Routes.profileSetup), Routes.home);
    expect(gate(SessionStatus.ready, Routes.splash), Routes.home);
    expect(gate(SessionStatus.ready, Routes.settings), isNull);
  });
}
