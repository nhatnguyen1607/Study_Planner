import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_record.dart';
import 'package:study_planner_flutter/services/study_database.dart';
import 'package:study_planner_flutter/viewmodel/study_data_view_model.dart';

StudyRecord plan(String id) => StudyRecord(id, {
  'title': 'Toán',
  'source': 'manual',
  'status': 'active',
  'subjects': ['Toán'],
  'startAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
  'endAt': Timestamp.fromDate(DateTime(2026, 12, 1)),
  'weeklyHours': 3,
  'archived': false,
});
StudyRecord session(String id, String planId, int hour) => StudyRecord(id, {
  'planId': planId,
  'title': 'Toán',
  'subject': 'Toán',
  'startAt': Timestamp.fromDate(DateTime(2026, 11, 2, hour)),
  'endAt': Timestamp.fromDate(DateTime(2026, 11, 2, hour + 1)),
  'status': 'scheduled',
  'actualMinutes': 0,
  'rating': 0,
  'archived': false,
});
Future<void> drain() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  test(
    'UID-scoped plan and dated sessions round trip without sharing records',
    () async {
      final db = FakeFirebaseFirestore();
      // Same database is essential to verify isolation, rather than two fake stores.
      final alice = StudyDatabase('alice', firestore: db),
          bob = StudyDatabase('bob', firestore: db);
      await alice.saveCalendar(
        plan: plan('p'),
        sessions: [session('s', 'p', 9)],
      );
      expect((await alice.watch('plans').first).single.text('title'), 'Toán');
      expect((await alice.watch('sessions').first).single.text('planId'), 'p');
      expect(await bob.watch('plans').first, isEmpty);
      await bob.saveCalendar(
        plan: plan('p'),
        sessions: [session('s', 'p', 10)],
      );
      expect(
        (await alice.watch('sessions').first).single.date('startAt')!.hour,
        9,
      );
      expect(
        (await bob.watch('sessions').first).single.date('startAt')!.hour,
        10,
      );
    },
  );
  test('Reject orphan sessions and overlapping schedules atomically', () async {
    final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
    await expectLater(
      repo.saveCalendar(sessions: [session('s', 'missing', 9)]),
      throwsA(isA<DataFailure>()),
    );
    await repo.saveCalendar(plan: plan('p'), sessions: [session('s', 'p', 9)]);
    await expectLater(
      repo.saveCalendar(
        plan: plan('second'),
        sessions: [session('s2', 'second', 9)],
      ),
      throwsA(isA<DataFailure>()),
    );
    expect((await repo.watch('plans').first).length, 1);
    expect((await repo.watch('sessions').first).length, 1);
  });
  test(
    'Stale updates cannot overwrite a newer record; extension fields survive',
    () async {
      final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
      await repo.save('tasks', 't', {
        'title': 'Task',
        'notes': '',
        'completed': false,
        'archived': false,
        'extensions': {'futureField': true},
      });
      await repo.save('tasks', 't', {'completed': true}, expected: 1);
      await expectLater(
        repo.save('tasks', 't', {'completed': false}, expected: 1),
        throwsA(isA<DataFailure>()),
      );
      final record = (await repo.watch('tasks').first).single;
      expect(record.flag('completed'), true);
      expect(record.data['extensions'], {'futureField': true});
      expect(record.revision, 2);
    },
  );
  test(
    'Analytics use own completed records and dispose clears user data',
    () async {
      final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
      await repo.saveCalendar(
        plan: plan('p'),
        sessions: [session('s', 'p', 9)],
      );
      final current = (await repo.watch('sessions').first).single;
      await repo.saveCalendar(
        sessions: [
          StudyRecord(current.id, {
            ...current.data,
            'status': 'completed',
            'actualMinutes': 45,
            'rating': 4,
            'completedAt': Timestamp.now(),
          }),
        ],
      );
      final vm = StudyDataViewModel(repo);
      await drain();
      expect(vm.ready, true);
      expect(vm.totalMinutes, 45);
      expect(vm.progress, 100);
      expect(vm.streak, 1);
      final other = StudyDataViewModel(
        StudyDatabase('bob', firestore: repo.db),
      );
      await drain();
      expect(other.totalMinutes, 0);
      expect(other.items('plans'), isEmpty);
      vm.dispose();
      expect(vm.records, isEmpty);
      other.dispose();
    },
  );
  test(
    'Restores wizard drafts, including typed lists, within one user only',
    () async {
      final db = FakeFirebaseFirestore();
      final a = StudyDatabase('alice', firestore: db);
      await a.save('settings', 'editor', {
        'values': {
          'courses': ['Toán cao cấp'],
          'days': [1, 3],
          'milestones': [
            {'title': 'Mốc', 'id': 'm', 'notes': '', 'completed': false},
          ],
        },
        'allocation': {'weeklyHours': 18},
      });
      final vm = StudyDataViewModel(a);
      await drain();
      expect(vm.drafts['courses'], isA<List<String>>());
      expect(vm.drafts['milestones'], isA<List<Map<String, dynamic>>>());
      final bob = StudyDataViewModel(StudyDatabase('bob', firestore: db));
      await drain();
      expect(bob.drafts, isEmpty);
      vm.dispose();
      bob.dispose();
    },
  );
  test('Logout guard waits for writes and surfaces unsaved changes', () async {
    final vm = StudyDataViewModel(
      StudyDatabase('alice', firestore: FakeFirebaseFirestore()),
    );
    var finished = false;
    final save = vm.run('slow-save', () async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      finished = true;
    });
    await vm.prepareSignOut();
    expect(finished, true);
    expect(await save, true);
    await vm.run('failed-save', () async {
      throw const DataFailure('test', 'Chưa lưu');
    });
    await expectLater(vm.prepareSignOut(), throwsA(isA<DataFailure>()));
    vm.dispose();
  });
}
