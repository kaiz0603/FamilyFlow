import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/assessment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/advice_card.dart';
import '../../../core/assessment_labels.dart';
import '../view_models/advice_view_model.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<AdviceViewModel>();
    final cards = vm.visible;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabAdvice)),
      body: !vm.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _Chips<ParentingStyle>(
                  allLabel: l.allStyles,
                  values: ParentingStyle.values,
                  selected: vm.style,
                  label: (s) => s.label(l),
                  onSelected: vm.filterStyle,
                ),
                _Chips<String>(
                  allLabel: l.allTopics,
                  values: AdviceLibrary.tags,
                  selected: vm.tag,
                  label: (t) => tagLabel(l, t),
                  onSelected: vm.filterTag,
                ),
                const SizedBox(height: 8),
                if (cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.adviceEmpty, textAlign: TextAlign.center),
                  ),
                for (final a in cards)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AdviceCard(key: ValueKey(a.id), advice: a),
                  ),
              ],
            ),
    );
  }
}

/// One horizontally scrolling row of single-choice chips with an "All" chip.
class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.allLabel,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String allLabel;
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final void Function(T?) onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Row(
      children: [
        ChoiceChip(
          label: Text(allLabel),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final v in values)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(label(v)),
              selected: selected == v,
              onSelected: (_) => onSelected(v),
            ),
          ),
      ],
    ),
  );
}
