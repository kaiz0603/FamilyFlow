import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/validators.dart';
import '../view_models/auth_view_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
      context.read<AuthViewModel>().signUp(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    return FormPage(
      title: l.signUp,
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
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l.password,
                  helperText: l.passwordHint,
                ),
                validator: (v) => Validators.newPassword(l, v),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ErrorLine(vm.error),
        BusyButton(label: l.signUp, busy: vm.busy, onPressed: _submit),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.pushReplacement(Routes.signIn),
          child: Text(l.haveAccount),
        ),
      ],
    );
  }
}
