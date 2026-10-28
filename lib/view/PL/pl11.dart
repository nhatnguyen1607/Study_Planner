import 'ai_schedule_screen.dart';

import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Preview uses the same allocation state as PL09 and its editing dialogs.
class Pl11Screen extends StatelessWidget {
  const Pl11Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl11),
    vm: viewModel,
    title: 'Xem trước kế hoạch',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      step(6, 'Xác nhận'),
      KColumn([
        const Icon(Icons.celebration_outlined, size: 76, color: green),
        bold('Kế hoạch đã sẵn sàng!', 24),
        const T('Kiểm tra nhanh trước khi bắt đầu', color: muted, center: true),
      ], center: true),
      KCard([
        plannerDetail(Icons.menu_book_outlined, 'Môn học', '3 môn'),
        plannerDetail(
          Icons.schedule,
          'Thời lượng',
          '${viewModel.allocatedHours} giờ/tuần',
        ),
        plannerDetail(Icons.date_range, 'Thời hạn', '2 tháng'),
        plannerDetail(Icons.repeat, 'Lịch học', 'T2 · T4 · T6'),
        plannerDetail(
          Icons.wb_sunny_outlined,
          'Khung giờ',
          viewModel.idealTimeLabel,
        ),
        plannerDetail(
          Icons.notifications_active_outlined,
          'Nhắc nhở',
          'Đã bật',
        ),
      ]),
      for (var i = 0; i < subjects.length; i++)
        selectRow(
          subjects[i].$3,
          subjects[i].$1,
          '${viewModel.subjectHours[i]} giờ/tuần',
          selected: true,
        ),
      KButton(
        'Đề xuất lịch với AI',
        () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AiScheduleScreen()),
        ),
        leading: '✦',
      ),
      KButton('Tạo kế hoạch', s.go(D.pl12), leading: '✓'),
      HoverAction(
        onTap: viewModel.goBack,
        child: const T(
          'Quay lại chỉnh sửa',
          color: dark,
          center: true,
          weight: FontWeight.w600,
        ),
      ),
    ],
  );
}
