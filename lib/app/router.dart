import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../ui/core/placeholder_screen.dart';
import '../ui/core/shell_scaffold.dart';
import '../ui/core/splash_screen.dart';
import '../ui/features/onboarding/view_models/auth_view_model.dart';
import '../ui/features/onboarding/view_models/profile_setup_view_model.dart';
import '../ui/features/onboarding/views/profile_setup_screen.dart';
import '../ui/features/onboarding/views/sign_in_screen.dart';
import '../ui/features/onboarding/views/sign_up_screen.dart';
import '../ui/features/onboarding/views/welcome_screen.dart';
import '../ui/features/settings/view_models/settings_view_model.dart';
import '../ui/features/settings/views/settings_screen.dart';
import 'session.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const compare = '/compare';
  static const advice = '/advice';
  static const settings = '/settings';

  static const signedOutOnly = {welcome, signIn, signUp};
}

/// Where [status] sends a user who asked for [location]; null lets them stay.
/// The Family gate joins this in M2.
String? gate(SessionStatus status, String location) => switch (status) {
  SessionStatus.loading => location == Routes.splash ? null : Routes.splash,
  SessionStatus.signedOut =>
    Routes.signedOutOnly.contains(location) ? null : Routes.welcome,
  SessionStatus.needsProfile =>
    location == Routes.profileSetup ? null : Routes.profileSetup,
  SessionStatus.ready =>
    Routes.signedOutOnly.contains(location) ||
            location == Routes.profileSetup ||
            location == Routes.splash
        ? Routes.home
        : null,
};

GoRouter createRouter(Session session) => GoRouter(
  initialLocation: Routes.home,
  refreshListenable: session,
  redirect: (context, state) => gate(session.status, state.matchedLocation),
  routes: [
    GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
    GoRoute(
      path: Routes.signIn,
      builder: (context, _) => ChangeNotifierProvider(
        create: (c) => AuthViewModel(auth: c.read()),
        child: const SignInScreen(),
      ),
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, _) => ChangeNotifierProvider(
        create: (c) => AuthViewModel(auth: c.read()),
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: Routes.profileSetup,
      builder: (context, _) => ChangeNotifierProvider(
        create: (c) => ProfileSetupViewModel(
          uid: c.read<Session>().uid!,
          auth: c.read(),
          profiles: c.read(),
        ),
        child: const ProfileSetupScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScaffold(shell: shell),
      branches: [
        _placeholderTab(Routes.home, (l) => l.tabHome),
        _placeholderTab(Routes.compare, (l) => l.tabCompare),
        _placeholderTab(Routes.advice, (l) => l.tabAdvice),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, _) => ChangeNotifierProvider(
                create: (c) => SettingsViewModel(
                  session: c.read(),
                  auth: c.read(),
                  profiles: c.read(),
                ),
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

StatefulShellBranch _placeholderTab(
  String path,
  String Function(AppLocalizations) title,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) =>
          PlaceholderScreen(title: title(AppLocalizations.of(context))),
    ),
  ],
);
