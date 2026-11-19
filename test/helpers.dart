import 'package:familyflow/app/app.dart';
import 'package:familyflow/data/repositories/assessment_repository.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/content_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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

/// The app wired to in-memory Firebase fakes.
class TestApp {
  TestApp({
    String? signedInUid,
    Map<String, Object?>? profile,
    FakeFirebaseFirestore? db,
  }) : auth = MockFirebaseAuth(
         signedIn: signedInUid != null,
         mockUser: MockUser(uid: signedInUid ?? 'u1', email: 'a@example.com'),
       ),
       db = db ?? FakeFirebaseFirestore() {
    SharedPreferences.setMockInitialValues({});
    if (signedInUid != null && profile != null) {
      this.db.collection('users').doc(signedInUid).set(profile);
    }
  }

  final MockFirebaseAuth auth;
  final FakeFirebaseFirestore db;

  Widget widget({Locale? locale}) => FamilyFlowApp(
    auth: AuthRepository(auth),
    profiles: ProfileRepository(db),
    families: FamilyRepository(db),
    assessments: AssessmentRepository(db),
    content: ContentRepository(),
    locale: locale,
  );
}
