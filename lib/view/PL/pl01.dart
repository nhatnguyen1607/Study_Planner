import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL01.kt.
class Pl01Screen extends StatelessWidget {
  const Pl01Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl01),
    vm: viewModel,
    title: 'Kế hoạch học tập',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    back: false,
    body: (s) => [
      hero(
        Icons.auto_awesome_outlined,
        'Chào Nguyễn!',
        'Hôm nay bạn có 3 buổi học',
        trailing: const KRing(60, size: 58, stroke: 7, labelSize: 13),
      ),
      dayStrip(selected: 2),
      plannerStats([
        (Icons.event_available_outlined, '2', 'Đã hoàn thành'),
        (Icons.schedule, '3', 'Còn lại'),
        (Icons.local_fire_department_outlined, '7', 'Chuỗi ngày'),
      ]),
      KRow([
        for (final a in [
          (Icons.today, 'Ngày', D.pl02),
          (Icons.view_week_outlined, 'Tuần', D.pl03),
          (Icons.calendar_month, 'Tháng', D.pl04),
          (Icons.list_alt, 'Kế hoạch', D.pl05),
        ])
          Expanded(
            child: HoverAction(
              onTap: s.go(a.$3),
              child: KColumn([
                Icon(a.$1, size: 25, color: dark),
                T(a.$2, size: 11, weight: FontWeight.w600),
              ], center: true),
            ),
          ),
      ], gap: 10),
      heading('Kế hoạch tiếp theo', action: 'Xem tất cả', tap: s.go(D.pl05)),
      for (final lesson in plannerLessons.take(2))
        lessonCard(lesson, s.go(D.pl16), planner: true, compact: true),
      KButton('Tạo kế hoạch mới', s.go(D.pl06), leading: '+'),
    ],
  );
}
