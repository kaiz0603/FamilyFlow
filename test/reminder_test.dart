import 'package:familyflow/app/reminder_sync.dart';
import 'package:familyflow/app/session.dart';
import 'package:familyflow/data/repositories/auth_repository.dart';
import 'package:familyflow/data/repositories/challenge_repository.dart';
import 'package:familyflow/data/repositories/profile_repository.dart';
import 'package:familyflow/data/repositories/reminder_repository.dart';
import 'package:familyflow/domain/models/challenge.dart';
import 'package:familyflow/domain/models/reminder.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'challenge_test.dart' show seedChallenge;
import 'compare_test.dart' show seedFamily;
import 'helpers.dart';

// A Friday.
final _now = DateTime(2026, 11, 20, 8);

Challenge _challenge({
  List<String> participants = const ['mom', 'kai'],
  Map<String, List<String>> checkIns = const {},
  String start = '2026-11-19',
  bool finished = false,
}) => Challenge(
  id: 'c1',
  adviceId: 'a1',
  title: 't',
  createdBy: 'mom',
  participants: participants,
  startDate: start,
  endDate: addDays(start, 6),
  finished: finished,
  checkIns: checkIns,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('planReminders', () {
    test('both off by default: nothing is planned', () {
      expect(_now.weekday, DateTime.friday);
      expect(
        planReminders(
          const ReminderSettings(),
          uid: 'kai',
          challenge: _challenge(),
          now: _now,
        ),
        isEmpty,
      );
    });

    test('weekly: the next matching weekday, rolling a week if past', () {
      List<PlannedReminder> weekly(int weekday, int minutes) => planReminders(
        ReminderSettings(
          weeklyOn: true,
          weekday: weekday,
          weeklyMinutes: minutes,
        ),
        uid: 'kai',
        challenge: null,
        now: _now,
      );
      expect(
        weekly(DateTime.sunday, 19 * 60).single.at,
        DateTime(2026, 11, 22, 19),
      );
      expect(
        weekly(DateTime.friday, 19 * 60).single.at,
        DateTime(2026, 11, 20, 19),
      );
      expect(
        weekly(DateTime.friday, 7 * 60 + 30).single.at,
        DateTime(2026, 11, 27, 7, 30),
      );
      expect(
        weekly(DateTime.thursday, 9 * 60).single.at,
        DateTime(2026, 11, 26, 9),
      );
      expect(weekly(DateTime.sunday, 9 * 60).single.kind, ReminderKind.weekly);
    });

    const daily = ReminderSettings(dailyOn: true);

    test('daily: one per remaining day, none for a day already done', () {
      final plan = planReminders(
        daily,
        uid: 'kai',
        challenge: _challenge(
          checkIns: {
            'kai': ['2026-11-20'],
          },
        ),
        now: _now,
      );
      expect(plan.map((r) => r.at), [
        for (var d = 21; d <= 25; d++) DateTime(2026, 11, d, 19),
      ]);
      expect(plan.every((r) => r.kind == ReminderKind.daily), isTrue);
      expect(plan.map((r) => r.id).toSet().length, plan.length);
    });

    test('daily: today counts while its time is still ahead', () {
      final plan = planReminders(
        daily,
        uid: 'kai',
        challenge: _challenge(),
        now: _now,
      );
      expect(plan.first.at, DateTime(2026, 11, 20, 19));
      expect(plan, hasLength(6));
      final late = planReminders(
        daily,
        uid: 'kai',
        challenge: _challenge(),
        now: DateTime(2026, 11, 20, 20),
      );
      expect(late.first.at, DateTime(2026, 11, 21, 19));
    });

    test('daily: not a Participant, no Challenge, or an over one', () {
      List<PlannedReminder> plan(Challenge? c, [DateTime? now]) =>
          planReminders(daily, uid: 'kai', challenge: c, now: now ?? _now);
      expect(plan(_challenge(participants: ['mom'])), isEmpty);
      expect(plan(null), isEmpty);
      expect(plan(_challenge(finished: true)), isEmpty);
      expect(plan(_challenge(), DateTime(2026, 11, 26, 8)), isEmpty);
    });
  });

  group('ReminderRepository', () {
    late FakeNotificationService service;
    late ReminderRepository repo;
    const texts = ReminderTexts(title: 'T', weeklyBody: 'W', dailyBody: 'D');

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = FakeNotificationService();
      repo = ReminderRepository(service);
    });

    test(
      'defaults are off; settings are per user and can be cleared',
      () async {
        expect((await repo.load('kai')).weeklyOn, isFalse);
        expect((await repo.load('kai')).dailyOn, isFalse);
        await repo.save(
          'kai',
          const ReminderSettings(
            weeklyOn: true,
            weekday: 3,
            weeklyMinutes: 450,
          ),
        );
        final kai = await repo.load('kai');
        expect((kai.weeklyOn, kai.weekday, kai.weeklyMinutes), (true, 3, 450));
        expect((await repo.load('mom')).weeklyOn, isFalse);
        await repo.clear('kai');
        expect((await repo.load('kai')).weeklyOn, isFalse);
      },
    );

    test('apply replaces what was scheduled', () async {
      await repo.save(
        'kai',
        const ReminderSettings(weeklyOn: true, dailyOn: true),
      );
      await repo.apply('kai', texts, challenge: _challenge(), now: _now);
      expect(service.scheduled.where((s) => s.weekly), hasLength(1));
      expect(service.scheduled.where((s) => !s.weekly), hasLength(6));
      expect(service.scheduled.firstWhere((s) => s.weekly).body, 'W');

      await repo.save('kai', const ReminderSettings(dailyOn: true));
      await repo.apply('kai', texts, challenge: null, now: _now);
      expect(service.scheduled, isEmpty);
    });
  });

  group('ReminderSync', () {
    late FakeFirebaseFirestore db;
    late FakeNotificationService service;
    late MockFirebaseAuth auth;
    late Session session;
    late ReminderSync sync;

    Future<void> start({Map<String, Object> prefs = const {}}) async {
      SharedPreferences.setMockInitialValues({
        'reminder:kai:dailyOn': true,
        'reminder:kai:weeklyOn': true,
        ...prefs,
      });
      db = FakeFirebaseFirestore();
      await seedFamily(db);
      await seedChallenge(db, start: '2026-11-19');
      service = FakeNotificationService();
      auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'kai'));
      session = Session(
        auth: AuthRepository(auth),
        profiles: ProfileRepository(db),
      );
      sync = ReminderSync(
        session: session,
        challenges: ChallengeRepository(db),
        reminders: ReminderRepository(service),
        now: () => _now,
      );
      await pumpEventQueue();
    }

    tearDown(() {
      sync.dispose();
      session.dispose();
    });

    int daily() => service.scheduled.where((s) => !s.weekly).length;

    test('schedules the weekly and the daily Reminders', () async {
      await start();
      expect(service.scheduled.where((s) => s.weekly), hasLength(1));
      expect(daily(), 6);
    });

    test(
      'checking in drops today; a finished Challenge drops the daily ones',
      () async {
        await start();
        await db.doc('families/f1/challenges/c1').update({
          'checkIns': {
            'kai': ['2026-11-20'],
          },
        });
        await pumpEventQueue();
        expect(daily(), 5);

        await db.doc('families/f1/challenges/c1').update({
          'status': 'finished',
        });
        await pumpEventQueue();
        // Finished: the daily Reminders go, the weekly one stays.
        expect(daily(), 0);
        expect(service.scheduled.where((s) => s.weekly), hasLength(1));
      },
    );

    test('sign-out cancels everything', () async {
      await start();
      expect(service.scheduled, isNotEmpty);
      await auth.signOut();
      await pumpEventQueue();
      expect(service.scheduled, isEmpty);
    });

    test('off by default: nothing is scheduled', () async {
      await start(
        prefs: {'reminder:kai:dailyOn': false, 'reminder:kai:weeklyOn': false},
      );
      expect(service.scheduled, isEmpty);
    });
  });

  group('Settings switches', () {
    Future<TestApp> open(WidgetTester tester, {String locale = 'en'}) async {
      final app = TestApp(
        signedInUid: 'u1',
        profile: profileDoc(locale: locale),
      );
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).last);
      await tester.pumpAndSettle();
      return app;
    }

    SwitchListTile tile(String title) =>
        find.widgetWithText(SwitchListTile, title).evaluate().single.widget
            as SwitchListTile;

    testWidgets(
      'off by default; turning weekly on asks permission and schedules',
      (tester) async {
        final app = await open(tester);
        expect(tile('Weekly check-in').value, isFalse);
        expect(tile('Daily Challenge check-in').value, isFalse);
        expect(find.text('Day'), findsNothing);

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Weekly check-in'),
        );
        await tester.pumpAndSettle();

        expect(app.notifications.permissionRequests, 1);
        expect(tile('Weekly check-in').value, isTrue);
        expect(find.text('Day'), findsOneWidget);
        expect(
          app.notifications.scheduled.where((s) => s.weekly),
          hasLength(1),
        );
        expect(
          (await SharedPreferences.getInstance()).getBool(
            'reminder:u1:weeklyOn',
          ),
          isTrue,
        );

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Weekly check-in'),
        );
        await tester.pumpAndSettle();
        expect(app.notifications.scheduled, isEmpty);
      },
    );

    testWidgets('a denied permission turns the switch back off and explains', (
      tester,
    ) async {
      final app = TestApp(signedInUid: 'u1', profile: profileDoc());
      app.notifications.permissionGranted = false;
      await tester.pumpWidget(app.widget());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Weekly check-in'));
      await tester.pumpAndSettle();

      expect(tile('Weekly check-in').value, isFalse);
      expect(find.textContaining('Notifications are blocked'), findsOneWidget);
      expect(app.notifications.scheduled, isEmpty);
    });

    testWidgets('Chinese labels', (tester) async {
      await open(tester, locale: 'zh');
      expect(find.text('提醒'), findsOneWidget);
      expect(find.text('每周回顾'), findsOneWidget);
      expect(find.text('每日挑战打卡'), findsOneWidget);
    });
  });
}
