import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/repositories/assessment_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/challenge_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/family_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../ui/core/theme.dart';
import 'router.dart';
import 'session.dart';

class FamilyFlowApp extends StatefulWidget {
  const FamilyFlowApp({
    super.key,
    required this.auth,
    required this.profiles,
    required this.families,
    required this.assessments,
    required this.challenges,
    required this.content,
    this.locale,
  });

  final AuthRepository auth;
  final ProfileRepository profiles;
  final FamilyRepository families;
  final AssessmentRepository assessments;
  final ChallengeRepository challenges;
  final ContentRepository content;

  /// Forces a locale (tests). Otherwise: the profile's language, else the device's.
  final Locale? locale;

  @override
  State<FamilyFlowApp> createState() => _FamilyFlowAppState();
}

class _FamilyFlowAppState extends State<FamilyFlowApp> {
  late final Session _session = Session(
    auth: widget.auth,
    profiles: widget.profiles,
  );
  late final GoRouter _router = createRouter(_session);

  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.auth),
        Provider.value(value: widget.profiles),
        Provider.value(value: widget.families),
        Provider.value(value: widget.assessments),
        Provider.value(value: widget.challenges),
        Provider.value(value: widget.content),
        ChangeNotifierProvider.value(value: _session),
      ],
      child: ListenableBuilder(
        listenable: _session,
        builder: (context, _) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: widget.locale ?? _session.locale,
          // Not AppLocalizations.localizationsDelegates: gen-l10n still emits the
          // flutter_localizations delegates, which don't serve material_ui (zh breaks).
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        ),
      ),
    );
  }
}
