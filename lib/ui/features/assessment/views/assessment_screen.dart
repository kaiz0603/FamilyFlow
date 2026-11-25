import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../domain/models/assessment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/advice_card.dart';
import '../../../core/assessment_labels.dart';
import '../../../core/form_widgets.dart';
import '../view_models/assessment_view_model.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AssessmentViewModel>();
    final title = vm.perspective == Perspective.self
        ? l.assessmentTitleSelf
        : l.assessmentTitleChild(vm.subjectName);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: switch (vm.step) {
          AssessmentStep.loading || AssessmentStep.saving => const Center(
            child: CircularProgressIndicator(),
          ),
          AssessmentStep.intro => const _Intro(),
          AssessmentStep.answering => const _Question(),
          AssessmentStep.result => const _Result(),
        },
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AssessmentViewModel>();
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.assessmentIntro, style: text.titleMedium),
        if (vm.perspective == Perspective.childView) ...[
          const SizedBox(height: 16),
          Text(
            l.assessmentChildPrivacy(vm.subjectName),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
        const SizedBox(height: 16),
        Text(l.assessmentDisclaimer, style: text.bodySmall),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: vm.start,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(vm.hasDraft ? l.resumeAssessment : l.startAssessment),
        ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AssessmentViewModel>();
    final item = vm.current;
    final chosen = vm.answerFor(item);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: (vm.index + 1) / vm.items.length),
          const SizedBox(height: 8),
          Text(
            l.questionProgress(vm.index + 1, vm.items.length),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          Text(
            vm.itemText(item),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          for (var value = 5; value >= 1; value--)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Option(
                label: vm.scale[value - 1],
                selected: chosen == value,
                onTap: () => vm.answer(value),
              ),
            ),
          const Spacer(),
          ErrorLine(vm.error),
          Row(
            children: [
              TextButton.icon(
                onPressed: vm.index == 0 ? null : vm.back,
                icon: const Icon(Icons.arrow_back),
                label: Text(l.previousQuestion),
              ),
              const Spacer(),
              if (vm.isLast)
                FilledButton(
                  onPressed: vm.allAnswered ? vm.submit : null,
                  child: Text(l.seeResult),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = Size.fromHeight(52);
    return selected
        ? FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(minimumSize: size),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(minimumSize: size),
            child: Text(label),
          );
  }
}

class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AssessmentViewModel>();
    final s = vm.scores!;
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          vm.perspective == Perspective.self
              ? l.resultLeadSelf
              : l.resultLeadChild(vm.subjectName),
          style: text.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(s.style.label(l), style: text.headlineMedium),
        const SizedBox(height: 8),
        Text(s.style.description(l)),
        const SizedBox(height: 20),
        _ScoreBar(label: l.dimWarmth, value: s.warmth),
        const SizedBox(height: 12),
        _ScoreBar(label: l.dimDemandingness, value: s.demandingness),
        const SizedBox(height: 24),
        Text(l.tryThis, style: text.titleMedium),
        const SizedBox(height: 8),
        for (final (i, a) in vm.advice.indexed)
          AdviceCard(advice: a, initiallyExpanded: i == 0),
        TextButton(
          onPressed: () => context.go('${Routes.advice}?style=${s.style.name}'),
          child: Text(l.seeAllAdvice),
        ),
        const SizedBox(height: 16),
        Text(l.assessmentDisclaimer, style: text.bodySmall),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go(Routes.home),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(l.done),
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label $value / 100',
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label), const Spacer(), Text('$value')]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: value / 100, minHeight: 8),
        ),
      ],
    ),
  );
}
