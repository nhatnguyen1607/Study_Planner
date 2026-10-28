import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL17.kt.
class Pl17Screen extends StatelessWidget {
  const Pl17Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl17),
    vm: viewModel,
    title: 'Lên lịch buổi học',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      hero(
        Icons.edit_calendar_outlined,
        'Buổi học linh hoạt',
        'Chọn thời gian phù hợp với bạn',
      ),
      KCard([
        plannerDetail(
          Icons.calendar_today,
          'Ngày học',
          'Thứ 4, 24/04/2024',
          tap: () {},
        ),
        plannerDetail(Icons.schedule, 'Bắt đầu', '10:00', tap: () {}),
        plannerDetail(
          Icons.timer_outlined,
          'Thời lượng',
          '90 phút',
          tap: () {},
        ),
        plannerDetail(
          Icons.location_on_outlined,
          'Địa điểm',
          'Thư viện · P204',
          tap: () {},
        ),
      ]),
      const KField(
        'Ghi chú',
        value: 'Ôn đạo hàm và làm bài tập',
        lines: 3,
        icon: Icons.notes,
      ),
      selectRow(
        Icons.notifications_active_outlined,
        'Nhắc trước 15 phút',
        'Đã bật',
        selected: true,
        tap: () {},
      ),
      KButton('Xác nhận và lưu', s.go(D.pl16), leading: '✓'),
    ],
  );
}
