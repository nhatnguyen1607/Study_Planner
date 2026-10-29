import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/model/study_record.dart';
import 'package:study_planner_flutter/services/study_database.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/viewmodel/study_data_view_model.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

class DelayedEditorDatabase extends StudyDatabase {
  DelayedEditorDatabase() : super('alice', firestore: FakeFirebaseFirestore());
  bool delayEditor = false;
  bool rejectEditor = false;
  int editorWrites = 0;
  @override
  Stream<List<StudyRecord>> watch(String kind) =>
      super.watch(kind).asyncMap((items) async {
        if (kind == 'settings' && delayEditor) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        return items;
      });
  @override
  Future<void> save(
    String kind,
    String id,
    Map<String, dynamic> values, {
    int? expected,
  }) async {
    if (kind == 'settings' && id == 'editor') {
      editorWrites++;
      if (rejectEditor) {
        throw const DataFailure('conflict', 'Unexpected extra draft write');
      }
    }
    await super.save(kind, id, values, expected: expected);
  }
}

Future<void> until(bool Function() ready) async {
  for (var i = 0; i < 300; i++) {
    if (ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('View model did not receive the committed snapshot');
}

void main() {
  test(
    'Wizard saves wait for committed snapshots before the next step',
    () async {
      final repo = DelayedEditorDatabase();
      final vm = StudyDataViewModel(repo);
      addTearDown(vm.dispose);
      await until(() => vm.ready);
      repo.delayEditor = true;
      final first = vm.setting('editor', {
        'values': {'planTitle': 'Kế hoạch mới'},
        'allocation': {},
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        vm.busy,
        true,
        reason: 'Do not enable the next step before the snapshot arrives',
      );
      expect(await first, true);
      expect(vm.find('settings', 'editor')!.revision, 1);
      expect(
        await vm.setting('editor', {
          'values': {'planTitle': 'Đã chọn môn'},
          'allocation': {},
        }),
        true,
      );
      expect(vm.find('settings', 'editor')!.revision, 2);
      expect(vm.error, isNull);
      // A real stale edit from another writer must still be rejected.
      await repo.save('settings', 'editor', {
        'values': {'planTitle': 'Bản mới trên máy chủ'},
      }, expected: 2);
      expect(
        await vm.setting('editor', {
          'values': {'planTitle': 'Bản cũ'},
        }),
        false,
      );
      expect(vm.error, contains('[conflict]'));
      await until(() => vm.find('settings', 'editor')?.revision == 3);
      expect(vm.find('settings', 'editor')!.data['values'], {
        'planTitle': 'Bản mới trên máy chủ',
      });
    },
  );

  testWidgets('Creating a plan navigates once and never resaves the editor', (
    tester,
  ) async {
    final repo = DelayedEditorDatabase(), vm = StudyPlannerViewModel();
    final data = StudyDataViewModel(repo);
    vm.database = data;
    addTearDown(data.dispose);
    addTearDown(vm.dispose);
    await tester.runAsync(() => until(() => data.ready));
    repo.rejectEditor = true;
    final start = DateTime.now().add(const Duration(days: 7));
    data.drafts.addAll({
      'planTitle': 'Lịch kiểm tra đồng bộ',
      'planStart': start.toIso8601String(),
      'planEnd': start.add(const Duration(days: 6)).toIso8601String(),
    });
    vm.navigate(StudyDestination.pl11);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildStudyTheme(),
        home: StudyPlannerApp(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo kế hoạch'));
    await tester.pumpAndSettle();
    expect(vm.destination, StudyDestination.pl12);
    expect(repo.editorWrites, 0);
    expect(data.error, isNull);
    expect(data.drafts.containsKey('planDraftId'), false);
    final plans = await repo.watch('plans').first;
    expect(plans.length, 1);
    expect(data.selectedPlanId, plans.single.id);
    expect(tester.takeException(), isNull);
  });
}
