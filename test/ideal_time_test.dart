import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/model/study_time_slot.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

void main() {
  setUpAll(() async {
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
  test('At least one time slot is required and labels keep day order', () {
    final vm = StudyPlannerViewModel();
    addTearDown(vm.dispose);
    expect(vm.idealTimeLabel, '18:00 - 22:00');
    expect(vm.setIdealTimeSlots({}), isFalse);
    expect(
      vm.setIdealTimeSlots({StudyTimeSlot.evening, StudyTimeSlot.morning}),
      isTrue,
    );
    expect(vm.idealTimeLabel, 'Sáng · Tối');
  });

  testWidgets(
    'Time slot dialog supports multi-select, cancel and returning from preview',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final vm = StudyPlannerViewModel()..navigate(StudyDestination.pl10);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildStudyTheme(),
          home: StudyPlannerApp(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choose-ideal-time')));
      await tester.pumpAndSettle();
      expect(find.text('Chọn 1 hoặc nhiều khung giờ'), findsOneWidget);
      await tester.tap(find.byKey(const Key('time-slot-morning')));
      await tester.tap(find.byKey(const Key('cancel-time-slots')));
      await tester.pumpAndSettle();
      expect(vm.idealTimeSlots, {StudyTimeSlot.evening});
      await tester.tap(find.byKey(const Key('choose-ideal-time')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('time-slot-evening')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('save-time-slots')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('time-slot-morning')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('time-slot-afternoon')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-time-slots')));
      await tester.pumpAndSettle();
      expect(vm.idealTimeSlots, {
        StudyTimeSlot.morning,
        StudyTimeSlot.afternoon,
      });
      expect(find.text('Sáng · Chiều'), findsOneWidget);
      await tester.tap(find.text('Xem trước kế hoạch'));
      await tester.pumpAndSettle();
      expect(find.text('Sáng · Chiều'), findsOneWidget);
      vm.goBack();
      await tester.pumpAndSettle();
      expect(find.text('Sáng · Chiều'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('choose-ideal-time')));
      await tester.tap(find.byKey(const Key('choose-ideal-time')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
