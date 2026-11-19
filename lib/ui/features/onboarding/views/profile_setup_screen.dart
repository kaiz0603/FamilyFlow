import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/validators.dart';
import '../view_models/profile_setup_view_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Role _role = Role.parent;
  int? _birthYear;
  bool _parentTooYoung = false;

  // Includes years under 13 so the age gate can say why, instead of hiding them.
  final List<int> _years = [
    for (var y = DateTime.now().year - 5; y >= 1920; y--) y,
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _parentTooYoung = false);
    if (!_form.currentState!.validate()) return;
    final vm = context.read<ProfileSetupViewModel>();
    final lang = Localizations.localeOf(context).languageCode;
    final outcome = await vm.submit(
      role: _role,
      displayName: _name.text,
      birthYear: _birthYear!,
      locale: lang == 'zh' ? 'zh' : 'en',
    );
    if (!mounted) return;
    switch (outcome) {
      case SetupOutcome.underAge:
        await _explainUnderAge();
        await vm.removeUnderAgeAccount();
      case SetupOutcome.parentTooYoung:
        setState(() => _parentTooYoung = true);
      case SetupOutcome.saved || SetupOutcome.failed:
        break; // saved: the router moves on; failed: vm.error is shown.
    }
  }

  Future<void> _explainUnderAge() {
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l.underAgeTitle),
        content: Text(l.underAgeBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<ProfileSetupViewModel>();
    final scheme = Theme.of(context).colorScheme;
    return FormPage(
      title: l.profileSetupTitle,
      children: [
        Text(l.profileSetupIntro),
        const SizedBox(height: 24),
        Text(l.roleLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<Role>(
          segments: [
            ButtonSegment(
              value: Role.parent,
              label: Text(l.roleParent),
              icon: const Icon(Icons.person),
            ),
            ButtonSegment(
              value: Role.child,
              label: Text(l.roleChild),
              icon: const Icon(Icons.child_care),
            ),
          ],
          selected: {_role},
          onSelectionChanged: (s) => setState(() {
            _role = s.single;
            _parentTooYoung = false;
          }),
        ),
        if (_role == Role.child) ...[
          const SizedBox(height: 8),
          Text(l.childPrivacyNote, style: TextStyle(color: scheme.primary)),
        ],
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                maxLength: UserProfile.maxNameLength,
                decoration: InputDecoration(labelText: l.displayName),
                validator: (v) => Validators.displayName(l, v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _birthYear,
                decoration: InputDecoration(labelText: l.birthYear),
                menuMaxHeight: 320,
                items: [
                  for (final y in _years)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
                onChanged: (y) => setState(() {
                  _birthYear = y;
                  _parentTooYoung = false;
                }),
                validator: (y) => y == null ? l.fieldRequired : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_parentTooYoung)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l.parentTooYoung,
              style: TextStyle(color: scheme.error),
            ),
          ),
        ErrorLine(vm.error),
        BusyButton(label: l.continueAction, busy: vm.busy, onPressed: _submit),
        const SizedBox(height: 12),
        TextButton(
          onPressed: vm.useAnotherAccount,
          child: Text(l.useAnotherAccount),
        ),
      ],
    );
  }
}
