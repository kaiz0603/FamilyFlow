import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../ui/core/theme.dart';
import 'router.dart';

class FamilyFlowApp extends StatefulWidget {
  const FamilyFlowApp({super.key, this.locale});

  /// Forces a locale (tests). Null follows the device language.
  final Locale? locale;

  @override
  State<FamilyFlowApp> createState() => _FamilyFlowAppState();
}

class _FamilyFlowAppState extends State<FamilyFlowApp> {
  final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: widget.locale,
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
    );
  }
}
