import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    const tall = Size.fromHeight(48);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.family_restroom,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l.appTitle,
                style: text.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.welcomeTagline,
                style: text.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push(Routes.signUp),
                style: FilledButton.styleFrom(minimumSize: tall),
                child: Text(l.signUp),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(Routes.signIn),
                style: OutlinedButton.styleFrom(minimumSize: tall),
                child: Text(l.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
