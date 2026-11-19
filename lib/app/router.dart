import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../ui/core/placeholder_screen.dart';
import '../ui/core/shell_scaffold.dart';

/// Tab routes, in bottom-navigation order.
abstract final class Routes {
  static const home = '/home';
  static const compare = '/compare';
  static const advice = '/advice';
  static const settings = '/settings';
}

// Gates (signed out / no profile / no Family) arrive with M1–M2 as a `redirect`.
GoRouter createRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScaffold(shell: shell),
      branches: [
        _tab(Routes.home, (l) => l.tabHome),
        _tab(Routes.compare, (l) => l.tabCompare),
        _tab(Routes.advice, (l) => l.tabAdvice),
        _tab(Routes.settings, (l) => l.tabSettings),
      ],
    ),
  ],
);

StatefulShellBranch _tab(
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
