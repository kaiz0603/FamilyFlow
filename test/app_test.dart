import 'package:familyflow/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shell shows four tabs in English and switches tab', (
    tester,
  ) async {
    await tester.pumpWidget(const FamilyFlowApp(locale: Locale('en')));
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Compare', 'Advice', 'Settings']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Advice'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Advice'), findsOneWidget);
  });

  testWidgets('shell shows Chinese labels', (tester) async {
    await tester.pumpWidget(const FamilyFlowApp(locale: Locale('zh')));
    await tester.pumpAndSettle();

    for (final label in ['首页', '对比', '建议', '设置']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    expect(find.text('即将推出'), findsOneWidget);
  });
}
