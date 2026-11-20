import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show ValueKey;
import 'package:provider/provider.dart';

import '../ui/core/shell_scaffold.dart';
import '../domain/models/assessment.dart';
import '../ui/core/splash_screen.dart';
import '../ui/features/advice/view_models/advice_view_model.dart';
import '../ui/features/advice/views/advice_screen.dart';
import '../ui/features/assessment/view_models/assessment_view_model.dart';
import '../ui/features/assessment/views/assessment_screen.dart';
import '../ui/features/challenge/view_models/challenge_view_model.dart';
import '../ui/features/challenge/views/start_challenge_screen.dart';
import '../ui/features/compare/view_models/compare_view_model.dart';
import '../ui/features/compare/views/compare_screen.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/home/views/home_screen.dart';
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

  /// `/assessment/<subjectParentId>?name=<display name>`
  static String assessment(String subjectParentId, String name) =>
      '/assessment/$subjectParentId?name=${Uri.encodeQueryComponent(name)}';

  /// `/challenge/start?adviceId=<id>&title=<challenge text>`
  static String startChallenge(String adviceId, String title) => Uri(
    path: '/challenge/start',
    queryParameters: {'adviceId': adviceId, 'title': title},
  ).toString();

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
    GoRoute(
      path: '/assessment/:subject',
      builder: (context, state) => ChangeNotifierProvider(
        create: (c) => AssessmentViewModel(
          session: c.read(),
          content: c.read(),
          assessments: c.read(),
          subjectParentId: state.pathParameters['subject']!,
          subjectName: state.uri.queryParameters['name'] ?? '',
        ),
        child: const AssessmentScreen(),
      ),
    ),
    GoRoute(
      path: '/challenge/start',
      builder: (context, state) => ChangeNotifierProvider(
        create: (c) => ChallengeViewModel(
          session: c.read(),
          families: c.read(),
          challenges: c.read(),
        ),
        child: StartChallengeScreen(
          adviceId: state.uri.queryParameters['adviceId'] ?? '',
          title: state.uri.queryParameters['title'] ?? '',
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScaffold(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, _) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (c) => HomeViewModel(
                      session: c.read(),
                      families: c.read(),
                      assessmentRepo: c.read(),
                    ),
                  ),
                  ChangeNotifierProvider(
                    create: (c) => ChallengeViewModel(
                      session: c.read(),
                      families: c.read(),
                      challenges: c.read(),
                    ),
                  ),
                ],
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.compare,
              builder: (context, _) => ChangeNotifierProvider(
                create: (c) => CompareViewModel(
                  session: c.read(),
                  families: c.read(),
                  assessmentRepo: c.read(),
                ),
                child: const CompareScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.advice,
              builder: (context, state) {
                final style = ParentingStyle.values
                    .asNameMap()[state.uri.queryParameters['style']];
                return ChangeNotifierProvider(
                  key: ValueKey(style),
                  create: (c) => AdviceViewModel(
                    session: c.read(),
                    content: c.read(),
                    style: style,
                  ),
                  child: const AdviceScreen(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, _) => ChangeNotifierProvider(
                create: (c) => SettingsViewModel(
                  session: c.read(),
                  auth: c.read(),
                  profiles: c.read(),
                  families: c.read(),
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
