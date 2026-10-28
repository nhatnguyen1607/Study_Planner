import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/study_record.dart';
import 'package:study_planner_flutter/services/ai_schedule_repository.dart';
import 'package:study_planner_flutter/view/PL/ai_schedule_screen.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/viewmodel/ai_schedule_view_model.dart';

class ScreenAi implements AiScheduleRepository {
  int generated = 0, confirmed = 0;
  @override
  Future<Map<String, dynamic>> generate(
    List<String> subjects,
    int hours, {
    String objective = '',
  }) async {
    generated++;
    return {
      'draftId': 'preview',
      'title': 'Kế hoạch từ Gemini',
      'objective': 'Ôn kiến thức cơ bản',
      'sessions': [
        {
          'subject': subjects.first,
          'topic': 'Ôn tập chương đầu',
          'notes': 'Đọc lý thuyết và giải bài tập.',
          'day': 0,
          'startMinute': 420,
          'durationMinutes': 60,
        },
      ],
    };
  }

  @override
  Future<String> confirm(
    String draftId,
    DateTime start, {
    int weeks = 4,
  }) async {
    confirmed++;
    if (confirmed == 1) {
      throw const DataFailure('overlap', 'Lịch đang bị trùng. Thử lại.');
    }
    return draftId;
  }
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets(
    'Gemini preview stays after save failure; retry does not regenerate and layout fits phones',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repo = ScreenAi(), vm = AiScheduleViewModel(ScreenAi());
      vm.dispose();
      final state = AiScheduleViewModel(repo);
      addTearDown(state.dispose);
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 844);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildStudyTheme(),
            home: AiScheduleScreen(viewModel: state),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final generate = find.text('Tạo kế hoạch với Gemini');
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(repo.generated, 1);
      expect(find.text('Kế hoạch từ Gemini'), findsOneWidget);
      final save = find.text('Xác nhận lưu lịch 4 tuần');
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(state.error, contains('overlap'));
      expect(state.draft, isNotNull);
      expect(repo.generated, 1);
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(state.savedPlanId, 'preview');
      expect(repo.confirmed, 2);
      expect(repo.generated, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
