import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Served by GitHub Pages from `docs/` once the repo is public (docs/RELEASE.md).
const _base = 'https://kaiz0603.github.io/FamilyFlow';

Uri privacyPolicyUri(Locale locale) => Uri.parse(
  locale.languageCode == 'zh'
      ? '$_base/privacy-policy-zh.html'
      : '$_base/privacy-policy.html',
);

Future<void> openPrivacyPolicy(BuildContext context) => launchUrl(
  privacyPolicyUri(Localizations.localeOf(context)),
  mode: LaunchMode.externalApplication,
);
