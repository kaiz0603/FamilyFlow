import 'package:familyflow/app/app.dart';
import 'package:familyflow/data/repositories/assessment_repository.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/challenge_repository.dart';
import 'package:familyflow/data/repositories/content_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/data/repositories/reminder_repository.dart';
import 'package:familyflow/data/services/google_auth_service.dart';
import 'package:familyflow/data/services/notification_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A stored profile for `users/{uid}` in tests.
Map<String, Object?> profileDoc({
  String name = 'Alice',
  String role = 'parent',
  int? birthYear,
  String locale = 'en',
}) => {
  'displayName': name,
  'role': role,
  'birthYear': birthYear ?? DateTime.now().year - 40,
  'locale': locale,
  'familyId': null,
  'createdAt': DateTime(2026),
};

/// Records what would be scheduled; no plugin involved.
class FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  int permissionRequests = 0;
  final scheduled = <({int id, DateTime at, String body, bool weekly})>[];
  int cancelAllCalls = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required bool weekly,
  }) async => scheduled.add((id: id, at: at, body: body, weekly: weekly));

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }
}

/// The Google picker: returns [token] (null = the user closed it) or throws [error].
class FakeGoogleAuthService implements GoogleAuthService {
  String? token = 'google-id-token';
  Object? error;
  int picks = 0;
  int signOuts = 0;

  @override
  Future<String?> idToken() async {
    picks++;
    if (error case final e?) throw e;
    return token;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

/// The app wired to in-memory Firebase fakes.
class TestApp {
  TestApp({
    String? signedInUid,
    Map<String, Object?>? profile,
    FakeFirebaseFirestore? db,
    MockFirebaseAuth? auth,
  }) : auth =
           auth ??
           MockFirebaseAuth(
             signedIn: signedInUid != null,
             mockUser: MockUser(
               uid: signedInUid ?? 'u1',
               email: 'a@example.com',
             ),
           ),
       db = db ?? FakeFirebaseFirestore() {
    SharedPreferences.setMockInitialValues({});
    if (signedInUid != null && profile != null) {
      this.db.collection('users').doc(signedInUid).set(profile);
    }
  }

  final MockFirebaseAuth auth;
  final FakeFirebaseFirestore db;
  final notifications = FakeNotificationService();
  final google = FakeGoogleAuthService();

  Widget widget({Locale? locale}) => FamilyFlowApp(
    auth: AuthRepository(auth, google),
    profiles: ProfileRepository(db),
    families: FamilyRepository(db),
    assessments: AssessmentRepository(db),
    challenges: ChallengeRepository(db),
    content: ContentRepository(),
    reminders: ReminderRepository(notifications),
    locale: locale,
  );
}

/// A phone-sized screen at 200% text (M7 accessibility pass). Overflows fail the test.
void phoneAt200(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
