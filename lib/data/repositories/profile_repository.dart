import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_profile.dart';
import '../../utils/result.dart';

/// `users/{uid}` (docs/DATA_MODEL.md). Owner-only by the rules.
class ProfileRepository {
  ProfileRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// Emits null when the profile does not exist yet. A cache-only "missing"
  /// is skipped, so an offline cold start doesn't look like a new user.
  Stream<UserProfile?> watch(String uid) =>
      _doc(uid)
          .snapshots(includeMetadataChanges: true)
          .where((s) => s.exists || !s.metadata.isFromCache)
          .map((s) => s.exists ? _fromDoc(uid, s.data()!) : null);

  Future<Result<void>> create({
    required String uid,
    required String displayName,
    required Role role,
    required int birthYear,
    required String locale,
  }) => guard(
    () => _doc(uid).set({
      'displayName': displayName.trim(),
      'role': role.name,
      'birthYear': birthYear,
      'locale': locale,
      'familyId': null,
      'createdAt': FieldValue.serverTimestamp(),
    }),
  );

  Future<Result<void>> update(
    String uid, {
    String? displayName,
    String? locale,
  }) => guard(
    () =>
        _doc(uid)
            .update({'displayName': ?displayName?.trim(), 'locale': ?locale}),
  );

  /// Deletes the private answers first, then the profile (docs/PRIVACY.md).
  Future<Result<void>> delete(String uid) => guard(() async {
    final answers = await _doc(uid).collection('answers').get();
    final batch = _db.batch();
    for (final d in answers.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_doc(uid));
    await batch.commit();
  });

  static UserProfile _fromDoc(String uid, Map<String, dynamic> d) =>
      UserProfile(
        uid: uid,
        displayName: d['displayName'] as String,
        role: Role.values.byName(d['role'] as String),
        birthYear: d['birthYear'] as int,
        locale: d['locale'] as String,
        familyId: d['familyId'] as String?,
        pendingFamilyId: d['pendingFamilyId'] as String?,
      );
}
