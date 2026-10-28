import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL08.kt.
class Pl08Screen extends StatelessWidget {
  const Pl08Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl08),
    vm: viewModel,
    title: 'Chọn khoảng thời gian',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      step(3, 'Thời gian'),
      hero(
        Icons.date_range,
        '15/10 — 15/12',
        'Hai tháng để hoàn thành kế hoạch',
      ),
      KCard([
        plannerDetail(
          Icons.calendar_today,
          'Thời gian bắt đầu',
          '15 tháng 10, 2026',
          tap: () {},
        ),
        plannerDetail(
          Icons.event,
          'Thời gian kết thúc',
          '15 tháng 12, 2026',
          tap: () {},
        ),
        plannerDetail(Icons.repeat, 'Tần suất học', '3 buổi/tuần', tap: () {}),
      ]),
      KCard([
        plannerDetail(Icons.lightbulb_outline, 'Gợi ý', 'Lịch cân bằng'),
        const T(
          'Bạn có thể điều chỉnh lịch học sau khi tạo kế hoạch. AI sẽ tối ưu thời gian còn lại.',
          color: muted,
        ),
      ]),
      KButton('Tiếp tục', s.go(D.pl09)),
    ],
  );
}
