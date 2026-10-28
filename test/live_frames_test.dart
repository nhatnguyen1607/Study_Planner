import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/services/study_database.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/study_data_view_model.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

import 'study_database_test.dart' as fixtures;

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets(
    'All live frames render with empty and populated user data at phone widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
      final data = StudyDataViewModel(repo), vm = StudyPlannerViewModel();
      vm.database = data;
      addTearDown(data.dispose);
      addTearDown(vm.dispose);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildStudyTheme(),
          home: SizedBox(
            key: boundary,
            child: StudyPlannerApp(viewModel: vm),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final file in Directory(
          'assets/images',
        ).listSync().whereType<File>()) {
          await precacheImage(
            AssetImage('assets/images/${file.uri.pathSegments.last}'),
            boundary.currentContext!,
          );
        }
      });
      for (final populated in [false, true]) {
        if (populated) {
          await tester.runAsync(() async {
            await repo.saveCalendar(
              plan: fixtures.plan('p'),
              sessions: [fixtures.session('s', 'p', 9)],
            );
            await repo.save('goals', 'g', {
              'title': 'Mục tiêu dài kiểm tra không tràn chữ',
              'description': 'Nội dung mục tiêu',
              'category': 'Toán',
              'unit': 'bài',
              'baseline': 0,
              'current': 10,
              'target': 100,
              'deadline': Timestamp.now(),
              'milestones': <Map<String, dynamic>>[],
              'notes': '',
              'rating': 0,
              'archived': false,
            });
            await repo.save('tasks', 't', {
              'title': 'Việc cần làm',
              'notes': 'Mô tả',
              'completed': false,
              'archived': false,
            });
          });
          data.selectedPlanId = 'p';
          data.selectedSessionId = 's';
          data.selectedGoalId = 'g';
        }
        for (final width in [320.0, 390.0]) {
          tester.view.physicalSize = Size(width, 844);
          for (final destination in StudyDestination.values) {
            vm.navigate(destination);
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$destination populated=$populated width=$width',
            );
          }
        }
      }
    },
  );
}
