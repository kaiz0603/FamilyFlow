import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyflow/app/session.dart';
import 'package:familyflow/data/repositories/assessment_repository.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/domain/assessment/scoring.dart';
import 'package:familyflow/ui/features/compare/view_models/compare_view_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Family f1: parent mom, children kai and mia.
Future<void> seedFamily(FakeFirebaseFirestore db) async {
  await db.doc('families/f1').set({'name': 'Lims', 'createdBy': 'mom'});
  for (final (uid, name, role) in [
    ('mom', 'Mom', 'parent'),
    ('kai', 'Kai', 'child'),
    ('mia', 'Mia', 'child'),
  ]) {
    await db.doc('families/f1/members/$uid').set({
      'role': role,
      'displayName': name,
    });
    await db
        .doc('users/$uid')
        .set(
          profileDoc(
            name: name,
            role: role,
            birthYear: DateTime.now().year - (role == 'child' ? 14 : 40),
          )..['familyId'] = 'f1',
        );
  }
}

Future<void> addAssessment(
  FakeFirebaseFirestore db, {
  required String rater,
  required int w,
  required int d,
  String subject = 'mom',
  String version = '1.0',
  required DateTime at,
}) => db.collection('families/f1/assessments').add({
  'raterId': rater,
  'subjectParentId': subject,
  'perspective': rater == subject ? 'self' : 'child_view',
  'warmth': w,
  'demandingness': d,
  'style': styleFor(w, d).name,
  'contentVersion': version,
  'createdAt': Timestamp.fromDate(at),
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = FakeFirebaseFirestore();
    await seedFamily(db);
  });

  Future<CompareViewModel> vmFor(String uid) async {
    final session = Session(
      auth: AuthRepository(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid)),
      ),
      profiles: ProfileRepository(db),
    );
    await pumpEventQueue();
    final vm = CompareViewModel(
      session: session,
      families: FamilyRepository(db),
      assessmentRepo: AssessmentRepository(db),
    );
    await pumpEventQueue();
    return vm;
  }

  group('CompareViewModel', () {
    test('a parent sees their latest self and each child view', () async {
      await addAssessment(db, rater: 'mom', w: 40, d: 40, at: DateTime(2026));
      await addAssessment(
        db,
        rater: 'mom',
        w: 70,
        d: 60,
        at: DateTime(2026, 2),
      );
      await addAssessment(
        db,
        rater: 'kai',
        w: 30,
        d: 80,
        at: DateTime(2026, 3),
      );
      await addAssessment(
        db,
        rater: 'mia',
        w: 65,
        d: 55,
        at: DateTime(2026, 3),
      );
      final vm = await vmFor('mom');

      final c = vm.cards.single;
      expect(c.self!.warmth, 70);
      expect(
        {for (final v in c.views) v.child.uid: v.view.warmth},
        {'kai': 30, 'mia': 65},
      );
      expect(c.history, hasLength(4));
      expect(c.history.first.warmth, 40); // oldest first
    });

    test('a new major version hides older results from the chart', () async {
      await addAssessment(db, rater: 'mom', w: 70, d: 60, at: DateTime(2026));
      await addAssessment(
        db,
        rater: 'kai',
        w: 30,
        d: 30,
        version: '2.0',
        at: DateTime(2026, 2),
      );
      final vm = await vmFor('mom');

      final c = vm.cards.single;
      expect(c.self, isNull);
      expect(c.views.single.view.contentVersion, '2.0');
      expect(c.history, hasLength(2));
    });

    test(
      'a child sees only parents they rated, with only their view',
      () async {
        await addAssessment(db, rater: 'mom', w: 70, d: 60, at: DateTime(2026));
        await addAssessment(db, rater: 'mia', w: 65, d: 55, at: DateTime(2026));
        var vm = await vmFor('kai');
        expect(vm.cards, isEmpty);
        expect(vm.unratedParents.single.uid, 'mom');

        await addAssessment(
          db,
          rater: 'kai',
          w: 30,
          d: 80,
          at: DateTime(2026, 2),
        );
        vm = await vmFor('kai');
        final c = vm.cards.single;
        expect(c.views.single.child.uid, 'kai');
        expect(c.history.map((a) => a.raterId), ['mom', 'kai']);
        expect(vm.unratedParents, isEmpty);
      },
    );
  });

  group('Compare tab', () {
    Future<void> open(WidgetTester tester, String uid) async {
      final app = TestApp(signedInUid: uid, db: db);
      await tester.pumpWidget(app.widget(locale: const Locale('en')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavigationDestination, 'Compare'));
      await tester.pumpAndSettle();
    }

    testWidgets('none: invites the parent and the children', (tester) async {
      await open(tester, 'mom');
      expect(
        find.text('Take your self-check to put your own view on the chart.'),
        findsOneWidget,
      );
      expect(
        find.text('Ask your Children to rate you. Their views show up here.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('No results yet')), findsOneWidget);
    });

    testWidgets('one side: self only', (tester) async {
      await addAssessment(db, rater: 'mom', w: 70, d: 60, at: DateTime(2026));
      await open(tester, 'mom');
      expect(
        find.text('Take your self-check to put your own view on the chart.'),
        findsNothing,
      );
      expect(
        find.text('Ask your Children to rate you. Their views show up here.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Mom \\(self\\): warmth 70, demandingness 60, Authoritative'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('both: a parent with 2 children sees both child views', (
      tester,
    ) async {
      await addAssessment(db, rater: 'mom', w: 70, d: 60, at: DateTime(2026));
      await addAssessment(
        db,
        rater: 'kai',
        w: 40,
        d: 62,
        at: DateTime(2026, 2),
      );
      await addAssessment(
        db,
        rater: 'mia',
        w: 75,
        d: 30,
        at: DateTime(2026, 2),
      );
      await open(tester, 'mom');

      final chart = find.bySemanticsLabel(
        RegExp('Kai: warmth 40.*Mia: warmth 75'),
      );
      expect(chart, findsOneWidget);
      expect(
        find.text(
          'Kai experiences much less warmth than Mom sees in their self-check.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Kai and Mom see demandingness about the same way.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Mia experiences a bit more warmth than Mom sees in their self-check.',
        ),
        findsNothing, // gap 5: same
      );
      expect(
        find.text(
          'Mia experiences much less demandingness than Mom sees in their self-check.',
        ),
        findsOneWidget,
      );
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('a child sees the parent they rated; missing self is named', (
      tester,
    ) async {
      await addAssessment(db, rater: 'kai', w: 40, d: 62, at: DateTime(2026));
      await open(tester, 'kai');
      expect(
        find.text('Mom has not done a self-check yet. Ask them to take it.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('Kai: warmth 40')), findsOneWidget);
    });

    testWidgets('zh: gap copy in Chinese', (tester) async {
      await addAssessment(db, rater: 'mom', w: 70, d: 60, at: DateTime(2026));
      await addAssessment(
        db,
        rater: 'kai',
        w: 40,
        d: 62,
        at: DateTime(2026, 2),
      );
      await tester.pumpWidget(
        TestApp(signedInUid: 'mom', db: db).widget(locale: const Locale('zh')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavigationDestination, '对比'));
      await tester.pumpAndSettle();
      expect(find.text('Kai感受到的温暖回应比Mom自评的明显低。'), findsOneWidget);
      expect(find.text('Kai和Mom对规则要求的看法基本一致。'), findsOneWidget);
    });
  });
}
