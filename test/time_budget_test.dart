import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final font = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium', 'Bold']) {
      font.addFont(
        Future.value(
          ByteData.sublistView(
            await File('test/fonts/Roboto-$weight.ttf').readAsBytes(),
          ),
        ),
      );
    }
    await font.load();
  });

  test('Time allocation stays within the weekly budget', () {
    final vm = StudyPlannerViewModel();
    addTearDown(vm.dispose);
    expect(vm.subjectHours, [3, 2, 4]);
    expect(vm.allocatedHours, 9);
    expect(vm.weeklyHours, 18);
    expect(vm.remainingHours, 9);
    expect(vm.setSubjectHours(-1, 4), isFalse);
    expect(vm.setSubjectHours(3, 4), isFalse);
    expect(vm.setSubjectHours(0, 0), isFalse);
    expect(vm.setSubjectHours(0, 13), isFalse);
    expect(vm.setSubjectHours(0, 12), isTrue);
    expect(vm.remainingHours, 0);
    expect(vm.setWeeklyHours(17), isFalse);
    expect(vm.setWeeklyHours(169), isFalse);
    expect(vm.setWeeklyHours(20), isTrue);
    expect(vm.remainingHours, 2);
  });

  testWidgets(
    'Subject and weekly dialogs save, cancel and update the preview',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final vm = StudyPlannerViewModel()..navigate(StudyDestination.pl09);
      addTearDown(vm.dispose);
      final previewKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: previewKey,
          child: MaterialApp(
            theme: buildStudyTheme(),
            home: StudyPlannerApp(viewModel: vm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/study_planner_bg.png'),
          previewKey.currentContext!,
        ),
      );
      await tester.pumpAndSettle();

      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final render =
              previewKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('build/parity_previews/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      expect(find.text('Tổng thời lượng: 9/18 giờ'), findsOneWidget);
      await capture('pl09_allocation');
      await tester.tap(find.byKey(const Key('subject-hours-0')));
      await tester.pumpAndSettle();
      expect(find.text('Thời lượng Toán cao cấp'), findsOneWidget);
      await capture('pl09_subject_dialog');
      await tester.tap(find.byKey(const Key('increase-hours')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cancel-hours')));
      await tester.pumpAndSettle();
      expect(vm.subjectHours[0], 3);

      for (var index = 0; index < 3; index++) {
        await tester.tap(find.byKey(Key('subject-hours-$index')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('increase-hours')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm-hours')));
        await tester.pumpAndSettle();
      }
      expect(vm.subjectHours, [4, 3, 5]);
      expect(find.text('Tổng thời lượng: 12/18 giờ'), findsOneWidget);
      expect(find.text('Còn lại: 6 giờ'), findsOneWidget);

      await tester.tap(find.byKey(const Key('edit-week-hours')));
      await tester.pumpAndSettle();
      expect(find.text('Tổng thời gian học mỗi tuần'), findsOneWidget);
      await capture('pl09_week_dialog');
      await tester.tap(find.byKey(const Key('increase-hours')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cancel-hours')));
      await tester.pumpAndSettle();
      expect(vm.weeklyHours, 18);

      await tester.tap(find.byKey(const Key('edit-week-hours')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('decrease-hours')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-hours')));
      await tester.pumpAndSettle();
      expect(vm.weeklyHours, 17);
      expect(find.text('Tổng thời lượng: 12/17 giờ'), findsOneWidget);
      expect(find.text('Còn lại: 5 giờ'), findsOneWidget);
      vm.navigate(StudyDestination.pl11);
      await tester.pumpAndSettle();
      expect(find.text('12 giờ/tuần'), findsOneWidget);
      expect(find.text('4 giờ/tuần'), findsOneWidget);
      expect(find.text('3 giờ/tuần'), findsOneWidget);
      expect(find.text('5 giờ/tuần'), findsOneWidget);
      expect(tester.takeException(), isNull);

      vm.goBack();
      await tester.pumpAndSettle();
      expect(find.text('Tổng thời lượng: 12/17 giờ'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('subject-hours-0')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('cancel-hours')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('edit-week-hours')));
      await tester.tap(find.byKey(const Key('edit-week-hours')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
