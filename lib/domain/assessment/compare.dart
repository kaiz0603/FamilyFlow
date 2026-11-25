import '../models/assessment.dart';
import '../models/family.dart';

/// What one Parent's Compare card shows (docs/ASSESSMENT.md, Perception Gap).
class ParentComparison {
  const ParentComparison({
    required this.parent,
    required this.self,
    required this.views,
    required this.history,
  });

  final Member parent;

  /// Latest Self Assessment in the current major Content Version.
  final Assessment? self;

  /// Latest Child View per Child, same major as [self]. Children without one
  /// are left out.
  final List<({Member child, Assessment view})> views;

  /// Every Assessment about [parent] by the shown raters, oldest first,
  /// across all Content Versions.
  final List<Assessment> history;

  bool get isEmpty => self == null && views.isEmpty;
}

/// [all] is newest first (AssessmentRepository.watchFamily). [children] are
/// the raters to show: every Child for a Parent's own card, only the viewer
/// for a Child's card.
ParentComparison compareParent(
  Member parent,
  List<Member> children,
  List<Assessment> all,
) {
  final childIds = {for (final c in children) c.uid};
  final about = [
    for (final a in all)
      if (a.subjectParentId == parent.uid &&
          (a.perspective == Perspective.self
              ? a.raterId == parent.uid
              : childIds.contains(a.raterId)))
        a,
  ];
  // The newest Assessment sets the major: older majors used other Items.
  final major = about.firstOrNull?.majorVersion;
  final current = [
    for (final a in about)
      if (a.majorVersion == major) a,
  ];
  return ParentComparison(
    parent: parent,
    self: current.where((a) => a.perspective == Perspective.self).firstOrNull,
    views: [
      for (final c in children)
        if (current
                .where(
                  (a) =>
                      a.perspective == Perspective.childView &&
                      a.raterId == c.uid,
                )
                .firstOrNull
            case final v?)
          (child: c, view: v),
    ],
    history: about.reversed.toList(),
  );
}

/// Child View minus Self, per Dimension.
({int warmth, int demandingness}) gap(Assessment self, Assessment view) => (
  warmth: view.warmth - self.warmth,
  demandingness: view.demandingness - self.demandingness,
);
