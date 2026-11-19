import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/family.dart';
import '../../domain/models/user_profile.dart';
import '../../utils/result.dart';

/// Families, Members, Invite Codes and Join Requests (docs/DATA_MODEL.md).
/// Every multi-document change is one batch, matching what the rules expect.
class FamilyRepository {
  FamilyRepository(this._db, {Random? random})
    : _random = random ?? Random.secure();

  final FirebaseFirestore _db;
  final Random _random;

  static const activityLifetime = Duration(days: 90);
  static const _batchLimit = 450; // Firestore allows 500 writes per batch.

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> _family(String fid) =>
      _db.collection('families').doc(fid);
  CollectionReference<Map<String, dynamic>> _members(String fid) =>
      _family(fid).collection('members');
  CollectionReference<Map<String, dynamic>> _requests(String fid) =>
      _family(fid).collection('joinRequests');
  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection('invites');

  // ---- reads ----

  /// Emits null once the caller can no longer read the Family (removed or dissolved).
  Stream<Family?> watchFamily(String fid) =>
      _family(fid)
          .snapshots()
          .where((s) => s.exists || !s.metadata.isFromCache)
          .map<Family?>(
            (s) => s.exists
                ? Family(
                    id: fid,
                    name: s.data()!['name'] as String,
                    createdBy: s.data()!['createdBy'] as String,
                  )
                : null,
          )
          .transform(_nullWhenDenied());

  /// Emits null once [uid] is no longer a Member: read access lost, or a
  /// server snapshot without them. Cache-only snapshots never count as removal.
  Stream<List<Member>?> watchMembers(String fid, String uid) => _members(fid)
      .snapshots()
      .where((q) => !q.metadata.isFromCache || q.docs.any((d) => d.id == uid))
      .map<List<Member>?>((q) {
        if (!q.docs.any((d) => d.id == uid)) return null;
        return [
          for (final d in q.docs)
            Member(
              uid: d.id,
              role: Role.values.byName(d['role'] as String),
              displayName: d['displayName'] as String,
            ),
        ]..sort(
          (a, b) => a.role.index.compareTo(b.role.index),
        ); // parents first
      })
      .transform(_nullWhenDenied());

  Stream<List<JoinRequest>> watchPendingRequests(String fid) =>
      _requests(fid)
          .where('status', isEqualTo: JoinStatus.pending.name)
          .snapshots()
          .map((q) => [for (final d in q.docs) _request(d.id, d.data())])
          .handleError((_) {}, test: _isPermissionDenied);

  /// The caller's own request; null when it no longer exists.
  Stream<JoinRequest?> watchMyRequest(String fid, String uid) =>
      _requests(fid)
          .doc(uid)
          .snapshots()
          .where((s) => s.exists || !s.metadata.isFromCache)
          .map((s) => s.exists ? _request(uid, s.data()!) : null);

  /// The newest unexpired Invite Code of the Family (parents only).
  Stream<Invite?> watchInvite(String fid) => _invites
      .where('familyId', isEqualTo: fid)
      .snapshots()
      .map((q) {
        final now = DateTime.now();
        final valid =
            [
                for (final d in q.docs)
                  Invite(
                    code: d.id,
                    expiresAt: (d['expiresAt'] as Timestamp).toDate(),
                  ),
              ].where((i) => i.expiresAt.isAfter(now)).toList()
              ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
        return valid.isEmpty ? null : valid.first;
      })
      .handleError((_) {}, test: _isPermissionDenied);

  Future<Result<bool>> isLastParent(String fid, String uid) => guard(() async {
    final parents = await _members(fid)
        .where('role', isEqualTo: Role.parent.name)
        .get();
    return parents.docs.every((d) => d.id == uid);
  });

  // ---- create and invite ----

  Future<Result<String>> createFamily({
    required String uid,
    required String name,
    required String displayName,
  }) => guard(() async {
    final ref = _db.collection('families').doc();
    await (_db.batch()
          ..set(ref, {
            'name': name.trim(),
            'createdBy': uid,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(ref.collection('members').doc(uid), {
            'role': Role.parent.name,
            'displayName': displayName,
            'joinedAt': FieldValue.serverTimestamp(),
          })
          ..update(_user(uid), {'familyId': ref.id}))
        .commit();
    return ref.id;
  });

  /// Creating over an existing code is denied by the rules, so a taken code is
  /// checked first and a new one drawn.
  Future<Result<Invite>> createInvite(String fid, String uid) =>
      guard(() async {
        for (var attempt = 0; attempt < 5; attempt++) {
          final code = _newCode();
          final ref = _invites.doc(code);
          if ((await ref.get()).exists) continue;
          final invite = Invite(
            code: code,
            expiresAt: DateTime.now().add(Invite.lifetime),
          );
          await ref.set({
            'familyId': fid,
            'createdBy': uid,
            'expiresAt': Timestamp.fromDate(invite.expiresAt),
          });
          return invite;
        }
        throw StateError('No free invite code after 5 attempts');
      });

  String _newCode() => String.fromCharCodes([
    for (var i = 0; i < Invite.length; i++)
      Invite.alphabet.codeUnitAt(_random.nextInt(Invite.alphabet.length)),
  ]);

  // ---- joining ----

  /// The Family id behind [code], or [AppError.invalidInviteCode].
  Future<Result<String>> findFamilyByCode(String code) async {
    final normalized = Invite.normalize(code);
    if (!Invite.isWellFormed(normalized)) {
      return const Err(AppError.invalidInviteCode);
    }
    final result = await guard(() => _invites.doc(normalized).get());
    return switch (result) {
      Err(:final error) => Err(error),
      Ok(value: final s)
          when s.exists &&
              (s['expiresAt'] as Timestamp).toDate().isAfter(DateTime.now()) =>
        Ok(s['familyId'] as String),
      Ok() => const Err(AppError.invalidInviteCode),
    };
  }

  Future<Result<void>> requestToJoin({
    required String uid,
    required String fid,
    required String code,
    required UserProfile profile,
  }) => guard(
    () =>
        (_db.batch()
              ..set(_requests(fid).doc(uid), {
                'code': Invite.normalize(code),
                'role': profile.role.name,
                'displayName': profile.displayName,
                'status': JoinStatus.pending.name,
                'createdAt': FieldValue.serverTimestamp(),
              })
              ..update(_user(uid), {'pendingFamilyId': fid}))
            .commit(),
  );

  /// Withdraw a request, or clear one a parent rejected or deleted.
  Future<Result<void>> cancelRequest(String fid, String uid) => guard(
    () =>
        (_db.batch()
              ..delete(_requests(fid).doc(uid))
              ..update(_user(uid), {'pendingFamilyId': null}))
            .commit(),
  );

  /// Called by the joiner once a parent approved.
  Future<Result<void>> completeJoin(String fid, String uid) => guard(() {
    final batch = _db.batch()
      ..update(_user(uid), {'familyId': fid, 'pendingFamilyId': null})
      ..delete(_requests(fid).doc(uid));
    addActivity(_db, batch, fid, uid, 'member_joined');
    return batch.commit();
  });

  Future<Result<void>> approve(String fid, JoinRequest request) => guard(
    () =>
        (_db.batch()
              ..set(_members(fid).doc(request.uid), {
                'role': request.role.name,
                'displayName': request.displayName,
                'joinedAt': FieldValue.serverTimestamp(),
              })
              ..update(_requests(fid).doc(request.uid), {
                'status': JoinStatus.approved.name,
              }))
            .commit(),
  );

  Future<Result<void>> reject(String fid, String uid) => guard(
    () => _requests(fid).doc(uid).update({'status': JoinStatus.rejected.name}),
  );

  // ---- leaving ----

  Future<Result<void>> removeMember(String fid, String byUid, String uid) =>
      guard(() {
        final batch = _db.batch()..delete(_members(fid).doc(uid));
        addActivity(_db, batch, fid, byUid, 'member_left', refId: uid);
        return batch.commit();
      });

  /// Leaving removes our own Assessments from the Family (docs/PRIVACY.md).
  Future<Result<void>> leave(String fid, String uid) => guard(() async {
    final mine = await _family(fid)
        .collection('assessments')
        .where('raterId', isEqualTo: uid)
        .get();
    final batch = _db.batch();
    for (final d in mine.docs) {
      batch.delete(d.reference);
    }
    addActivity(_db, batch, fid, uid, 'member_left');
    batch
      ..delete(_members(fid).doc(uid))
      ..update(_user(uid), {'familyId': null});
    await batch.commit();
  });

  /// The last Parent leaving: delete everything under the Family.
  /// shortcut: several batches; an interrupted run leaves unreadable orphans
  /// (docs/DATA_MODEL.md). Upgrade with a Functions cleanup if on Blaze.
  Future<Result<void>> dissolve(String fid, String uid) => guard(() async {
    final refs = <DocumentReference>[
      for (final d
          in (await _invites.where('familyId', isEqualTo: fid).get()).docs)
        d.reference,
      for (final sub in ['activity', 'joinRequests', 'assessments'])
        for (final d in (await _family(fid).collection(sub).get()).docs)
          d.reference,
      for (final d in (await _members(fid).get()).docs)
        if (d.id != uid) d.reference,
    ];
    for (var i = 0; i < refs.length; i += _batchLimit) {
      final batch = _db.batch();
      for (final r in refs.skip(i).take(_batchLimit)) {
        batch.delete(r);
      }
      await batch.commit();
    }
    // Last: the family doc needs our membership, so ours goes after it.
    await (_db.batch()
          ..delete(_family(fid))
          ..delete(_members(fid).doc(uid))
          ..update(_user(uid), {'familyId': null}))
        .commit();
  });

  /// A Child just leaves; the last Parent dissolves the Family.
  Future<Result<void>> leaveFamily(String fid, UserProfile me) async {
    if (me.role == Role.parent) {
      final last = await isLastParent(fid, me.uid);
      if (last case Err(:final error)) return Err(error);
      if (last case Ok(value: true)) return dissolve(fid, me.uid);
    }
    return leave(fid, me.uid);
  }

  /// Our profile points at a Family we are no longer in (removed or dissolved).
  Future<Result<void>> clearFamily(String uid) =>
      guard(() => _user(uid).update({'familyId': null}));

  // ---- helpers ----

  /// Adds an Activity entry to [batch] (shared with AssessmentRepository).
  static void addActivity(
    FirebaseFirestore db,
    WriteBatch batch,
    String fid,
    String uid,
    String type, {
    String? refId,
  }) => batch.set(
    db.collection('families').doc(fid).collection('activity').doc(),
    {
      'type': type,
      'actorId': uid,
      'refId': refId,
      'createdAt': FieldValue.serverTimestamp(),
      'expireAt': Timestamp.fromDate(DateTime.now().add(activityLifetime)),
    },
  );

  static JoinRequest _request(String uid, Map<String, dynamic> d) =>
      JoinRequest(
        uid: uid,
        role: Role.values.byName(d['role'] as String),
        displayName: d['displayName'] as String,
        status: JoinStatus.values.byName(d['status'] as String),
      );

  static bool _isPermissionDenied(dynamic e) =>
      e is FirebaseException && e.code == 'permission-denied';

  /// Losing read access means we were removed or the Family was dissolved.
  static StreamTransformer<T?, T?> _nullWhenDenied<T>() =>
      StreamTransformer.fromHandlers(
        handleError: (e, st, sink) =>
            _isPermissionDenied(e) ? sink.add(null) : sink.addError(e, st),
      );
}
