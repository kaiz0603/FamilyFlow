import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/privacy_policy.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLeave(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final vm = context.read<SettingsViewModel>();
    final isParent = vm.profile?.role == Role.parent;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.leaveFamily),
        content: Text(
          isParent
              ? [l.leaveFamilyBody, l.leaveFamilyLastParentBody].join('\n\n')
              : l.leaveFamilyBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.leaveFamily),
          ),
        ],
      ),
    );
    if (ok == true) await vm.leaveFamily();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final vm = context.read<SettingsViewModel>();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteAccountDialog(
        inFamily: vm.inFamily,
        withPassword: vm.hasPassword,
      ),
    );
    if (password != null) {
      await vm.deleteAccount(vm.hasPassword ? password : null);
    }
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
            // Below the title, not trailing: at 200% text it needs the full width.
            subtitle: SegmentedButton<String>(
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
          const _Reminders(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ErrorLine(vm.error),
          ),
          if (vm.inFamily)
            ListTile(
              leading: const Icon(Icons.group_off_outlined),
              title: Text(l.leaveFamily),
              onTap: vm.busy ? null : () => _confirmLeave(context),
            ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicy),
            onTap: () => openPrivacyPolicy(context),
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

/// Two opt-in Reminders (PRD F8.3): weekly check-in, daily Challenge check-in.
class _Reminders extends StatelessWidget {
  const _Reminders();

  Future<void> _pickTime(
    BuildContext context,
    int minutes,
    Future<void> Function(int) save,
  ) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (t != null) await save(t.hour * 60 + t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();
    final r = vm.reminders;
    String time(int m) =>
        TimeOfDay(hour: m ~/ 60, minute: m % 60).format(context);
    // 2024-01-01 is a Monday, so day N of January is weekday N.
    String day(int weekday) =>
        DateFormat.EEEE(l.localeName).format(DateTime(2024, 1, weekday));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            l.settingsReminders,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SwitchListTile(
          title: Text(l.remindersWeekly),
          subtitle: Text(l.remindersWeeklySubtitle),
          value: r.weeklyOn,
          onChanged: vm.setWeekly,
        ),
        if (r.weeklyOn) ...[
          ListTile(
            title: Text(l.remindersDay),
            trailing: DropdownButton<int>(
              value: r.weekday,
              onChanged: (v) => vm.setWeekday(v!),
              items: [
                for (var d = 1; d <= 7; d++)
                  DropdownMenuItem(value: d, child: Text(day(d))),
              ],
            ),
          ),
          ListTile(
            title: Text(l.remindersTime),
            trailing: Text(time(r.weeklyMinutes)),
            onTap: () =>
                _pickTime(context, r.weeklyMinutes, vm.setWeeklyMinutes),
          ),
        ],
        SwitchListTile(
          title: Text(l.remindersDaily),
          subtitle: Text(l.remindersDailySubtitle),
          value: r.dailyOn,
          onChanged: vm.setDaily,
        ),
        if (r.dailyOn)
          ListTile(
            title: Text(l.remindersTime),
            trailing: Text(time(r.dailyMinutes)),
            onTap: () => _pickTime(context, r.dailyMinutes, vm.setDailyMinutes),
          ),
        if (vm.notificationsBlocked)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.remindersPermissionDenied,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

/// Returns the password to re-authenticate with ('' for Google-only accounts,
/// which confirm in the Google picker next), or null on cancel.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({
    required this.inFamily,
    required this.withPassword,
  });

  final bool inFamily;
  final bool withPassword;

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
          if (widget.inFamily) ...[
            const SizedBox(height: 8),
            Text(l.deleteAccountFamilyNote),
          ],
          const SizedBox(height: 12),
          if (widget.withPassword)
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: l.password),
            )
          else
            Text(l.deleteAccountGoogleNote),
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
            if (!widget.withPassword || _password.text.isNotEmpty) {
              Navigator.pop(context, _password.text);
            }
          },
          child: Text(l.deleteAccountConfirm),
        ),
      ],
    );
  }
}
