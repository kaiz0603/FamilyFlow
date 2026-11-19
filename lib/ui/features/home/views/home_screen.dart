import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/models/family.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../../../core/validators.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final title = vm.mode == HomeMode.inFamily ? vm.family!.name : l.tabHome;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (vm.mode) {
        HomeMode.loading => const Center(child: CircularProgressIndicator()),
        HomeMode.noFamily => const _FamilySetup(),
        HomeMode.pending => _StatusCard(
          icon: Icons.hourglass_top,
          title: l.requestPendingTitle,
          body: l.requestPendingBody,
          action: l.cancelRequest,
        ),
        HomeMode.rejected => _StatusCard(
          icon: Icons.block,
          title: l.requestRejectedTitle,
          body: l.requestRejectedBody,
          action: l.ok,
        ),
        HomeMode.inFamily => const _FamilyView(),
      },
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [ErrorLine(context.watch<HomeViewModel>().error), ...children],
  );
}

class _FamilySetup extends StatelessWidget {
  const _FamilySetup();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final text = Theme.of(context).textTheme;
    return _Page(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.familySetupTitle, style: text.titleLarge),
                const SizedBox(height: 8),
                Text(
                  vm.isParent
                      ? l.familySetupParentBody
                      : l.familySetupChildBody,
                ),
                const SizedBox(height: 20),
                if (vm.isParent) ...[
                  FilledButton.icon(
                    onPressed: vm.busy ? null : () => _create(context),
                    icon: const Icon(Icons.add_home),
                    label: Text(l.createFamily),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: vm.busy ? null : () => _join(context),
                  icon: const Icon(Icons.vpn_key),
                  label: Text(l.joinFamily),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final vm = context.read<HomeViewModel>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(
        title: l.createFamily,
        label: l.familyName,
        hint: l.familyNameHint,
        maxLength: Family.maxNameLength,
        action: l.createFamily,
        validator: (v) => Validators.required(l, v),
      ),
    );
    if (name != null) await vm.createFamily(name);
  }

  Future<void> _join(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final vm = context.read<HomeViewModel>();
    final code = await showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(
        title: l.joinFamily,
        label: l.inviteCode,
        hint: 'ABC234',
        maxLength: Invite.length,
        action: l.sendRequest,
        capitalize: true,
        validator: (v) => Invite.isWellFormed(Invite.normalize(v ?? ''))
            ? null
            : l.errInvalidInviteCode,
      ),
    );
    if (code != null) await vm.joinWithCode(code);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return _Page(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(body, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: vm.busy ? null : vm.cancelRequest,
                  child: Text(action),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FamilyView extends StatelessWidget {
  const _FamilyView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final text = Theme.of(context).textTheme;
    return _Page(
      children: [
        if (vm.isParent) const _InviteCard(),
        if (vm.isParent && vm.pendingRequests.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l.pendingRequestsTitle, style: text.titleMedium),
          for (final r in vm.pendingRequests)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_add_alt),
              title: Text(r.displayName),
              subtitle: Text(_roleLabel(l, r.role)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.reject,
                    onPressed: vm.busy ? null : () => vm.reject(r),
                    icon: const Icon(Icons.close),
                  ),
                  IconButton.filled(
                    // ListTile's icon color would otherwise win (dark on teal).
                    color: Theme.of(context).colorScheme.onPrimary,
                    tooltip: l.approve,
                    onPressed: vm.busy ? null : () => vm.approve(r),
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        Text(l.membersTitle, style: text.titleMedium),
        for (final m in vm.members)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(m.displayName.characters.first)),
            title: Text(
              m.uid == vm.me?.uid
                  ? '${m.displayName} ${l.youSuffix}'
                  : m.displayName,
            ),
            subtitle: Text(_roleLabel(l, m.role)),
            trailing: vm.isParent && m.uid != vm.me?.uid
                ? IconButton(
                    tooltip: l.removeMember,
                    onPressed: vm.busy ? null : () => _remove(context, m),
                    icon: const Icon(Icons.person_remove_outlined),
                  )
                : null,
          ),
      ],
    );
  }

  Future<void> _remove(BuildContext context, Member m) async {
    final l = AppLocalizations.of(context);
    final vm = context.read<HomeViewModel>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.removeMemberTitle(m.displayName)),
        content: Text(l.removeMemberBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.removeMember),
          ),
        ],
      ),
    );
    if (ok == true) await vm.removeMember(m);
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final invite = vm.invite;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.inviteTitle, style: text.titleMedium),
            const SizedBox(height: 4),
            Text(l.inviteBody),
            const SizedBox(height: 16),
            if (invite == null)
              FilledButton.icon(
                onPressed: vm.busy ? null : vm.createInvite,
                icon: const Icon(Icons.vpn_key),
                label: Text(l.generateCode),
              )
            else ...[
              SelectableText(
                invite.code,
                textAlign: TextAlign.center,
                style: text.displaySmall?.copyWith(letterSpacing: 6),
              ),
              Text(
                l.inviteExpires(
                  DateFormat.yMMMd(locale).format(invite.expiresAt),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: vm.busy ? null : vm.createInvite,
                      child: Text(l.newCode),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(text: l.inviteShareText(invite.code)),
                      ),
                      icon: const Icon(Icons.share),
                      label: Text(l.share),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _roleLabel(AppLocalizations l, Role r) =>
    r == Role.parent ? l.roleParent : l.roleChild;

/// One-field dialog; returns the trimmed value or null on cancel.
class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.label,
    required this.hint,
    required this.maxLength,
    required this.action,
    required this.validator,
    this.capitalize = false,
  });

  final String title;
  final String label;
  final String hint;
  final int maxLength;
  final String action;
  final String? Function(String?) validator;
  final bool capitalize;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _value.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _value,
          autofocus: true,
          maxLength: widget.maxLength,
          textCapitalization: widget.capitalize
              ? TextCapitalization.characters
              : TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
          ),
          validator: widget.validator,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}
