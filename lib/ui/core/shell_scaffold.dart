import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Bottom navigation around the four main tabs.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.compare_arrows_outlined),
            selectedIcon: const Icon(Icons.compare_arrows),
            label: l.tabCompare,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outline),
            selectedIcon: const Icon(Icons.lightbulb),
            label: l.tabAdvice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.tabSettings,
          ),
        ],
      ),
    );
  }
}
