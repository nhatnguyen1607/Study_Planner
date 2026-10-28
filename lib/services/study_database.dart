import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/study_record.dart';

/// Construct once per authenticated session. Never accepts a UID from a form.
class StudyDatabase {
  StudyDatabase(this.uid, {FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance {
    if (uid.isEmpty || uid.contains('/')) throw ArgumentError('Invalid UID');
  }
  final String uid;
  final FirebaseFirestore db;
  static const collections = [
    'plans',
    'sessions',
    'goals',
    'tasks',
    'notifications',
    'activities',
    'settings',
  ];
  DocumentReference<Map<String, dynamic>> get root =>
      db.collection('user').doc(uid);
  CollectionReference<Map<String, dynamic>> collection(String kind) {
    if (!collections.contains(kind)) throw ArgumentError('Unknown collection');
    return root.collection(kind);
  }

  String newId(String kind) => collection(kind).doc().id;
  Stream<List<StudyRecord>> watch(String kind) => collection(kind)
      .snapshots(includeMetadataChanges: true)
      .where(
        (snap) => !snap.metadata.isFromCache && !snap.metadata.hasPendingWrites,
      )
      .map(
        (snap) => snap.docs.map((doc) {
          final data = doc.data();
          if (data['ownerId'] != uid || data['schemaVersion'] != 1) {
            throw const DataFailure(
              'schema-owner',
              'Bản ghi không đúng chủ sở hữu hoặc phiên bản dữ liệu.',
            );
          }
          return StudyRecord(doc.id, data);
        }).toList(),
      );
  Map<String, dynamic> envelope(
    Map<String, dynamic> data,
    int revision, {
    bool create = false,
  }) => {
    ...data,
    'ownerId': uid,
    'schemaVersion': 1,
    'revision': revision,
    if (create) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
  void check(StudyRecord? current, int? expected) {
    if (current != null && current.data['ownerId'] != uid) {
      throw const DataFailure('owner', 'Sai tài khoản.');
    }
    if ((current?.revision ?? 0) != (expected ?? 0)) {
      throw const DataFailure(
        'conflict',
        'Dữ liệu đã thay đổi trên thiết bị khác. Hãy tải lại rồi thử lại.',
      );
    }
  }

  Future<void> save(
    String kind,
    String id,
    Map<String, dynamic> data, {
    int? expected,
  }) async {
    if (kind == 'sessions' || kind == 'plans') {
      throw ArgumentError('Use calendar transaction');
    }
    await db
        .runTransaction((tx) async {
          final ref = collection(kind).doc(id), snap = await tx.get(ref);
          final current = snap.exists ? StudyRecord(id, snap.data()!) : null;
          check(current, expected);
          tx.set(
            ref,
            envelope(
              {...?current?.data, ...data},
              (current?.revision ?? 0) + 1,
              create: current == null,
            ),
            SetOptions(merge: true),
          );
        })
        .timeout(const Duration(seconds: 20));
  }

  /// All calendar writers share this lock, including the AI function.
  /// Read lock BEFORE querying, then recheck it inside the transaction.
  Future<void> saveCalendar({
    StudyRecord? plan,
    required List<StudyRecord> sessions,
    StudyRecord? existingPlan,
  }) async {
    final lockRef = collection('settings').doc('calendar');
    final before = await lockRef.get(const GetOptions(source: Source.server));
    final version = before.data()?['revision'] ?? 0;
    final stored = await collection('sessions')
        .get(const GetOptions(source: Source.server));
    final replaced = sessions.map((v) => v.id).toSet();
    final all = [
      ...stored.docs
          .where((d) => !replaced.contains(d.id))
          .map((d) => StudyRecord(d.id, d.data())),
      ...sessions,
    ].where((s) => !s.archived).toList();
    for (final s in sessions) {
      final start = s.date('startAt'), end = s.date('endAt');
      if (start == null ||
          end == null ||
          !end.isAfter(start) ||
          end.difference(start).inMinutes > 240 ||
          s.text('planId').isEmpty) {
        throw const DataFailure(
          'session-range',
          'Buổi học cần thuộc một kế hoạch và kéo dài từ 1 đến 240 phút.',
        );
      }
      if (s.archived) continue;
      if (all.any(
        (other) =>
            other.id != s.id &&
            other.date('startAt') != null &&
            other.date('endAt') != null &&
            start.isBefore(other.date('endAt')!) &&
            end.isAfter(other.date('startAt')!),
      )) {
        throw const DataFailure(
          'overlap',
          'Khung giờ này trùng với buổi học khác. Hãy chọn giờ khác.',
        );
      }
    }
    if (sessions.length > 350) {
      throw const DataFailure(
        'too-many',
        'Tối đa 350 buổi cho một lần tạo kế hoạch.',
      );
    }
    await db
        .runTransaction((tx) async {
          final lock = await tx.get(lockRef);
          if ((lock.data()?['revision'] ?? 0) != version) {
            throw const DataFailure(
              'calendar-conflict',
              'Lịch vừa thay đổi. Hãy thử lưu lại.',
            );
          }
          final planId = plan?.id ?? sessions.first.text('planId');
          if (sessions.any((s) => s.text('planId') != planId)) {
            throw const DataFailure(
              'plan-mismatch',
              'Các buổi học phải thuộc đúng kế hoạch đang lưu.',
            );
          }
          final planRef = collection('plans').doc(planId);
          final parent = await tx.get(planRef);
          if (plan == null &&
              (!parent.exists || parent.data()?['archived'] == true)) {
            throw const DataFailure(
              'plan-missing',
              'Kế hoạch không còn khả dụng.',
            );
          }
          if (plan != null) {
            check(
              parent.exists ? StudyRecord(plan.id, parent.data()!) : null,
              existingPlan?.revision,
            );
          }
          final snapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
          for (final s in sessions) {
            snapshots.add(await tx.get(collection('sessions').doc(s.id)));
          }
          for (var i = 0; i < sessions.length; i++) {
            final current = snapshots[i].exists
                ? StudyRecord(sessions[i].id, snapshots[i].data()!)
                : null;
            check(
              current,
              sessions[i].revision == 0 ? null : sessions[i].revision,
            );
            if (current != null &&
                current.text('planId') != sessions[i].text('planId')) {
              throw const DataFailure(
                'plan-immutable',
                'Không thể chuyển buổi học sang kế hoạch khác.',
              );
            }
          }
          if (plan != null) {
            tx.set(
              planRef,
              envelope(
                plan.data,
                (existingPlan?.revision ?? 0) + 1,
                create: !parent.exists,
              ),
              SetOptions(merge: true),
            );
          }
          for (var i = 0; i < sessions.length; i++) {
            final s = sessions[i];
            tx.set(
              collection('sessions').doc(s.id),
              envelope(s.data, s.revision + 1, create: !snapshots[i].exists),
              SetOptions(merge: true),
            );
          }
          tx.set(
            lockRef,
            envelope({}, (version as int) + 1, create: !lock.exists),
            SetOptions(merge: true),
          );
        })
        .timeout(const Duration(seconds: 30));
  }
}
