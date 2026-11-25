import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyflow/app/session.dart';
import 'package:familyflow/data/repositories/assessment_repository.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/domain/models/family.dart';
import 'package:familyflow/domain/models/user_profile.dart';
import 'package:familyflow/ui/features/home/view_models/home_view_model.dart';
import 'package:familyflow/utils/result.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

UserProfile profile(String uid, Role role, {String? familyId}) => UserProfile(
  uid: uid,
  displayName: uid,
  role: role,
  birthYear: 1980,
  locale: 'en',
  familyId: familyId,
);

void main() {
  late FakeFirebaseFirestore db;
  late FamilyRepository families;

  Future<Map<String, dynamic>?> read(String path) async =>
      (await db.doc(path).get()).data();

  Future<int> count(String path) async =>
      (await db.collection(path).get()).docs.length;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = FakeFirebaseFirestore();
    families = FamilyRepository(db);
    for (final (uid, role) in [
      ('mom', 'parent'),
      ('dad', 'parent'),
      ('kid', 'child'),
    ]) {
      await db.doc('users/$uid').set(profileDoc(name: uid, role: role));
    }
  });

  Future<String> createFamily() async => (await families.createFamily(
    uid: 'mom',
    name: ' Lins ',
    displayName: 'mom',
  ) as Ok<String>).value;

  test(
    'creating a family writes the family, the founder and the profile',
    () async {
      final fid = await createFamily();
      expect((await read('families/$fid'))!['name'], 'Lins');
      expect((await read('families/$fid'))!['memberIds'], ['mom']);
      expect((await read('families/$fid/members/mom'))!['role'], 'parent');
      expect((await read('users/mom'))!['familyId'], fid);
    },
  );

  test('invite codes use the readable alphabet and expire in 7 days', () async {
    final fid = await createFamily();
    final invite =
        (await families.createInvite(fid, 'mom') as Ok<Invite>).value;
    expect(Invite.isWellFormed(invite.code), isTrue);
    final stored = (await read('invites/${invite.code}'))!;
    expect(stored['familyId'], fid);
    final days = (stored['expiresAt'] as Timestamp)
        .toDate()
        .difference(DateTime.now())
        .inHours;
    expect(days, inInclusiveRange(167, 168));
  });

  test(
    'codes are found case- and space-insensitively; bad codes are refused',
    () async {
      final fid = await createFamily();
      final code =
          (await families.createInvite(fid, 'mom') as Ok<Invite>).value.code;
      final spaced = '${code.substring(0, 3)} ${code.substring(3)}'
          .toLowerCase();
      expect(await families.findFamilyByCode(spaced), isA<Ok<String>>());

      await db.doc('invites/OLD234').set({
        'familyId': fid,
        'createdBy': 'mom',
        'expiresAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      });
      for (final bad in ['OLD234', 'NONE22', 'ABC', 'ABC0O1']) {
        final r = await families.findFamilyByCode(bad);
        expect((r as Err).error, AppError.invalidInviteCode, reason: bad);
      }
    },
  );

  test('request → approve → complete join', () async {
    final fid = await createFamily();
    final code =
        (await families.createInvite(fid, 'mom') as Ok<Invite>).value.code;
    await families.requestToJoin(
      uid: 'kid',
      fid: fid,
      code: code,
      profile: profile('kid', Role.child),
    );
    expect((await read('users/kid'))!['pendingFamilyId'], fid);

    final pending = await families.watchPendingRequests(fid).first;
    expect(pending.single.role, Role.child);
    await families.approve(fid, pending.single);
    expect((await read('families/$fid/members/kid'))!['role'], 'child');
    expect((await read('families/$fid'))!['memberIds'], ['mom', 'kid']);

    await families.completeJoin(fid, 'kid');
    final kid = (await read('users/kid'))!;
    expect(kid['familyId'], fid);
    expect(kid['pendingFamilyId'], isNull);
    expect(await read('families/$fid/joinRequests/kid'), isNull);
    final activity = await db.collection('families/$fid/activity').get();
    expect(activity.docs.single['type'], 'member_joined');
  });

  test('a removed member sees null from watchMembers', () async {
    final fid = await createFamily();
    await db.doc('families/$fid/members/kid').set({
      'role': 'child',
      'displayName': 'kid',
    });
    final stream = families.watchMembers(fid, 'kid');
    expect((await stream.first)!.length, 2);
    await families.removeMember(fid, 'mom', 'kid');
    expect(await families.watchMembers(fid, 'kid').first, isNull);
  });

  test('removing a member deletes their assessments, not others', () async {
    final fid = await createFamily();
    await db.doc('families/$fid/members/kid').set({
      'role': 'child',
      'displayName': 'kid',
    });
    await db.doc('families/$fid').update({
      'memberIds': ['mom', 'kid'],
    });
    for (final rater in ['kid', 'kid', 'mom']) {
      await db.collection('families/$fid/assessments').add({'raterId': rater});
    }

    expect(await families.removeMember(fid, 'mom', 'kid'), isA<Ok<void>>());
    final left = await db.collection('families/$fid/assessments').get();
    expect([for (final d in left.docs) d['raterId']], ['mom']);
    expect(await read('families/$fid/members/kid'), isNull);
    expect((await read('families/$fid'))!['memberIds'], ['mom']);
    final activity = await db.collection('families/$fid/activity').get();
    expect(activity.docs.single['refId'], 'kid');
  });

  test('a child or a non-last parent just leaves', () async {
    final fid = await createFamily();
    await db.doc('families/$fid/members/dad').set({
      'role': 'parent',
      'displayName': 'dad',
    });
    await db.doc('users/dad').update({'familyId': fid});

    await families.leaveFamily(fid, profile('dad', Role.parent, familyId: fid));
    expect(await read('families/$fid'), isNotNull);
    expect(await read('families/$fid/members/dad'), isNull);
    expect((await read('families/$fid'))!['memberIds'], ['mom']);
    expect((await read('users/dad'))!['familyId'], isNull);
  });

  test('the last parent leaving dissolves the family', () async {
    final fid = await createFamily();
    await families.createInvite(fid, 'mom');
    await db.doc('families/$fid/members/kid').set({
      'role': 'child',
      'displayName': 'kid',
    });
    await db.doc('families/$fid/challenges/c1').set({'status': 'active'});

    await families.leaveFamily(fid, profile('mom', Role.parent, familyId: fid));
    expect(await read('families/$fid'), isNull);
    expect(await count('families/$fid/members'), 0);
    expect(await count('families/$fid/challenges'), 0);
    expect(await count('families/$fid/activity'), 0);
    expect(await count('invites'), 0);
    expect((await read('users/mom'))!['familyId'], isNull);
  });

  group('HomeViewModel', () {
    Future<HomeViewModel> homeFor(String uid) async {
      final session = Session(
        auth: AuthRepository(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid)),
        ),
        profiles: ProfileRepository(db),
      );
      final vm = HomeViewModel(
        session: session,
        families: families,
        assessmentRepo: AssessmentRepository(db),
      );
      await pumpEventQueue();
      return vm;
    }

    test('a parent without a family can create one and lands in it', () async {
      final vm = await homeFor('mom');
      expect(vm.mode, HomeMode.noFamily);
      expect(vm.isParent, isTrue);

      expect(await vm.createFamily('Lins'), isTrue);
      await pumpEventQueue();
      expect(vm.mode, HomeMode.inFamily);
      expect(vm.family!.name, 'Lins');
      expect(vm.members.single.uid, 'mom');
    });

    test('a joiner moves in by itself once approved', () async {
      final fid = await createFamily();
      final code =
          (await families.createInvite(fid, 'mom') as Ok<Invite>).value.code;
      final vm = await homeFor('kid');

      expect(await vm.joinWithCode(code), isTrue);
      await pumpEventQueue();
      expect(vm.mode, HomeMode.pending);

      final request = (await families.watchPendingRequests(fid).first).single;
      await families.approve(fid, request);
      await pumpEventQueue();
      expect((await read('users/kid'))!['familyId'], fid);
      expect(vm.mode, HomeMode.inFamily);
    });

    test('a wrong code shows an error and stays in setup', () async {
      final vm = await homeFor('kid');
      expect(await vm.joinWithCode('ZZZZ22'), isFalse);
      expect(vm.error, AppError.invalidInviteCode);
      expect(vm.mode, HomeMode.noFamily);
    });
  });
}
