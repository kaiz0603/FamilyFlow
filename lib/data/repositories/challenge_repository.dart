import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/challenge.dart';
import '../../utils/result.dart';
import 'family_repository.dart';

/// Challenges and the Family Activity feed (docs/DATA_MODEL.md).
class ChallengeRepository {
  ChallengeRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _challenges(String fid) =>
      _db.collection('families').doc(fid).collection('challenges');
  CollectionReference<Map<String, dynamic>> _activity(String fid) =>
      _db.collection('families').doc(fid).collection('activity');

  /// The newest Challenge (active or finished), or null when there is none.
  Stream<Challenge?> watchCurrent(String fid) =>
      _challenges(fid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((q) => q.docs.isEmpty ? null : _fromDoc(q.docs.first))
          .handleError((_) {}, test: _isPermissionDenied);

  /// Newest first.
  Stream<List<ActivityEntry>> watchActivity(String fid, {int limit = 20}) =>
      _activity(fid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs)
                if (ActivityType.fromStored(d['type'] as String) case final t?)
                  ActivityEntry(
                    id: d.id,
                    type: t,
                    actorId: d['actorId'] as String,
                    createdAt:
                        (d['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                  ),
            ],
          )
          .handleError((_) {}, test: _isPermissionDenied);

  /// Starts a week from [today]. Fails with [AppError.challengeActive] while
  /// another Challenge is still running (PRD F7.2).
  Future<Result<String>> start({
    required String fid,
    required String uid,
    required String adviceId,
    required String title,
    required List<String> participants,
    required String today,
  }) => guard(() async {
    // Transactions cannot run queries: find active ones first, then re-read
    // each inside the transaction (see the shortcut in docs/DATA_MODEL.md).
    final active = await _challenges(fid)
        .where('status', isEqualTo: 'active')
        .get();
    return _db.runTransaction((tx) async {
      for (final d in active.docs) {
        final c = _fromSnap(await tx.get(d.reference));
        if (c != null && !c.isOver(today)) {
          throw const AppException(AppError.challengeActive);
        }
      }
      final ref = _challenges(fid).doc();
      tx
        ..set(ref, {
          'adviceId': adviceId,
          'title': title,
          'createdBy': uid,
          'participants': participants,
          'startDate': today,
          'endDate': addDays(today, Challenge.length - 1),
          'status': 'active',
          'checkIns': <String, Object?>{},
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..set(
          _activity(fid).doc(),
          FamilyRepository.activityData(
            uid,
            ActivityType.challengeStarted.stored,
            refId: ref.id,
          ),
        );
      return ref.id;
    });
  });

  Future<Result<void>> checkIn(
    String fid,
    String challengeId,
    String uid,
    String today,
  ) => guard(
    () => _challenges(fid).doc(challengeId).update({
      'checkIns.$uid': FieldValue.arrayUnion([today]),
    }),
  );

  /// Closes the week once; a second Participant finishing it is a no-op.
  Future<Result<void>> finish(String fid, String challengeId, String uid) =>
      guard(
        () => _db.runTransaction((tx) async {
          final ref = _challenges(fid).doc(challengeId);
          if ((await tx.get(ref)).data()?['status'] != 'active') return;
          tx
            ..update(ref, {'status': 'finished'})
            ..set(
              _activity(fid).doc(),
              FamilyRepository.activityData(
                uid,
                ActivityType.challengeFinished.stored,
                refId: challengeId,
              ),
            );
        }),
      );

  static Challenge? _fromSnap(DocumentSnapshot<Map<String, dynamic>> s) =>
      s.exists ? _parse(s.id, s.data()!) : null;

  static Challenge _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
      _parse(d.id, d.data());

  static Challenge _parse(String id, Map<String, dynamic> j) => Challenge(
    id: id,
    adviceId: j['adviceId'] as String,
    title: j['title'] as String,
    createdBy: j['createdBy'] as String,
    participants: (j['participants'] as List).cast<String>(),
    startDate: j['startDate'] as String,
    endDate: j['endDate'] as String,
    finished: j['status'] == 'finished',
    checkIns: {
      for (final e in (j['checkIns'] as Map? ?? {}).entries)
        e.key as String: (e.value as List).cast<String>(),
    },
  );

  static bool _isPermissionDenied(dynamic e) =>
      e is FirebaseException && e.code == 'permission-denied';
}
