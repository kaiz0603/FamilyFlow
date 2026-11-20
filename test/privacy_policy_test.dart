import 'package:familyflow/ui/core/privacy_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('privacy policy follows the app language', () {
    expect(
      privacyPolicyUri(const Locale('zh')).path,
      endsWith('/privacy-policy-zh.html'),
    );
    expect(
      privacyPolicyUri(const Locale('en')).path,
      endsWith('/privacy-policy.html'),
    );
  });
}
