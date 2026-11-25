import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// M7 accessibility pass: 200% text on a phone-sized screen, tap targets, labels, contrast.
void main() {
  Future<void> meetsGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final lang in ['en', 'zh']) {
    testWidgets('$lang: welcome at 200% text', (tester) async {
      final semantics = tester.ensureSemantics();
      phoneAt200(tester);
      await tester.pumpWidget(TestApp().widget(locale: Locale(lang)));
      await tester.pumpAndSettle();
      await meetsGuidelines(tester);
      semantics.dispose();
    });

    testWidgets('$lang: every tab at 200% text', (tester) async {
      final semantics = tester.ensureSemantics();
      phoneAt200(tester);
      await tester.pumpWidget(
        TestApp(
          signedInUid: 'u1',
          profile: profileDoc(locale: lang),
        ).widget(),
      );
      await tester.pumpAndSettle();
      final tabs = find.byType(NavigationDestination);
      for (var i = 0; i < 4; i++) {
        await tester.tap(tabs.at(i));
        await tester.pumpAndSettle();
        await meetsGuidelines(tester);
      }
      semantics.dispose();
    });
  }
}
