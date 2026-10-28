import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/services/planner_state_repository.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

void main() {
  test(
    'Round-trip editable state, isolate UID and preserve unknown future fields',
    () async {
      final db = FakeFirebaseFirestore(), vm = StudyPlannerViewModel();
      final a = PlannerStateRepository('alice', db: db),
          b = PlannerStateRepository('bob', db: db);
      vm.setWeeklyHours(22);
      vm.setSubjectHours(0, 6);
      vm.toggleTask('Task');
      await a.save(vm.cloudState);
      await a.ref.update({'futureField': 'keep'});
      await a.save(vm.cloudState);
      final restored = StudyPlannerViewModel()
        ..restoreCloudState((await a.load())!);
      expect(restored.weeklyHours, 22);
      expect(restored.subjectHours[0], 6);
      expect(restored.completedTasks, contains('Task'));
      expect((await a.load())!['futureField'], 'keep');
      expect(await b.load(), isNull);
      vm.dispose();
      restored.dispose();
    },
  );
  test('Unknown schema versions cannot silently overwrite data', () {
    final vm = StudyPlannerViewModel();
    expect(
      () => vm.restoreCloudState({'schemaVersion': 999}),
      throwsFormatException,
    );
    vm.dispose();
  });
}
