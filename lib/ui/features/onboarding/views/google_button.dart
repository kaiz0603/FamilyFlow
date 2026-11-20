import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../view_models/auth_view_model.dart';

/// "Continue with Google" for Welcome and Sign in. Needs an [AuthViewModel] above.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return OutlinedButton.icon(
      onPressed: vm.busy ? null : vm.signInWithGoogle,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      icon: const Icon(Icons.account_circle),
      label: Text(AppLocalizations.of(context).continueWithGoogle),
    );
  }
}
