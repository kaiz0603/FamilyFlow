import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final vm = context.read<SettingsViewModel>();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password != null) await vm.deleteAccount(password);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();
    final profile = vm.profile;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (profile != null)
            ListTile(
              leading: CircleAvatar(
                child: Text(profile.displayName.characters.first),
              ),
              title: Text(profile.displayName),
              subtitle: Text(
                '${profile.role == Role.parent ? l.roleParent : l.roleChild}'
                ' · ${vm.email ?? ''}',
              ),
            ),
          const Divider(),
          ListTile(
            title: Text(l.settingsLanguage),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'zh', label: Text(l.languageZh)),
                ButtonSegment(value: 'en', label: Text(l.languageEn)),
              ],
              selected: {profile?.locale ?? 'en'},
              onSelectionChanged: vm.busy
                  ? null
                  : (s) => vm.setLocale(s.single),
              showSelectedIcon: false,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ErrorLine(vm.error),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.signOut),
            onTap: vm.busy ? null : vm.signOut,
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: scheme.error),
            title: Text(l.deleteAccount, style: TextStyle(color: scheme.error)),
            onTap: vm.busy ? null : () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}

/// Returns the password to re-authenticate with, or null on cancel.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l.deleteAccount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.deleteAccountBody),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l.password),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () {
            if (_password.text.isNotEmpty) {
              Navigator.pop(context, _password.text);
            }
          },
          child: Text(l.deleteAccountConfirm),
        ),
      ],
    );
  }
}
