import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/auth_user.dart';
import '../model/user_profile.dart';
import 'user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('user').doc(uid);
  @override
  Future<void> ensureUser(AuthUser user) async {
    // A transaction makes retries/concurrent logins safe: never reset an existing profile.
    await _db
        .runTransaction((transaction) async {
          final ref = _doc(user.uid);
          final snapshot = await transaction.get(ref);
          if (!snapshot.exists) {
            transaction.set(
              ref,
              UserProfile.initialData(user, FieldValue.serverTimestamp()),
            );
          }
        })
        .timeout(const Duration(seconds: 20));
  }

  @override
  Stream<UserProfile?> watch(String uid) => _doc(uid).snapshots().map(
    (snapshot) =>
        snapshot.exists ? UserProfile.fromMap(uid, snapshot.data()!) : null,
  );
  @override
  Future<void> save(UserProfile profile) => _doc(profile.uid)
      .update({
        ...profile.editableData(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      .timeout(const Duration(seconds: 20));
}
