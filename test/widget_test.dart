import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final name in ['Regular', 'Medium', 'Bold']) {
      final font = File('test/fonts/Roboto-$name.ttf');
      if (await font.exists()) {
        final loader = FontLoader('Roboto')
          ..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          );
        await loader.load();
      }
    }
  });
  testWidgets(
    'All 52 native screen layouts render at phone widths without overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final vm = StudyPlannerViewModel();
      addTearDown(vm.dispose);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildStudyTheme(),
          home: RepaintBoundary(
            key: boundaryKey,
            child: StudyPlannerApp(viewModel: vm),
          ),
        ),
      );
      await tester.runAsync(() async {
        final images = Directory('assets/images').listSync().whereType<File>();
        for (final image in images) {
          await precacheImage(
            AssetImage('assets/images/${image.uri.pathSegments.last}'),
            boundaryKey.currentContext!,
          );
        }
      });
      for (final size in [const Size(390, 844), const Size(360, 800)]) {
        tester.view.physicalSize = size;
        for (final destination in StudyDestination.values) {
          vm.navigate(destination);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${destination.name} at $size',
          );
          if (size.width == 390 &&
              [
                StudyDestination.hm01,
                StudyDestination.go02,
                StudyDestination.an01,
                StudyDestination.an09,
                StudyDestination.pr01,
                StudyDestination.pr05,
                StudyDestination.pl03,
              ].contains(destination)) {
            await tester.runAsync(() async {
              final boundary =
                  boundaryKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final output = File(
                'build/parity_previews/${destination.name}.png',
              );
              await output.parent.create(recursive: true);
              await output.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
      }
    },
  );

  testWidgets(
    'Home navigation, task state, goal progress and profile mode match Kotlin',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final vm = StudyPlannerViewModel();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildStudyTheme(),
          home: StudyPlannerApp(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Nguyễn 👋'), findsOneWidget);
      await tester.tap(find.byTooltip('Tìm kiếm'));
      await tester.pumpAndSettle();
      expect(vm.destination, StudyDestination.hm09);
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.enterText(find.byType(TextField), 'Python');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(vm.destination, StudyDestination.hm10);
      vm.navigate(StudyDestination.hm03);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Làm bài tập Toán cao cấp'));
      await tester.pumpAndSettle();
      expect(vm.completedTasks, contains('Làm bài tập Toán cao cấp'));
      vm.navigate(StudyDestination.go09);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoàn thành cột mốc'));
      await tester.pumpAndSettle();
      expect(vm.goalProgress, 65);
      await tester.tap(find.text('Đánh dấu hoàn thành'));
      await tester.pumpAndSettle();
      expect(vm.goalProgress, 100);
      expect(vm.destination, StudyDestination.go10);
      vm.navigate(StudyDestination.an09);
      await tester.pumpAndSettle();
      expect(find.text('Chia sẻ thành tích'), findsOneWidget);
      expect(find.text('★'), findsNothing);
      vm.navigate(StudyDestination.pr05);
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Màu chủ đạo'), findsOneWidget);
      await tester.tap(find.text('Tối'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
