import '../models/assessment.dart';

/// Scoring model from docs/ASSESSMENT.md. Pure Dart; mirrored by the quadrant
/// check in firebase/firestore.rules (assessments create).

/// shortcut: the scale midpoint, not a population norm. Upgrade when there are
/// enough real answers to set norms per form.
const cutoff = 50;

typedef Scores = ({int warmth, int demandingness, ParentingStyle style});

/// [answers] maps every item id to 1..5. Throws [ArgumentError] otherwise.
Scores score(List<Item> items, Map<String, int> answers) {
  final sums = {for (final d in Dimension.values) d: 0};
  final counts = {for (final d in Dimension.values) d: 0};
  for (final item in items) {
    final a = answers[item.id];
    if (a == null || a < 1 || a > 5) {
      throw ArgumentError.value(a, item.id, 'answer must be 1..5');
    }
    sums[item.dimension] = sums[item.dimension]! + (item.reverse ? 6 - a : a);
    counts[item.dimension] = counts[item.dimension]! + 1;
  }
  int scaled(Dimension d) => ((sums[d]! / counts[d]! - 1) / 4 * 100).round();
  final w = scaled(Dimension.warmth);
  final d = scaled(Dimension.demandingness);
  return (warmth: w, demandingness: d, style: styleFor(w, d));
}

ParentingStyle styleFor(int warmth, int demandingness) =>
    switch ((warmth >= cutoff, demandingness >= cutoff)) {
      (true, true) => ParentingStyle.authoritative,
      (false, true) => ParentingStyle.authoritarian,
      (true, false) => ParentingStyle.permissive,
      (false, false) => ParentingStyle.neglectful,
    };

enum GapBand { same, some, large }

/// How different two views of one Dimension are (child view minus self).
GapBand gapBand(int gap) => switch (gap.abs()) {
  < 10 => GapBand.same,
  < 25 => GapBand.some,
  _ => GapBand.large,
};
