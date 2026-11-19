import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/assessment_repository.dart';
import '../../../../data/repositories/family_repository.dart';
import '../../../../domain/assessment/compare.dart';
import '../../../../domain/models/assessment.dart';
import '../../../../domain/models/family.dart';
import '../../../../domain/models/user_profile.dart';

/// Compare + History (PRD F5, F6). A Parent sees their own card with every
/// Child View; a Child sees one card per Parent they rated, with their own view.
class CompareViewModel extends ChangeNotifier {
  CompareViewModel({
    required this._session,
    required this._families,
    required this._assessmentRepo,
  }) {
    _session.addListener(_follow);
    _follow();
  }

  final Session _session;
  final FamilyRepository _families;
  final AssessmentRepository _assessmentRepo;
  final List<StreamSubscription<Object?>> _subs = [];
  String? _followedKey;

  bool _loading = true;
  bool get loading => _loading;

  List<Member> _members = const [];
  List<Assessment> _assessments = const [];

  UserProfile? get me => _session.profile;
  bool get isParent => me?.role == Role.parent;
  bool get hasFamily => me?.familyId != null;

  List<Member> _withRole(Role r) => [
    for (final m in _members)
      if (m.role == r) m,
  ];

  List<Member> get children => _withRole(Role.child);

  List<ParentComparison> get cards {
    final me = this.me;
    if (me == null) return const [];
    if (isParent) {
      final mine = _members.where((m) => m.uid == me.uid).firstOrNull;
      return [if (mine != null) compareParent(mine, children, _assessments)];
    }
    final self = _members.where((m) => m.uid == me.uid).toList();
    return [
      for (final p in _withRole(Role.parent))
        if (compareParent(p, self, _assessments) case final c
            when c.history.any((a) => a.raterId == me.uid))
          c,
    ];
  }

  /// For a Child: Parents not rated yet, to offer a first rating.
  List<Member> get unratedParents {
    final me = this.me;
    if (me == null || isParent) return const [];
    return [
      for (final p in _withRole(Role.parent))
        if (!_assessments.any(
          (a) => a.raterId == me.uid && a.subjectParentId == p.uid,
        ))
          p,
    ];
  }

  void _follow() {
    final me = _session.profile;
    final fid = me?.familyId;
    final key = '${me?.uid}|$fid';
    if (key == _followedKey) return;
    _followedKey = key;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _members = const [];
    _assessments = const [];
    _loading = me == null || fid != null;
    if (me != null && fid != null) {
      _subs
        ..add(
          _families.watchMembers(fid, me.uid).listen((m) {
            _members = m ?? const [];
            _loading = false;
            notifyListeners();
          }),
        )
        ..add(
          _assessmentRepo.watchFamily(fid).listen((a) {
            _assessments = a;
            notifyListeners();
          }),
        );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _session.removeListener(_follow);
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
