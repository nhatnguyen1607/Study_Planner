import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN02.kt. Screen-specific structure is kept here.
class An02Screen extends StatelessWidget {
  const An02Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an02),
    vm: viewModel,
    title: 'Thời gian học tập',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      s.tabs(['Ngày', 'Tuần', 'Tháng', 'Năm']),
      bold('5h 20m', 30),
      const T('Hôm nay · ↑ 21% so với trung bình', color: dark),
      KCard([
        const KChart(
          [1, 2, 1.5, 3, 4, 2.5, 1.8],
          ['6h', '9h', '12h', '15h', '18h', '21h', '24h'],
        ),
      ], onTap: s.go(D.an05)),
      heading('Phân bổ thời gian'),
      KCard([
        statLine('Học lý thuyết', '2h 30m · 43%'),
        statLine('Làm bài tập', '1h 30m · 28%', color: navy),
        statLine('Ôn tập', '1h · 18%', color: peach),
        statLine('Đọc tài liệu', '20m · 11%', color: muted),
      ]),
    ],
  );
}
