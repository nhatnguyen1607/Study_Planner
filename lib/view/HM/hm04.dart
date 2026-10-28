import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM04.kt.
class Hm04Screen extends StatelessWidget {
  const Hm04Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm04),
    vm: viewModel,
    title: 'Hoạt động sắp diễn ra',
    section: 1,
    padding: 15,
    top: (s) => [
      s.tabs(['Tất cả', 'Học tập', 'Khác']),
      gap(18),
    ],
    body: (s) => [
      for (final group in [
        (
          'Ngày mai - Thứ 3, 15/10',
          <Lesson>[
            ('Toán cao cấp', '10:00-11:30', 'Phòng A2-301', 0, false),
            ('Luyện nói', '13:00-14:00', 'Phòng A2-303', 1, false),
          ],
        ),
        (
          'Thứ 4, Ngày 16/10',
          <Lesson>[
            ('Viết báo cáo', '14:00-15:00', 'Phòng A2-304', 3, false),
            ('Viết tiếng anh', '15:00-16:00', 'Phòng A2-305', 1, false),
          ],
        ),
      ]) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: bold(group.$1, 20),
        ),
        gap(8),
        for (final l in group.$2) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: lessonCard(l, s.go(D.pl16), chevron: true),
          ),
          gap(8),
        ],
      ],
    ],
  );
}
