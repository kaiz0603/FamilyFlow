import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/assessment/scoring.dart';
import '../../domain/models/assessment.dart';
import '../../utils/result.dart';
import 'family_repository.dart';

/// Saved Assessments (scores, family-visible) and their private answers.
/// Also keeps the device-local draft of an unfinished Assessment.
class AssessmentRepository {
  AssessmentRepository(this._db, [Future<SharedPreferences>? prefs])
    : _prefs = prefs ?? SharedPreferences.getInstance();

  final FirebaseFirestore _db;
  final Future<SharedPreferences> _prefs;

  CollectionReference<Map<String, dynamic>> _assessments(String fid) =>
      _db.collection('families').doc(fid).collection('assessments');

  /// Newest first.
  Stream<List<Assessment>> watchFamily(String fid) =>
      _assessments(fid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((q) => [for (final d in q.docs) _fromDoc(d)])
          .handleError((_) {}, test: _isPermissionDenied);

  /// One batch: private answers, the scores, and an Activity entry.
  Future<Result<String>> save({
    required String fid,
    required String uid,
    required Perspective perspective,
    required String subjectParentId,
    required Map<String, int> answers,
    required Scores scores,
    required String contentVersion,
  }) => guard(() async {
    final ref = _assessments(fid).doc();
    final batch = _db.batch()
      ..set(
        _db.collection('users').doc(uid).collection('answers').doc(ref.id),
        {
          'familyId': fid,
          'answers': answers,
          'contentVersion': contentVersion,
          'createdAt': FieldValue.serverTimestamp(),
        },
      )
      ..set(ref, {
        'raterId': uid,
        'subjectParentId': subjectParentId,
        'perspective': perspective.stored,
        'warmth': scores.warmth,
        'demandingness': scores.demandingness,
        'style': scores.style.name,
        'contentVersion': contentVersion,
        'createdAt': FieldValue.serverTimestamp(),
      });
    FamilyRepository.addActivity(
      _db,
      batch,
      fid,
      uid,
      'assessment_done',
      refId: ref.id,
    );
    await batch.commit();
    return ref.id;
  });

  // ---- drafts (device only, PRD F3.3) ----

  static String _draftKey(String uid, String subjectParentId) =>
      'draft:$uid:$subjectParentId';

  Future<Map<String, int>> loadDraft(String uid, String subjectParentId) async {
    final raw = (await _prefs).getString(_draftKey(uid, subjectParentId));
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>).cast<String, int>();
  }

  Future<void> saveDraft(
    String uid,
    String subjectParentId,
    Map<String, int> answers,
  ) async => (await _prefs).setString(
    _draftKey(uid, subjectParentId),
    jsonEncode(answers),
  );

  Future<void> clearDraft(String uid, String subjectParentId) async =>
      (await _prefs).remove(_draftKey(uid, subjectParentId));

  static Assessment _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data();
    return Assessment(
      id: d.id,
      raterId: j['raterId'] as String,
      subjectParentId: j['subjectParentId'] as String,
      perspective: Perspective.fromStored(j['perspective'] as String),
      warmth: j['warmth'] as int,
      demandingness: j['demandingness'] as int,
      style: ParentingStyle.values.byName(j['style'] as String),
      contentVersion: j['contentVersion'] as String,
      // Pending local writes have no server timestamp yet.
      createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static bool _isPermissionDenied(dynamic e) =>
      e is FirebaseException && e.code == 'permission-denied';
}
