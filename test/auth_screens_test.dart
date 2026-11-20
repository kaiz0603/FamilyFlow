import 'dart:async';

import 'package:familyflow/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// Auth calls that can fail or stay pending, to show the error and busy states.
class _Auth extends MockFirebaseAuth {
  _Auth({super.signedIn, super.mockUser});

  Object? error;
  Completer<void>? hold;

  Future<void> _gate() async {
    await hold?.future;
    if (error case final e?) throw e;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _gate();
    return super.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _gate();
    return super.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    await _gate();
    return super.sendPasswordResetEmail(email: email);
  }
}

class _Gate {
  Object? error;
  Completer<void>? hold;
}

// MockUser's own fields are mutable, so any subclass trips this lint.
// ignore: must_be_immutable
class _User extends MockUser {
  _User() : super(uid: 'u1', email: 'a@example.com');

  final gate = _Gate();

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) async {
    await gate.hold?.future;
    if (gate.error case final e?) throw e;
    return super.reauthenticateWithCredential(credential);
  }
}

final en = lookupAppLocalizations(const Locale('en'));
final zh = lookupAppLocalizations(const Locale('zh'));

FirebaseAuthException authError(String code) =>
    FirebaseAuthException(code: code);

void main() {
  Future<void> open(
    WidgetTester tester,
    _Auth auth,
    String button, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(TestApp(auth: auth).widget(locale: locale));
    await tester.pumpAndSettle();
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String email, String password) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  Finder submit(String label) => find.widgetWithText(FilledButton, label);

  group('sign in', () {
    testWidgets('empty form shows required fields', (tester) async {
      await open(tester, _Auth(), en.signIn);
      await tester.tap(submit(en.signIn));
      await tester.pump();
      expect(find.text(en.fieldRequired), findsNWidgets(2));
    });

    testWidgets('wrong password shows the error', (tester) async {
      final auth = _Auth()..error = authError('invalid-credential');
      await open(tester, auth, en.signIn);
      await fill(tester, 'a@example.com', 'wrong-pass');
      await tester.tap(submit(en.signIn));
      await tester.pumpAndSettle();
      expect(find.text(en.errInvalidCredentials), findsOneWidget);
    });

    testWidgets('busy while signing in, then on to profile setup', (
      tester,
    ) async {
      final auth = _Auth()..hold = Completer();
      await open(tester, auth, en.signIn);
      await fill(tester, 'a@example.com', 'secret-pass');
      await tester.tap(submit(en.signIn));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      auth.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('zh: empty form shows required fields in Chinese', (
      tester,
    ) async {
      await open(tester, _Auth(), zh.signIn, locale: const Locale('zh'));
      expect(find.widgetWithText(AppBar, zh.signIn), findsOneWidget);
      await tester.tap(submit(zh.signIn));
      await tester.pump();
      expect(find.text(zh.fieldRequired), findsNWidgets(2));
    });
  });

  group('password reset', () {
    Future<void> openDialog(WidgetTester tester, _Auth auth) async {
      await open(tester, auth, en.signIn);
      await tester.tap(find.text(en.forgotPassword));
      await tester.pumpAndSettle();
    }

    testWidgets('empty or bad email stays in the dialog', (tester) async {
      await openDialog(tester, _Auth());
      await tester.tap(find.text(en.sendLink));
      await tester.pump();
      expect(find.text(en.fieldRequired), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextFormField),
        ),
        'not-an-email',
      );
      await tester.tap(find.text(en.sendLink));
      await tester.pump();
      expect(find.text(en.invalidEmailField), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('sent: the same message whether or not the account exists', (
      tester,
    ) async {
      await openDialog(tester, _Auth());
      await tester.enterText(find.byType(TextFormField).last, 'a@example.com');
      await tester.tap(find.text(en.sendLink));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(en.resetEmailSent), findsOneWidget);
    });

    testWidgets('busy while sending, then a network error', (tester) async {
      final auth = _Auth()
        ..hold = Completer()
        ..error = authError('network-request-failed');
      await openDialog(tester, auth);
      await tester.enterText(find.byType(TextFormField).last, 'a@example.com');
      await tester.tap(find.text(en.sendLink));
      await tester.pump();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      auth.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.text(en.errNetwork), findsOneWidget);
      expect(find.text(en.resetEmailSent), findsNothing);
    });
  });

  group('sign up', () {
    testWidgets('empty and short password are refused', (tester) async {
      await open(tester, _Auth(), en.signUp);
      await tester.tap(submit(en.signUp));
      await tester.pump();
      expect(find.text(en.fieldRequired), findsNWidgets(2));

      await fill(tester, 'a@example.com', 'short');
      await tester.tap(submit(en.signUp));
      await tester.pump();
      expect(find.text(en.passwordTooShort), findsOneWidget);
    });

    testWidgets('a taken email shows the error', (tester) async {
      final auth = _Auth()..error = authError('email-already-in-use');
      await open(tester, auth, en.signUp);
      await fill(tester, 'a@example.com', 'long-enough');
      await tester.tap(submit(en.signUp));
      await tester.pumpAndSettle();
      expect(find.text(en.errEmailInUse), findsOneWidget);
    });

    testWidgets('busy while creating, then on to profile setup', (
      tester,
    ) async {
      final auth = _Auth()..hold = Completer();
      await open(tester, auth, en.signUp);
      await fill(tester, 'new@example.com', 'long-enough');
      await tester.tap(submit(en.signUp));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      auth.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.text('About you'), findsOneWidget);
    });
  });

  group('account deletion', () {
    late _User user;
    late TestApp app;

    Future<void> openDialog(WidgetTester tester) async {
      user = _User();
      app = TestApp(
        signedInUid: 'u1',
        profile: profileDoc(),
        auth: _Auth(signedIn: true, mockUser: user),
      );
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.deleteAccount));
      await tester.pumpAndSettle();
    }

    Finder confirm() => find.text(en.deleteAccountConfirm);
    Finder deleteTile() => find.widgetWithText(ListTile, en.deleteAccount);

    testWidgets('an empty password keeps the dialog open', (tester) async {
      await openDialog(tester);
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect((await app.db.doc('users/u1').get()).exists, isTrue);
    });

    testWidgets('a wrong password deletes nothing and shows the error', (
      tester,
    ) async {
      await openDialog(tester);
      user.gate.error = authError('wrong-password');
      await tester.enterText(find.byType(TextField).last, 'wrong-pass');
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(find.text(en.errInvalidCredentials), findsOneWidget);
      expect((await app.db.doc('users/u1').get()).exists, isTrue);
    });

    testWidgets('busy, then the profile is gone', (tester) async {
      await openDialog(tester);
      user.gate.hold = Completer();
      await tester.enterText(find.byType(TextField).last, 'secret-pass');
      await tester.tap(confirm());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // dialog closes
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.widget<ListTile>(deleteTile()).onTap, isNull);

      user.gate.hold!.complete();
      await tester.pumpAndSettle();
      expect((await app.db.doc('users/u1').get()).exists, isFalse);
    });
  });
}
