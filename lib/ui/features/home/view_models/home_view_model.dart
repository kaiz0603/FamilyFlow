import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/assessment_repository.dart';
import '../../../../data/repositories/family_repository.dart';
import '../../../../domain/models/assessment.dart';
import '../../../../domain/models/family.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../utils/result.dart';

enum HomeMode { loading, noFamily, pending, rejected, inFamily }

/// The Family part of Home: set up / waiting / the Family itself.
/// Follows the profile's familyId and pendingFamilyId from [Session].
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
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

  HomeMode _mode = HomeMode.loading;
  HomeMode get mode => _mode;

  Family? _family;
  Family? get family => _family;

  List<Member> _members = const [];
  List<Member> get members => _members;

  List<JoinRequest> _requests = const [];
  List<JoinRequest> get pendingRequests => _requests;

  Invite? _invite;
  Invite? get invite => _invite;

  List<Assessment> _assessments = const [];

  List<Member> get parents => [
    for (final m in _members)
      if (m.role == Role.parent) m,
  ];

  /// Newest first, so the first match is the latest.
  Assessment? get latestSelf => _assessments
      .where((a) => a.perspective == Perspective.self && a.raterId == me?.uid)
      .firstOrNull;

  Assessment? latestByMeFor(String parentUid) => _assessments
      .where(
        (a) =>
            a.perspective == Perspective.childView &&
            a.raterId == me?.uid &&
            a.subjectParentId == parentUid,
      )
      .firstOrNull;

  bool _busy = false;
  bool get busy => _busy;

  AppError? _error;
  AppError? get error => _error;

  UserProfile? get me => _session.profile;
  bool get isParent => me?.role == Role.parent;

  void _follow() {
    final me = _session.profile;
    if (me == null) return;
    final key = '${me.familyId}|${me.pendingFamilyId}';
    if (key == _followedKey) return;
    _followedKey = key;
    _cancelSubs();
    _family = null;
    _members = const [];
    _requests = const [];
    _invite = null;
    _assessments = const [];

    if (me.familyId case final fid?) {
      _mode = HomeMode.loading;
      _subs
        ..add(
          _families.watchFamily(fid).listen((f) {
            if (f == null) return _lostFamily(me.uid);
            _family = f;
            _update();
          }),
        )
        ..add(
          _families.watchMembers(fid, me.uid).listen((m) {
            if (m == null) return _lostFamily(me.uid);
            _members = m;
            _update();
          }),
        )
        ..add(
          _assessmentRepo.watchFamily(fid).listen((a) {
            _assessments = a;
            notifyListeners();
          }),
        );
      if (me.role == Role.parent) {
        _subs
          ..add(
            _families.watchPendingRequests(fid).listen((r) {
              _requests = r;
              notifyListeners();
            }),
          )
          ..add(
            _families.watchInvite(fid).listen((i) {
              _invite = i;
              notifyListeners();
            }),
          );
      }
    } else if (me.pendingFamilyId case final fid?) {
      _mode = HomeMode.pending;
      _subs.add(
        _families.watchMyRequest(fid, me.uid).listen((r) {
          switch (r?.status) {
            case JoinStatus.approved:
              _run(() => _families.completeJoin(fid, me.uid));
            case JoinStatus.rejected:
              _mode = HomeMode.rejected;
              notifyListeners();
            case JoinStatus.pending:
              _mode = HomeMode.pending;
              notifyListeners();
            case null: // A parent deleted it: clear our pointer.
              _run(() => _families.cancelRequest(fid, me.uid));
          }
        }),
      );
    } else {
      _mode = HomeMode.noFamily;
    }
    notifyListeners();
  }

  void _update() {
    if (_family != null && _members.isNotEmpty) _mode = HomeMode.inFamily;
    notifyListeners();
  }

  /// Removed, or the Family was dissolved. Clearing familyId makes [_follow] reset.
  void _lostFamily(String uid) {
    _cancelSubs();
    _run(() => _families.clearFamily(uid));
  }

  // ---- commands ----

  Future<bool> createFamily(String name) {
    final me = this.me!;
    return _run(
      () => _families.createFamily(
        uid: me.uid,
        name: name,
        displayName: me.displayName,
      ),
    );
  }

  Future<bool> joinWithCode(String code) => _run(() async {
    final me = this.me!;
    final found = await _families.findFamilyByCode(code);
    return switch (found) {
      Err(:final error) => Err(error),
      Ok(value: final fid) => _families.requestToJoin(
        uid: me.uid,
        fid: fid,
        code: code,
        profile: me,
      ),
    };
  });

  /// Withdraw a pending request, or dismiss a rejected one.
  Future<bool> cancelRequest() {
    final me = this.me!;
    return _run(() => _families.cancelRequest(me.pendingFamilyId!, me.uid));
  }

  Future<bool> createInvite() =>
      _run(() => _families.createInvite(_family!.id, me!.uid));

  Future<bool> approve(JoinRequest r) =>
      _run(() => _families.approve(_family!.id, r));

  Future<bool> reject(JoinRequest r) =>
      _run(() => _families.reject(_family!.id, r.uid));

  Future<bool> removeMember(Member m) =>
      _run(() => _families.removeMember(_family!.id, me!.uid, m.uid));

  Future<bool> _run<T>(Future<Result<T>> Function() op) async {
    _busy = true;
    _error = null;
    notifyListeners();
    final result = await op();
    _busy = false;
    if (result case Err(:final error)) _error = error;
    notifyListeners();
    return result is Ok;
  }

  void _cancelSubs() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  @override
  void dispose() {
    _session.removeListener(_follow);
    _cancelSubs();
    super.dispose();
  }
}
