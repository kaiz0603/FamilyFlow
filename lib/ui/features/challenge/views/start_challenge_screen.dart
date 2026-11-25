import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_error_text.dart';
import '../../../core/form_widgets.dart';
import '../../../../utils/result.dart';
import '../view_models/challenge_view_model.dart';

/// Pick Participants for a Challenge from one Advice card (PRD F7.1).
class StartChallengeScreen extends StatefulWidget {
  const StartChallengeScreen({
    super.key,
    required this.adviceId,
    required this.title,
  });

  final String adviceId;
  final String title;

  @override
  State<StartChallengeScreen> createState() => _StartChallengeScreenState();
}

class _StartChallengeScreenState extends State<StartChallengeScreen> {
  Set<String>? _picked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<ChallengeViewModel>();
    final text = Theme.of(context).textTheme;
    final picked = _picked ??= {vm.me!.uid};
    return Scaffold(
      appBar: AppBar(title: Text(l.newChallengeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.title, style: text.titleLarge),
          const SizedBox(height: 8),
          Text(l.challengeWeekInfo),
          const SizedBox(height: 20),
          Text(l.challengeParticipants, style: text.titleMedium),
          for (final m in vm.members)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: picked.contains(m.uid),
              title: Text(m.displayName),
              onChanged: (on) => setState(
                () => on! ? picked.add(m.uid) : picked.remove(m.uid),
              ),
            ),
          if (picked.isEmpty)
            Text(
              l.challengeNeedParticipant,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (vm.hasActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(AppError.challengeActive.message(l)),
            ),
          ErrorLine(vm.error),
          const SizedBox(height: 16),
          BusyButton(
            label: l.startAction,
            busy: vm.busy,
            onPressed: picked.isEmpty || vm.hasActive
                ? null
                : () async {
                    // Keep the Family's member order, not the tap order.
                    final ok = await vm.start(
                      adviceId: widget.adviceId,
                      title: widget.title,
                      participants: [
                        for (final m in vm.members)
                          if (picked.contains(m.uid)) m.uid,
                      ],
                    );
                    if (ok && context.mounted) context.go(Routes.home);
                  },
          ),
        ],
      ),
    );
  }
}
