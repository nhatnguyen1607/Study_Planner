import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/services/study_database.dart';
import 'package:study_planner_flutter/view/study_planner_app.dart';
import 'package:study_planner_flutter/view/common/figma_widgets.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/study_data_view_model.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

Future<void> drain() async =>
    Future<void>.delayed(const Duration(milliseconds: 20));
Future<void> loadFonts() async {
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final font = File('test/fonts/Roboto-$weight.ttf');
    await (FontLoader('Roboto')..addFont(
          Future.value(ByteData.sublistView(await font.readAsBytes())),
        ))
        .load();
  }
}

void main() {
  setUpAll(loadFonts);
  test('Custom subject catalog is unique, survives reload and stays isolated by UID', () async {
    final store = FakeFirebaseFirestore(),
        data = StudyDataViewModel(
          StudyDatabase('alice', firestore: FakeFirebaseFirestore()),
        );
    data.dispose();
    final repo = StudyDatabase('alice', firestore: store),
        alice = StudyDataViewModel(StudyDatabase('alice', firestore: store));
    await drain();
    expect(alice.subjects.length, 7);
    expect(alice.selectedSubjects.length, 3);
    expect(await alice.addSubject('  Thiết kế   UX/UI  '), true);
    await drain();
    final subject = alice.subjects.last;
    expect(subject.name, 'Thiết kế UX/UI');
    expect(alice.selectedSubjects.last.id, subject.id);
    expect(await alice.addSubject('thiết kế UX/UI'), false);
    expect(alice.changeSubjectHours(subject, 2), true);
    expect(alice.changeSubjectHours(subject, 0), false);
    expect(
      await alice.setting('editor', {
        'values': Map<String, dynamic>.of(alice.drafts),
        'allocation': <String, dynamic>{},
      }),
      true,
    );
    await drain();
    final reloaded = StudyDataViewModel(repo),
        bob = StudyDataViewModel(StudyDatabase('bob', firestore: store));
    await drain();
    expect(reloaded.subjects.last.id, subject.id);
    expect(reloaded.subjectHoursFor(reloaded.subjects.last), 2);
    expect(bob.subjects.length, 7);
    expect(bob.subjects.any((s) => s.name == subject.name), false);
    alice.dispose();
    expect(alice.drafts, isEmpty);
    reloaded.dispose();
    bob.dispose();
  });
  testWidgets(
    'Subject form, filtering and allocation support newly created subjects',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore()),
          vm = StudyPlannerViewModel();
      final data = StudyDataViewModel(repo);
      vm.database = data;
      vm.navigate(StudyDestination.pl07);
      addTearDown(vm.dispose);
      addTearDown(data.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildStudyTheme(),
          home: StudyPlannerApp(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('course-search')), findsOneWidget);
      expect(find.byType(FigmaSubjectTile), findsNWidgets(7));
      await tester.tap(find.byKey(const Key('add-subject')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tên môn học'),
        'Thiết kế UX/UI',
      );
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(data.subjects.last.name, 'Thiết kế UX/UI');
      expect(data.selectedSubjects.length, 4);
      await tester.enterText(find.byKey(const Key('course-search')), 'UX/UI');
      await tester.pumpAndSettle();
      expect(find.byType(FigmaSubjectTile), findsOneWidget);
      vm.navigate(StudyDestination.pl09);
      await tester.pumpAndSettle();
      expect(find.text('Thiết kế UX/UI'), findsOneWidget);
      expect(find.byType(StudyMascot), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Plan confirmation saves two custom subjects with different session IDs',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repo = StudyDatabase('alice', firestore: FakeFirebaseFirestore()),
          vm = StudyPlannerViewModel();
      final data = StudyDataViewModel(repo);
      vm.database = data;
      addTearDown(vm.dispose);
      addTearDown(data.dispose);
      await tester.runAsync(() async {
        await drain();
        expect(await data.addSubject('Thiết kế UX/UI'), true);
        expect(await data.addSubject('Kinh tế học'), true);
      });
      for (final subject
          in data.selectedSubjects
              .where((s) => ['math', 'english', 'python'].contains(s.id))
              .toList()) {
        data.toggleSubject(subject);
      }
      data.changeSubjectHours(data.selectedSubjects.first, 2);
      expect(vm.allocatedHours, 3);
      final start = DateTime.now().add(const Duration(days: 7));
      data.drafts['planTitle'] = 'Kế hoạch môn tự thêm';
      data.drafts['planStart'] = start.toIso8601String();
      data.drafts['planEnd'] = start
          .add(const Duration(days: 13))
          .toIso8601String();
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
      final plans = await repo.watch('plans').first,
          sessions = await repo.watch('sessions').first;
      expect(plans.length, 1);
      expect((plans.single.data['subjectHours'] as Map)['Thiết kế UX/UI'], 2);
      expect((plans.single.data['subjectHours'] as Map)['Kinh tế học'], 1);
      expect(sessions, isNotEmpty);
      expect(sessions.map((s) => s.id).toSet().length, sessions.length);
      expect(sessions.map((s) => s.text('subject')).toSet(), {
        'Thiết kế UX/UI',
        'Kinh tế học',
      });
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Export restored layouts with the existing Elements mascot', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final vm = StudyPlannerViewModel(),
        data = StudyDataViewModel(
          StudyDatabase('preview-user', firestore: FakeFirebaseFirestore()),
        );
    vm.database = data;
    addTearDown(vm.dispose);
    addTearDown(data.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildStudyTheme(),
        home: RepaintBoundary(
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
    for (final destination in [
      StudyDestination.hm01,
      StudyDestination.pl01,
      StudyDestination.pl06,
      StudyDestination.pl07,
      StudyDestination.pl09,
      StudyDestination.pl11,
      StudyDestination.go01,
      StudyDestination.go02,
      StudyDestination.an01,
      StudyDestination.an07,
      StudyDestination.an08,
      StudyDestination.pr01,
    ]) {
      vm.navigate(destination);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: destination.name);
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File('build/figma_restore/${destination.name}.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
