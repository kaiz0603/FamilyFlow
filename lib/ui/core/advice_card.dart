import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/session.dart';

import '../../domain/models/assessment.dart';
import '../../l10n/app_localizations.dart';
import 'assessment_labels.dart';

/// Scenario as the title; guidance and the weekly challenge when expanded.
class AdviceCard extends StatelessWidget {
  const AdviceCard({
    super.key,
    required this.advice,
    this.initiallyExpanded = false,
  });

  final Advice advice;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        title: Text(advice.scenario),
        subtitle: Text(advice.tags.map((t) => tagLabel(l, t)).join(' · ')),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(advice.guidance),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l.weeklyChallenge}  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: advice.challenge),
                ],
              ),
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
          // Advice-only mode (no Family) has nobody to share a Challenge with.
          if (context.watch<Session>().profile?.familyId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(
                  Routes.startChallenge(advice.id, advice.challenge),
                ),
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.startChallenge),
              ),
            ),
        ],
      ),
    );
  }
}
