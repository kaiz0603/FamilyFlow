import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/challenge_repository.dart';
import '../../../../data/repositories/family_repository.dart';
import '../../../../domain/models/challenge.dart';
import '../../../../domain/models/family.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../utils/result.dart';

/// The Family's current Challenge, its check-ins and the Activity feed.
/// Used by Home and by the start screen.
class ChallengeViewModel extends ChangeNotifier {
  ChallengeViewModel({
    required this._session,
    required this._families,
    required this._challenges,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    _session.addListener(_follow);
    _follow();
  }

  final Session _session;
  final FamilyRepository _families;
  final ChallengeRepository _challenges;
  final DateTime Function() _now;
  final List<StreamSubscription<Object?>> _subs = [];
  String? _followedFid;
  String? _finishing;

  Challenge? _challenge;

  /// The newest Challenge, active or finished; null before the first one.
  Challenge? get challenge => _challenge;

  List<Member> _members = const [];
  List<Member> get members => _members;

  List<ActivityEntry> _activity = const [];
  List<ActivityEntry> get activity => _activity;

  bool _busy = false;
  bool get busy => _busy;

  AppError? _error;
  AppError? get error => _error;

  UserProfile? get me => _session.profile;
  String get today => localDate(_now());

  bool get hasActive => _challenge != null && !_challenge!.isOver(today);
  bool get canCheckIn => _challenge?.canCheckIn(me!.uid, today) ?? false;

  /// A Member who left keeps their check-ins; show a neutral name for them.
  String? nameOf(String uid) =>
      _members.where((m) => m.uid == uid).firstOrNull?.displayName;

  void _follow() {
    final me = _session.profile;
    final fid = me?.familyId;
    if (fid == _followedFid) return;
    _followedFid = fid;
    _cancelSubs();
    _challenge = null;
    _members = const [];
    _activity = const [];
    if (me != null && fid != null) {
      _subs
        ..add(
          _families.watchMembers(fid, me.uid).listen((m) {
            _members = m ?? const [];
            notifyListeners();
          }),
        )
        ..add(
          _challenges.watchCurrent(fid).listen((c) {
            _challenge = c;
            _finishIfOver(fid, me.uid);
            notifyListeners();
          }),
        )
        ..add(
          _challenges.watchActivity(fid).listen((a) {
            _activity = a;
            notifyListeners();
          }),
        );
    }
    notifyListeners();
  }

  /// The week has passed: the first Participant to see it writes the close.
  void _finishIfOver(String fid, String uid) {
    final c = _challenge;
    if (c == null || c.finished || !c.isOver(today)) return;
    if (!c.participants.contains(uid) || _finishing == c.id) return;
    _finishing = c.id;
    _challenges.finish(fid, c.id, uid);
  }

  // ---- commands ----

  Future<bool> start({
    required String adviceId,
    required String title,
    required List<String> participants,
  }) => _run(
    () => _challenges.start(
      fid: me!.familyId!,
      uid: me!.uid,
      adviceId: adviceId,
      title: title,
      participants: participants,
      today: today,
    ),
  );

  Future<bool> checkIn() => _run(
    () => _challenges.checkIn(me!.familyId!, _challenge!.id, me!.uid, today),
  );

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
