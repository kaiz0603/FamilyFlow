import 'package:familyflow/app/session.dart';
import 'package:familyflow/data/repositories/assessment_repository.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/content_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/domain/models/assessment.dart';
import 'package:familyflow/domain/models/user_profile.dart';
import 'package:familyflow/ui/features/assessment/view_models/assessment_view_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // rootBundle for content
  late FakeFirebaseFirestore db;
  late AssessmentRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = FakeFirebaseFirestore();
    repo = AssessmentRepository(db);
    await db
        .doc('users/kid')
        .set(
          profileDoc(
            name: 'Kid',
            role: 'child',
            birthYear: DateTime.now().year - 14,
          )..['familyId'] = 'f1',
        );
    await db.doc('families/f1').set({
      'name': 'F',
      'createdBy': 'mom',
      'memberIds': ['mom', 'kid'],
    });
    await db.doc('families/f1/members/kid').set({
      'role': 'child',
      'displayName': 'Kid',
    });
    await db.doc('families/f1/members/mom').set({
      'role': 'parent',
      'displayName': 'Mom',
    });
  });

  Future<AssessmentViewModel> runFor(
    String uid,
    String subject,
    String name,
  ) async {
    final session = Session(
      auth: AuthRepository(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid)),
      ),
      profiles: ProfileRepository(db),
    );
    await pumpEventQueue();
    final vm = AssessmentViewModel(
      session: session,
      content: ContentRepository(),
      assessments: repo,
      subjectParentId: subject,
      subjectName: name,
    );
    await pumpEventQueue();
    return vm;
  }

  test(
    'a child rates a parent: scores to the family, answers kept private',
    () async {
      final vm = await runFor('kid', 'mom', 'Mom');
      expect(vm.step, AssessmentStep.intro);
      expect(vm.perspective, Perspective.childView);
      expect(vm.itemText(vm.items.first), contains('Mom'));

      vm.start();
      for (var i = 0; i < 24; i++) {
        vm.answer(5);
      }
      expect(vm.allAnswered, isTrue);
      await vm.submit();

      expect(vm.step, AssessmentStep.result);
      expect(vm.scores!.warmth, 67); // 8 × 5 and 4 reverse items flipped to 1
      expect(vm.advice, isNotEmpty);
      expect(
        vm.advice.every(
          (a) => a.role == Role.child && a.style == vm.scores!.style,
        ),
        isTrue,
      );

      final saved =
          (await db.collection('families/f1/assessments').get()).docs.single;
      expect(saved['perspective'], 'child_view');
      expect(saved['subjectParentId'], 'mom');
      expect(saved.data().containsKey('answers'), isFalse);
      final private = await db.doc('users/kid/answers/${saved.id}').get();
      expect((private['answers'] as Map).length, 24);
      final activity =
          (await db.collection('families/f1/activity').get()).docs.single;
      expect(activity['type'], 'assessment_done');
    },
  );

  test('a half-finished assessment resumes from the device draft', () async {
    final first = await runFor('kid', 'mom', 'Mom');
    first.start();
    for (var i = 0; i < 5; i++) {
      first.answer(4);
    }
    await pumpEventQueue();

    final again = await runFor('kid', 'mom', 'Mom');
    expect(again.hasDraft, isTrue);
    expect(again.index, 5);
  });

  test('leaving a family deletes your own assessments', () async {
    final vm = await runFor('kid', 'mom', 'Mom');
    vm.start();
    for (var i = 0; i < 24; i++) {
      vm.answer(3);
    }
    await vm.submit();
    await FamilyRepository(db).leave('f1', 'kid');
    expect(
      (await db.collection('families/f1/assessments').get()).docs,
      isEmpty,
    );
  });

  test('deleting the profile deletes the private answers', () async {
    final vm = await runFor('kid', 'mom', 'Mom');
    vm.start();
    for (var i = 0; i < 24; i++) {
      vm.answer(3);
    }
    await vm.submit();
    await ProfileRepository(db).delete('kid');
    expect((await db.collection('users/kid/answers').get()).docs, isEmpty);
    expect((await db.doc('users/kid').get()).exists, isFalse);
  });
}
