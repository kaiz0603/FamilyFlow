import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/privacy_policy.dart';
import '../view_models/auth_view_model.dart';
import 'google_button.dart';

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
              ErrorLine(context.watch<AuthViewModel>().error),
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
              const SizedBox(height: 12),
              const GoogleButton(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => openPrivacyPolicy(context),
                child: Text(l.privacyPolicy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
