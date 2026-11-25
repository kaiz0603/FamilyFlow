import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('signed out: welcome screen', (tester) async {
    await tester.pumpWidget(TestApp().widget(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signed in without a profile: profile setup', (tester) async {
    await tester.pumpWidget(
      TestApp(signedInUid: 'u1').widget(locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('About you'), findsOneWidget);
  });

  testWidgets('ready: four tabs in English, switching tab', (tester) async {
    await tester.pumpWidget(
      TestApp(signedInUid: 'u1', profile: profileDoc()).widget(),
    );
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Compare', 'Advice', 'Settings']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    await tester.tap(find.widgetWithText(NavigationDestination, 'Advice'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Advice'), findsOneWidget);
  });

  testWidgets('the profile language drives the UI (zh)', (tester) async {
    await tester.pumpWidget(
      TestApp(
        signedInUid: 'u1',
        profile: profileDoc(locale: 'zh'),
      ).widget(),
    );
    await tester.pumpAndSettle();

    for (final label in ['首页', '对比', '建议', '设置']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    expect(find.text('建立你的家庭'), findsOneWidget);
    expect(find.text('创建家庭'), findsOneWidget);
  });

  testWidgets('a child without a family can only join, not create', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        signedInUid: 'u1',
        profile: profileDoc(role: 'child'),
      ).widget(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Join with a code'), findsOneWidget);
    expect(find.text('Create family'), findsNothing);
  });

  testWidgets('switching language in Settings updates the profile and UI', (
    tester,
  ) async {
    final app = TestApp(signedInUid: 'u1', profile: profileDoc());
    await tester.pumpWidget(app.widget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '设置'), findsOneWidget);
    final stored = await app.db.collection('users').doc('u1').get();
    expect(stored.data()!['locale'], 'zh');
  });
}
