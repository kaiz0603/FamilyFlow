import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/domain/models/user_profile.dart';
import 'package:familyflow/ui/features/onboarding/view_models/profile_setup_view_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final thisYear = DateTime.now().year;
  late FakeFirebaseFirestore db;
  late ProfileRepository profiles;
  late MockFirebaseAuth mockAuth;
  late ProfileSetupViewModel vm;

  setUp(() {
    db = FakeFirebaseFirestore();
    profiles = ProfileRepository(db);
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1'));
    vm = ProfileSetupViewModel(
      uid: 'u1',
      auth: AuthRepository(mockAuth),
      profiles: profiles,
    );
  });

  Future<bool> stored() async =>
      (await db.collection('users').doc('u1').get()).exists;

  test('ageInYear is year-based', () {
    expect(ageInYear(2013, 2026), 13);
    expect(ageInYear(2014, 2026), 12);
  });

  test('a 13-year-old child is saved', () async {
    final outcome = await vm.submit(
      role: Role.child,
      displayName: ' Mei ',
      birthYear: thisYear - 13,
      locale: 'zh',
    );
    expect(outcome, SetupOutcome.saved);
    final doc = (await db.collection('users').doc('u1').get()).data()!;
    expect(doc['displayName'], 'Mei');
    expect(doc['role'], 'child');
    expect(doc['familyId'], isNull);
  });

  test('under 13 writes nothing', () async {
    final outcome = await vm.submit(
      role: Role.child,
      displayName: 'Kid',
      birthYear: thisYear - 12,
      locale: 'en',
    );
    expect(outcome, SetupOutcome.underAge);
    expect(await stored(), isFalse);
  });

  test('a parent under 18 is sent back to choose Child', () async {
    final outcome = await vm.submit(
      role: Role.parent,
      displayName: 'Teen',
      birthYear: thisYear - 17,
      locale: 'en',
    );
    expect(outcome, SetupOutcome.parentTooYoung);
    expect(await stored(), isFalse);
  });

  test('removing an under-13 account signs the user out', () async {
    await vm.removeUnderAgeAccount();
    expect(mockAuth.currentUser, isNull);
  });

  test('watch maps the stored profile and follows updates', () async {
    await profiles.create(
      uid: 'u1',
      displayName: 'Alice',
      role: Role.parent,
      birthYear: thisYear - 40,
      locale: 'en',
    );
    final stream = profiles.watch('u1');
    expect((await stream.first)!.role, Role.parent);

    await profiles.update('u1', locale: 'zh');
    expect((await profiles.watch('u1').first)!.locale, 'zh');

    await profiles.delete('u1');
    expect(await profiles.watch('u1').first, isNull);
  });
}
