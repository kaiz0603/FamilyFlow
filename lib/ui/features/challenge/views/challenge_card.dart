import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../domain/models/challenge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/form_widgets.dart';
import '../view_models/challenge_view_model.dart';

/// Home: the running Challenge with its check-in grid, the finished week's
/// totals, or a pointer to Advice when there is none (PRD F7.3, F7.4).
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<ChallengeViewModel>();
    final text = Theme.of(context).textTheme;
    final c = vm.challenge;
    final over = c == null || c.isOver(vm.today);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              c == null
                  ? l.challengeTitle
                  : (over ? l.challengeFinishedTitle : l.challengeTitle),
              style: text.titleMedium,
            ),
            const SizedBox(height: 4),
            if (c == null)
              Text(l.challengeNone)
            else ...[
              Text(c.title, style: text.bodyLarge),
              if (!over)
                Text(
                  l.challengeDay(c.days.indexOf(vm.today) + 1),
                  style: text.bodySmall,
                ),
              const SizedBox(height: 12),
              _Grid(challenge: c, today: vm.today),
            ],
            ErrorLine(vm.error),
            const SizedBox(height: 12),
            if (!over && vm.canCheckIn)
              BusyButton(
                label: l.checkInToday,
                busy: vm.busy,
                onPressed: vm.checkIn,
              )
            else if (!over && c.checkedIn(vm.me!.uid, vm.today))
              Text(l.checkedInToday, textAlign: TextAlign.center)
            else if (over)
              OutlinedButton(
                onPressed: () => context.go(Routes.advice),
                child: Text(c == null ? l.browseAdvice : l.startNextChallenge),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row per Participant, one cell per day; each row reads as one summary.
class _Grid extends StatelessWidget {
  const _Grid({required this.challenge, required this.today});

  final Challenge challenge;
  final String today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<ChallengeViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = challenge.days;
    return Column(
      children: [
        Row(
          children: [
            const Spacer(flex: 3),
            for (final d in days)
              Expanded(
                child: Text(
                  DateFormat.E(locale).format(DateTime.parse(d)),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            const SizedBox(width: 36),
          ],
        ),
        for (final uid in challenge.participants)
          Semantics(
            container: true,
            label: l.challengeRowSummary(
              vm.nameOf(uid) ?? l.formerMember,
              challenge.countFor(uid),
            ),
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        vm.nameOf(uid) ?? l.formerMember,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final d in days)
                      Expanded(
                        child: Icon(
                          challenge.checkedIn(uid, d)
                              ? Icons.check_circle
                              : (d == today
                                    ? Icons.radio_button_unchecked
                                    : Icons.circle_outlined),
                          size: 20,
                          color: challenge.checkedIn(uid, d)
                              ? scheme.primary
                              : (d == today
                                    ? scheme.primary
                                    : scheme.outlineVariant),
                        ),
                      ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${challenge.countFor(uid)}/${Challenge.length}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Home: newest Activity first, live while the app is open (PRD F8.1, F8.2).
class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<ChallengeViewModel>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat.MMMd(locale).add_Hm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.activityTitle, style: Theme.of(context).textTheme.titleMedium),
        if (vm.activity.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l.activityEmpty),
          ),
        for (final a in vm.activity)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_icon(a.type)),
            title: Text(_text(l, a, vm.nameOf(a.actorId) ?? l.formerMember)),
            subtitle: Text(when.format(a.createdAt)),
          ),
      ],
    );
  }

  static IconData _icon(ActivityType t) => switch (t) {
    ActivityType.memberJoined => Icons.person_add_alt,
    ActivityType.memberLeft => Icons.person_remove_outlined,
    ActivityType.assessmentDone => Icons.quiz_outlined,
    ActivityType.challengeStarted => Icons.flag_outlined,
    ActivityType.challengeFinished => Icons.emoji_events_outlined,
  };

  static String _text(AppLocalizations l, ActivityEntry a, String name) =>
      switch (a.type) {
        ActivityType.memberJoined => l.activityMemberJoined(name),
        ActivityType.memberLeft => l.activityMemberLeft(name),
        ActivityType.assessmentDone => l.activityAssessmentDone(name),
        ActivityType.challengeStarted => l.activityChallengeStarted(name),
        ActivityType.challengeFinished => l.activityChallengeFinished,
      };
}
