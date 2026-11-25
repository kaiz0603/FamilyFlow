import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyflow/app/session.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/challenge_repository.dart';
import 'package:familyflow/data/repositories/family_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/domain/models/challenge.dart';
import 'package:familyflow/ui/features/challenge/view_models/challenge_view_model.dart';
import 'package:familyflow/utils/result.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'compare_test.dart' show seedFamily;
import 'helpers.dart';

Future<void> seedChallenge(
  FakeFirebaseFirestore db, {
  required String start,
  Map<String, List<String>> checkIns = const {},
  String status = 'active',
}) => db.doc('families/f1/challenges/c1').set({
  'adviceId': 'a1',
  'title': 'Ask one open question a day',
  'createdBy': 'mom',
  'participants': ['mom', 'kai'],
  'startDate': start,
  'endDate': addDays(start, 6),
  'status': status,
  'checkIns': checkIns,
  'createdAt': Timestamp.now(),
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dates', () {
    test('addDays crosses months and years', () {
      expect(addDays('2026-12-29', 6), '2027-01-04');
      expect(addDays('2028-02-28', 1), '2028-02-29');
      expect(localDate(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
    });

    test('the week, over, and who can check in', () {
      const c = Challenge(
        id: 'c',
        adviceId: 'a',
        title: 't',
        createdBy: 'mom',
        participants: ['mom', 'kai'],
        startDate: '2026-11-19',
        endDate: '2026-11-25',
        finished: false,
        checkIns: {
          'kai': ['2026-11-19'],
        },
      );
      expect(c.days.first, '2026-11-19');
      expect(c.days.last, '2026-11-25');
      expect(c.isOver('2026-11-25'), isFalse);
      expect(c.isOver('2026-11-26'), isTrue);
      expect(c.canCheckIn('mom', '2026-11-19'), isTrue);
      expect(c.canCheckIn('kai', '2026-11-19'), isFalse); // already today
      expect(c.canCheckIn('mia', '2026-11-19'), isFalse); // not a Participant
      expect(c.canCheckIn('mom', '2026-11-26'), isFalse); // week over
    });
  });

  group('ChallengeViewModel', () {
    late FakeFirebaseFirestore db;
    var now = DateTime(2026, 11, 19, 9);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = FakeFirebaseFirestore();
      now = DateTime(2026, 11, 19, 9);
      await seedFamily(db);
    });

    Future<ChallengeViewModel> vmFor(String uid) async {
      final session = Session(
        auth: AuthRepository(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid)),
        ),
        profiles: ProfileRepository(db),
      );
      await pumpEventQueue();
      final vm = ChallengeViewModel(
        session: session,
        families: FamilyRepository(db),
        challenges: ChallengeRepository(db),
        now: () => now,
      );
      await pumpEventQueue();
      return vm;
    }

    Future<List<Map<String, dynamic>>> activity() async => [
      for (final d in (await db.collection('families/f1/activity').get()).docs)
        d.data(),
    ];

    test('start writes the week and a challenge_started entry', () async {
      final vm = await vmFor('kai');
      expect(
        await vm.start(
          adviceId: 'a1',
          title: 'Hug',
          participants: ['mom', 'kai'],
        ),
        isTrue,
      );
      await pumpEventQueue();
      final c = vm.challenge!;
      expect(c.startDate, '2026-11-19');
      expect(c.endDate, '2026-11-25');
      expect(c.createdBy, 'kai');
      expect(vm.hasActive, isTrue);
      final a = await activity();
      expect(a.single['type'], 'challenge_started');
      expect(a.single['refId'], c.id);
      expect(a.single['actorId'], 'kai');
    });

    test('only one active Challenge per Family', () async {
      await seedChallenge(db, start: '2026-11-17');
      final vm = await vmFor('mia');
      expect(
        await vm.start(adviceId: 'a2', title: 'x', participants: ['mia']),
        isFalse,
      );
      expect(vm.error, AppError.challengeActive);
    });

    test('check in once per day; the grid counts it', () async {
      await seedChallenge(db, start: '2026-11-19');
      final vm = await vmFor('kai');
      expect(vm.canCheckIn, isTrue);
      expect(await vm.checkIn(), isTrue);
      await pumpEventQueue();
      expect(vm.challenge!.countFor('kai'), 1);
      expect(vm.canCheckIn, isFalse);
      now = now.add(const Duration(days: 1));
      expect(vm.canCheckIn, isTrue);
    });

    test('a non-Participant sees the grid but cannot check in', () async {
      await seedChallenge(db, start: '2026-11-19');
      final vm = await vmFor('mia');
      expect(vm.challenge, isNotNull);
      expect(vm.canCheckIn, isFalse);
    });

    test('after the week a Participant closes it once', () async {
      await seedChallenge(
        db,
        start: '2026-11-10',
        checkIns: {
          'kai': ['2026-11-10', '2026-11-12'],
        },
      );
      final vm = await vmFor('kai');
      await pumpEventQueue();
      final doc = await db.doc('families/f1/challenges/c1').get();
      expect(doc['status'], 'finished');
      expect(vm.challenge!.finished, isTrue);
      expect(vm.challenge!.countFor('kai'), 2);
      expect(vm.hasActive, isFalse);
      final a = await activity();
      expect(a.single['type'], 'challenge_finished');
      // The next one can start now.
      expect(
        await vm.start(adviceId: 'a2', title: 'Next', participants: ['kai']),
        isTrue,
      );
    });

    test('activity is newest first with the actor', () async {
      await db.collection('families/f1/activity').add({
        'type': 'member_joined',
        'actorId': 'kai',
        'refId': null,
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
      });
      await db.collection('families/f1/activity').add({
        'type': 'assessment_done',
        'actorId': 'mom',
        'refId': 'x',
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 2)),
      });
      final vm = await vmFor('mia');
      expect(vm.activity.map((a) => a.type), [
        ActivityType.assessmentDone,
        ActivityType.memberJoined,
      ]);
      expect(vm.nameOf('mom'), 'Mom');
      expect(vm.nameOf('gone'), isNull);
    });
  });

  group('Home', () {
    late FakeFirebaseFirestore db;

    setUp(() async {
      db = FakeFirebaseFirestore();
      await seedFamily(db);
    });

    Future<void> openHome(
      WidgetTester tester,
      String uid, {
      Locale? locale,
    }) async {
      final app = TestApp(signedInUid: uid, db: db);
      await tester.pumpWidget(app.widget(locale: locale ?? const Locale('en')));
      await tester.pumpAndSettle();
    }

    testWidgets('no Challenge yet points to Advice', (tester) async {
      await openHome(tester, 'mom');
      expect(
        find.text('No Challenge yet. Pick one from an Advice card.'),
        findsOneWidget,
      );
      expect(find.text('Browse Advice'), findsOneWidget);
    });

    testWidgets('check in from Home; activity shows live', (tester) async {
      await seedChallenge(db, start: localDate(DateTime.now()));
      await openHome(tester, 'kai');
      expect(find.text('Ask one open question a day'), findsOneWidget);
      expect(find.text('Day 1 of 7'), findsOneWidget);
      expect(find.bySemanticsLabel('Kai: 0 of 7 days'), findsOneWidget);
      await tester.ensureVisible(find.text('Check in today'));
      await tester.tap(find.text('Check in today'));
      await tester.pumpAndSettle();
      expect(find.text('You checked in today.'), findsOneWidget);
      expect(find.bySemanticsLabel('Kai: 1 of 7 days'), findsOneWidget);

      await db.collection('families/f1/activity').add({
        'type': 'challenge_started',
        'actorId': 'mom',
        'refId': 'c1',
        'createdAt': Timestamp.now(),
      });
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Mom started a Challenge'),
        200,
      );
      expect(find.text('Mom started a Challenge'), findsOneWidget);
    });

    testWidgets('a finished week shows totals and the next step', (
      tester,
    ) async {
      phoneAt200(tester);
      await seedChallenge(
        db,
        start: '2026-01-01',
        status: 'finished',
        checkIns: {
          'mom': ['2026-01-01'],
          'kai': ['2026-01-01', '2026-01-02', '2026-01-03'],
        },
      );
      await openHome(tester, 'mia');
      expect(find.text('Week finished'), findsOneWidget);
      expect(find.bySemanticsLabel('Kai: 3 of 7 days'), findsOneWidget);
      expect(find.bySemanticsLabel('Mom: 1 of 7 days'), findsOneWidget);
      expect(find.text('Start the next one'), findsOneWidget);
    });

    testWidgets('zh: the card and the activity in Chinese', (tester) async {
      await seedChallenge(db, start: localDate(DateTime.now()));
      await db.collection('families/f1/activity').add({
        'type': 'member_joined',
        'actorId': 'kai',
        'refId': null,
        'createdAt': Timestamp.now(),
      });
      await openHome(tester, 'mom', locale: const Locale('zh'));
      expect(find.text('本周亲子挑战'), findsOneWidget);
      expect(find.text('今天打卡'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Kai加入了家庭'), 200);
      expect(find.text('Kai加入了家庭'), findsOneWidget);
    });

    testWidgets('start a Challenge from an Advice card', (tester) async {
      await openHome(tester, 'mom');
      await tester.tap(find.widgetWithText(NavigationDestination, 'Advice'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start as a Family Challenge').first);
      await tester.pumpAndSettle();
      expect(find.text('New Challenge'), findsOneWidget);
      // Mom is picked by default; add Kai.
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Kai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final c = (await db.collection('families/f1/challenges').get()).docs;
      expect(c.single['participants'], ['mom', 'kai']);
      expect(c.single['startDate'], localDate(DateTime.now()));
      expect(find.text('Check in today'), findsOneWidget);
    });
  });
}
