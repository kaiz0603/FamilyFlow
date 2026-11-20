import 'package:familyflow/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

final en = lookupAppLocalizations(const Locale('en'));

// MockUser's own fields are mutable, so any subclass trips this lint.
// ignore: must_be_immutable
class _GoogleUser extends MockUser {
  _GoogleUser()
    : super(
        uid: 'u1',
        email: 'a@gmail.com',
        providerData: [
          UserInfo.fromJson({
            'uid': 'g1',
            'providerId': 'google.com',
            'isAnonymous': false,
            'isEmailVerified': true,
          }),
        ],
      );

  int reauths = 0;

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) {
    expect(credential?.providerId, 'google.com');
    reauths++;
    return super.reauthenticateWithCredential(credential);
  }
}

void main() {
  Finder googleButton() => find.text(en.continueWithGoogle);

  group('Continue with Google', () {
    testWidgets('from Welcome, on to profile setup', (tester) async {
      final app = TestApp();
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(googleButton());
      await tester.pumpAndSettle();
      expect(app.google.picks, 1);
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('from Sign in too', (tester) async {
      final app = TestApp();
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.signIn));
      await tester.pumpAndSettle();
      await tester.tap(googleButton());
      await tester.pumpAndSettle();
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('closing the picker is not an error', (tester) async {
      final app = TestApp()..google.token = null;
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(googleButton());
      await tester.pumpAndSettle();
      expect(app.auth.currentUser, isNull);
      expect(find.text(en.errUnknown), findsNothing);
      expect(googleButton(), findsOneWidget);
    });

    testWidgets('a network failure shows the error', (tester) async {
      final app = TestApp()
        ..google.error = FirebaseAuthException(code: 'network-request-failed');
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(googleButton());
      await tester.pumpAndSettle();
      expect(find.text(en.errNetwork), findsOneWidget);
    });
  });

  group('deleting a Google account', () {
    late _GoogleUser user;
    late TestApp app;

    Future<void> confirmDelete(WidgetTester tester) async {
      user = _GoogleUser();
      app = TestApp(
        signedInUid: 'u1',
        profile: profileDoc(),
        auth: MockFirebaseAuth(signedIn: true, mockUser: user),
      );
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.deleteAccount));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text(en.deleteAccountGoogleNote), findsOneWidget);
    }

    testWidgets('re-authenticates with Google, then the profile is gone', (
      tester,
    ) async {
      await confirmDelete(tester);
      await tester.tap(find.text(en.deleteAccountConfirm));
      await tester.pumpAndSettle();
      expect(user.reauths, 1);
      expect((await app.db.doc('users/u1').get()).exists, isFalse);
    });

    testWidgets('closing the picker deletes nothing', (tester) async {
      await confirmDelete(tester);
      app.google.token = null;
      await tester.tap(find.text(en.deleteAccountConfirm));
      await tester.pumpAndSettle();
      expect(user.reauths, 0);
      expect((await app.db.doc('users/u1').get()).exists, isTrue);
      expect(find.text(en.errUnknown), findsNothing);
    });
  });
}
