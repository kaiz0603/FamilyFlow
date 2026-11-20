import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/validators.dart';
import '../view_models/auth_view_model.dart';
import 'google_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      context.read<AuthViewModel>().signIn(_email.text, _password.text);
    }
  }

  Future<void> _forgotPassword() async {
    final l = AppLocalizations.of(context);
    final vm = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final address = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(initialEmail: _email.text),
    );
    if (address == null) return;
    // Same message whether or not the account exists (no email enumeration).
    if (await vm.sendPasswordReset(address)) {
      messenger.showSnackBar(SnackBar(content: Text(l.resetEmailSent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    return FormPage(
      title: l.signIn,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l.email),
                validator: (v) => Validators.email(l, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(labelText: l.password),
                validator: (v) => Validators.required(l, v),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(l.forgotPassword),
          ),
        ),
        const SizedBox(height: 8),
        ErrorLine(vm.error),
        BusyButton(label: l.signIn, busy: vm.busy, onPressed: _submit),
        const SizedBox(height: 12),
        const GoogleButton(),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.pushReplacement(Routes.signUp),
          child: Text(l.noAccountYet),
        ),
      ],
    );
  }
}

/// Returns the validated email to send a reset link to, or null on cancel.
class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.resetPasswordTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.resetPasswordBody),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l.email),
              validator: (v) => Validators.email(l, v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, _email.text);
            }
          },
          child: Text(l.sendLink),
        ),
      ],
    );
  }
}
