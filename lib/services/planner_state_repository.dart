import 'package:cloud_firestore/cloud_firestore.dart';

/// Versioned UI state, not a substitute for task/goal business entities.
class PlannerStateRepository {
  PlannerStateRepository(this.uid, {FirebaseFirestore? db})
    : db = db ?? FirebaseFirestore.instance;
  final String uid;
  final FirebaseFirestore db;
  DocumentReference<Map<String, dynamic>> get ref =>
      db.doc('user/$uid/appState/current');
  Future<Map<String, dynamic>?> load() async =>
      (await ref.get(const GetOptions(source: Source.server))).data();
  Future<void> save(Map<String, dynamic> state) => ref
      .set({
        ...state,
        'schemaVersion': 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
      .timeout(const Duration(seconds: 20));
}
